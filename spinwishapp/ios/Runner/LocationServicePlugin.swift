import Flutter
import UIKit
import CoreLocation

public class LocationServicePlugin: NSObject, FlutterPlugin, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var channel: FlutterMethodChannel?
    private var pendingResult: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "location_service", binaryMessenger: registrar.messenger())
        let instance = LocationServicePlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(result: result)
        case "requestPermission":
            requestPermission(result: result)
        case "isLocationEnabled":
            isLocationEnabled(result: result)
        case "getCurrentLocation":
            getCurrentLocation(result: result)
        case "startLocationTracking":
            startLocationTracking(result: result)
        case "stopLocationTracking":
            stopLocationTracking(result: result)
        case "updateDiscoverySettings":
            updateDiscoverySettings(result: result)
        case "getNearbyDJs":
            getNearbyDJs(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(result: @escaping FlutterResult) {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        let hasPermission = hasLocationPermission()
        let isEnabled = CLLocationManager.locationServicesEnabled()
        
        result([
            "isLocationEnabled": isEnabled,
            "hasPermission": hasPermission
        ])
    }
    
    private func requestPermission(result: @escaping FlutterResult) {
        guard let locationManager = locationManager else {
            result(FlutterError(code: "NO_LOCATION_MANAGER", message: "Location manager not initialized", details: nil))
            return
        }
        
        if hasLocationPermission() {
            result(["granted": true])
            return
        }
        
        pendingResult = result
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func isLocationEnabled(result: @escaping FlutterResult) {
        result(CLLocationManager.locationServicesEnabled())
    }
    
    private func getCurrentLocation(result: @escaping FlutterResult) {
        guard hasLocationPermission() else {
            result(FlutterError(code: "PERMISSION_DENIED", message: "Location permission not granted", details: nil))
            return
        }
        
        guard CLLocationManager.locationServicesEnabled() else {
            result(FlutterError(code: "LOCATION_DISABLED", message: "Location services disabled", details: nil))
            return
        }
        
        guard let location = locationManager?.location else {
            result(nil)
            return
        }
        
        result([
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "timestamp": Int64(location.timestamp.timeIntervalSince1970 * 1000)
        ])
    }
    
    private func startLocationTracking(result: @escaping FlutterResult) {
        guard hasLocationPermission() && CLLocationManager.locationServicesEnabled() else {
            result(FlutterError(code: "PERMISSION_OR_SERVICE_UNAVAILABLE", message: "Permission or location service unavailable", details: nil))
            return
        }
        
        locationManager?.startUpdatingLocation()
        result(true)
    }
    
    private func stopLocationTracking(result: @escaping FlutterResult) {
        locationManager?.stopUpdatingLocation()
        result(true)
    }
    
    private func updateDiscoverySettings(result: @escaping FlutterResult) {
        // Store settings in UserDefaults or send to backend
        result(true)
    }
    
    private func getNearbyDJs(result: @escaping FlutterResult) {
        // Return empty list for now - would integrate with backend API
        result([])
    }
    
    private func hasLocationPermission() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let result = pendingResult {
            let granted = status == .authorizedWhenInUse || status == .authorizedAlways
            result(["granted": granted])
            pendingResult = nil
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Location updates would be sent via event channel in a full implementation
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
}

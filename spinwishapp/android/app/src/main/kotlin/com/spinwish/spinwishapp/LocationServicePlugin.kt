package com.spinwish.spinwishapp

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class LocationServicePlugin: FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: android.app.Activity? = null
    private var locationManager: LocationManager? = null
    private var locationListener: LocationListener? = null
    private var pendingResult: Result? = null

    companion object {
        private const val LOCATION_PERMISSION_REQUEST_CODE = 1001
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "location_service")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        locationManager = context?.getSystemService(Context.LOCATION_SERVICE) as LocationManager
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initialize(result)
            "requestPermission" -> requestPermission(result)
            "isLocationEnabled" -> isLocationEnabled(result)
            "getCurrentLocation" -> getCurrentLocation(result)
            "startLocationTracking" -> startLocationTracking(result)
            "stopLocationTracking" -> stopLocationTracking(result)
            "updateDiscoverySettings" -> updateDiscoverySettings(call, result)
            "getNearbyDJs" -> getNearbyDJs(call, result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(result: Result) {
        val hasPermission = hasLocationPermission()
        val isEnabled = isLocationServiceEnabled()
        
        result.success(mapOf(
            "isLocationEnabled" to isEnabled,
            "hasPermission" to hasPermission
        ))
    }

    private fun requestPermission(result: Result) {
        if (hasLocationPermission()) {
            result.success(mapOf("granted" to true))
            return
        }

        pendingResult = result
        activity?.let {
            ActivityCompat.requestPermissions(
                it,
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ),
                LOCATION_PERMISSION_REQUEST_CODE
            )
        } ?: result.error("NO_ACTIVITY", "Activity not available", null)
    }

    private fun isLocationEnabled(result: Result) {
        result.success(isLocationServiceEnabled())
    }

    private fun getCurrentLocation(result: Result) {
        if (!hasLocationPermission()) {
            result.error("PERMISSION_DENIED", "Location permission not granted", null)
            return
        }

        if (!isLocationServiceEnabled()) {
            result.error("LOCATION_DISABLED", "Location services disabled", null)
            return
        }

        try {
            val location = locationManager?.getLastKnownLocation(LocationManager.GPS_PROVIDER)
                ?: locationManager?.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)

            if (location != null) {
                result.success(mapOf(
                    "latitude" to location.latitude,
                    "longitude" to location.longitude,
                    "accuracy" to location.accuracy.toDouble(),
                    "timestamp" to location.time
                ))
            } else {
                result.success(null)
            }
        } catch (e: SecurityException) {
            result.error("SECURITY_EXCEPTION", e.message, null)
        }
    }

    private fun startLocationTracking(result: Result) {
        if (!hasLocationPermission() || !isLocationServiceEnabled()) {
            result.error("PERMISSION_OR_SERVICE_UNAVAILABLE", "Permission or location service unavailable", null)
            return
        }

        try {
            locationListener = object : LocationListener {
                override fun onLocationChanged(location: Location) {
                    // Location updates would be sent via event channel in a full implementation
                }
                override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
                override fun onProviderEnabled(provider: String) {}
                override fun onProviderDisabled(provider: String) {}
            }

            locationManager?.requestLocationUpdates(
                LocationManager.GPS_PROVIDER,
                10000L, // 10 seconds
                10f,    // 10 meters
                locationListener!!
            )

            result.success(true)
        } catch (e: SecurityException) {
            result.error("SECURITY_EXCEPTION", e.message, null)
        }
    }

    private fun stopLocationTracking(result: Result) {
        locationListener?.let {
            locationManager?.removeUpdates(it)
            locationListener = null
        }
        result.success(true)
    }

    private fun updateDiscoverySettings(call: MethodCall, result: Result) {
        // Store settings in SharedPreferences or send to backend
        result.success(true)
    }

    private fun getNearbyDJs(call: MethodCall, result: Result) {
        // Return empty list for now - would integrate with backend API
        result.success(emptyList<Map<String, Any>>())
    }

    private fun hasLocationPermission(): Boolean {
        return context?.let {
            ContextCompat.checkSelfPermission(it, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(it, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
        } ?: false
    }

    private fun isLocationServiceEnabled(): Boolean {
        return locationManager?.isProviderEnabled(LocationManager.GPS_PROVIDER) == true ||
               locationManager?.isProviderEnabled(LocationManager.NETWORK_PROVIDER) == true
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingResult?.success(mapOf("granted" to granted))
            pendingResult = null
            return true
        }
        return false
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}

import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register location service plugin
    let controller = window?.rootViewController as! FlutterViewController
    LocationServicePlugin.register(with: registrar(forPlugin: "LocationServicePlugin")!)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

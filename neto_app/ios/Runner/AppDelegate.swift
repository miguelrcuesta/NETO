import UIKit
import Flutter
import FirebaseCore // ⬅️ Must be present

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ⬅️ This is likely line 12 referenced in the crash report
    FirebaseApp.configure() // ⬅️ This line is where the crash occurs
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
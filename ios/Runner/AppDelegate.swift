import UIKit
import Flutter
import Firebase
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      GMSServices.provideAPIKey("AIzaSyAhtyxgDSU4aJnUjk5zyLvt7s1qSvY8UDQ")
      GeneratedPluginRegistrant.register(with: self)
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self
      }
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

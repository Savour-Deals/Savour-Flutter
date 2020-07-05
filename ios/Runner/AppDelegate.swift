import UIKit
import Flutter
import GoogleMaps
import FirebaseAuth

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      GMSServices.provideAPIKey("AIzaSyAhtyxgDSU4aJnUjk5zyLvt7s1qSvY8UDQ")
      GeneratedPluginRegistrant.register(with: self)
      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
      }
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      // Pass device token to auth
      Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
  }
  override func application(_ application: UIApplication,
      didReceiveRemoteNotification notification: [AnyHashable : Any],
      fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if Auth.auth().canHandleNotification(notification) {
      completionHandler(.noData)
      return
    }
    // This notification is not auth related, developer should handle it.
  }
    
}

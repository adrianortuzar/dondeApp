import UIKit
import RealmSwift

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // print document folder
    print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])

    // init data manager
    _ = DataManager.shared

    self.window =  UIWindow(frame: UIScreen.main.bounds)

    let navigationController: UINavigationController! = UINavigationController.init(rootViewController: DayTrackViewController())
    navigationController.navigationBar.isTranslucent = false

    self.window?.rootViewController = navigationController
    self.window?.makeKeyAndVisible()

    // init location manager
    _ = LocationManager.shared

    // observer location manager status
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.methodOfReceivedNotification(notification:)),
      name: Notification.Name(LocationManager.notificationDidChangeAuthorization),
      object: nil
    )

    return true
  }

  func methodOfReceivedNotification(notification: Notification) {
    //Take Action on Notification
    print("Change notification status")
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers,
    // and store enough application state information to restore
    // your application to its current state in case it is terminated later.

    // If your application supports background execution,
    // this method is called instead of applicationWillTerminate: when the user quits.
    application.beginBackgroundTask(withName: "location") {
      print("")
    }
  }
}

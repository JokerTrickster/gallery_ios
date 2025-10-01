import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Test log for PR creation check
        print("🧪 [PR TEST] AppDelegate initialized - Testing PR creation workflow")

        window = UIWindow(frame: UIScreen.main.bounds)

        let navigationController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navigationController)
        appCoordinator?.start()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}
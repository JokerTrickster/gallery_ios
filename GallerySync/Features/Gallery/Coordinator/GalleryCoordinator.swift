import UIKit

class GalleryCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let galleryViewModel = GalleryViewModel()
        let galleryViewController = GalleryViewController(viewModel: galleryViewModel)
        galleryViewController.coordinator = self
        navigationController.pushViewController(galleryViewController, animated: false)
    }

    func showCloudSync() {
        let cloudSyncCoordinator = CloudSyncCoordinator(navigationController: navigationController)
        addChildCoordinator(cloudSyncCoordinator)
        cloudSyncCoordinator.start()
    }

    func showSettings() {
        let settingsCoordinator = SettingsCoordinator(navigationController: navigationController)
        addChildCoordinator(settingsCoordinator)
        settingsCoordinator.start()
    }
}
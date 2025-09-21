import UIKit

class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showGallery()
    }

    private func showGallery() {
        let galleryCoordinator = GalleryCoordinator(navigationController: navigationController)
        addChildCoordinator(galleryCoordinator)
        galleryCoordinator.start()
    }
}
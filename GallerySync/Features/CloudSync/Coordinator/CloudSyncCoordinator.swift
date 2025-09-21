import UIKit

class CloudSyncCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let cloudSyncViewModel = CloudSyncViewModel()
        let cloudSyncViewController = CloudSyncViewController(viewModel: cloudSyncViewModel)
        cloudSyncViewController.coordinator = self
        navigationController.pushViewController(cloudSyncViewController, animated: true)
    }
}
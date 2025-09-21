import Foundation
import Combine

class CloudSyncViewModel: ObservableObject {
    @Published var syncProgress: Float = 0.0
    @Published var isSyncing: Bool = false
    @Published var syncStatus: String = "Ready to sync"
    @Published var lastSyncDate: Date?

    private let cloudSyncService = CloudSyncService()
    private var cancellables = Set<AnyCancellable>()

    func startSync() {
        isSyncing = true
        syncStatus = "Syncing..."
        syncProgress = 0.0

        // Simulate sync progress
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isSyncing else { return }
                self.syncProgress += 0.02
                if self.syncProgress >= 1.0 {
                    self.completSync()
                }
            }
            .store(in: &cancellables)
    }

    func stopSync() {
        isSyncing = false
        syncStatus = "Sync cancelled"
        syncProgress = 0.0
        cancellables.removeAll()
    }

    private func completSync() {
        isSyncing = false
        syncStatus = "Sync completed"
        syncProgress = 1.0
        lastSyncDate = Date()
        cancellables.removeAll()
    }
}
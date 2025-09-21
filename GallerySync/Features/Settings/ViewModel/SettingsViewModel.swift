import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var autoSyncEnabled: Bool = false
    @Published var syncQuality: SyncQuality = .medium
    @Published var storageUsed: String = "Loading..."
    @Published var accountStatus: String = "Not signed in"

    enum SyncQuality: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case original = "Original"
    }

    init() {
        loadSettings()
        updateStorageInfo()
    }

    private func loadSettings() {
        autoSyncEnabled = UserDefaults.standard.bool(forKey: "autoSyncEnabled")
        if let qualityRaw = UserDefaults.standard.string(forKey: "syncQuality"),
           let quality = SyncQuality(rawValue: qualityRaw) {
            syncQuality = quality
        }
    }

    func saveSettings() {
        UserDefaults.standard.set(autoSyncEnabled, forKey: "autoSyncEnabled")
        UserDefaults.standard.set(syncQuality.rawValue, forKey: "syncQuality")
    }

    func signOut() {
        accountStatus = "Not signed in"
        // Implement sign out logic
    }

    func clearCache() {
        // Implement cache clearing logic
        updateStorageInfo()
    }

    private func updateStorageInfo() {
        // Simulate storage calculation
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
            DispatchQueue.main.async {
                self.storageUsed = "2.5 GB used"
            }
        }
    }
}
import Foundation

struct Constants {

    struct API {
        static let baseURL = "https://api.gallerysync.com/v1"
        static let timeout: TimeInterval = 30.0
    }

    struct UserDefaults {
        static let autoSyncEnabled = "autoSyncEnabled"
        static let syncQuality = "syncQuality"
        static let lastSyncDate = "lastSyncDate"
        static let userToken = "userToken"
    }

    struct Keychain {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
    }

    struct UI {
        static let thumbnailSize: CGFloat = 100
        static let cornerRadius: CGFloat = 8
        static let spacing: CGFloat = 16
    }

    struct Notifications {
        static let syncCompleted = "syncCompleted"
        static let syncFailed = "syncFailed"
        static let photoLibraryChanged = "photoLibraryChanged"
    }
}
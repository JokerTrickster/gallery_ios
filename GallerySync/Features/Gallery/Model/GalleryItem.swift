import UIKit
import Photos

struct GalleryItem {
    let id: String
    let asset: PHAsset
    let thumbnail: UIImage?
    let creationDate: Date?
    let mediaType: PHAssetMediaType
    var isSelected: Bool
    var isSynced: Bool
    var cloudURL: String?
    var syncStatus: SyncStatus

    enum SyncStatus {
        case notSynced
        case uploading
        case uploaded
        case downloading
        case failed(Error)
    }

    init(asset: PHAsset, thumbnail: UIImage? = nil, isSelected: Bool = false, isSynced: Bool = false, cloudURL: String? = nil) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.thumbnail = thumbnail
        self.creationDate = asset.creationDate
        self.mediaType = asset.mediaType
        self.isSelected = isSelected
        self.isSynced = isSynced
        self.cloudURL = cloudURL
        self.syncStatus = isSynced ? .uploaded : .notSynced
    }

    mutating func toggleSelection() {
        isSelected.toggle()
    }

    mutating func updateSyncStatus(_ status: SyncStatus) {
        syncStatus = status
        switch status {
        case .uploaded:
            isSynced = true
        case .notSynced, .uploading, .downloading, .failed:
            isSynced = false
        }
    }
}
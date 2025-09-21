import UIKit
import Photos

struct GalleryItem {
    let id: String
    let asset: PHAsset
    let thumbnail: UIImage?
    let creationDate: Date?
    let mediaType: PHAssetMediaType
    let isSelected: Bool
    let isSynced: Bool
    let cloudURL: String?

    init(asset: PHAsset, thumbnail: UIImage? = nil) {
        self.id = asset.localIdentifier
        self.asset = asset
        self.thumbnail = thumbnail
        self.creationDate = asset.creationDate
        self.mediaType = asset.mediaType
        self.isSelected = false
        self.isSynced = false
        self.cloudURL = nil
    }
}
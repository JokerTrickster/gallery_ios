import Photos
import UIKit

class PhotoLibraryService {

    func requestPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            switch status {
            case .authorized, .limited:
                completion(true)
            default:
                completion(false)
            }
        }
    }

    func fetchAssets(completion: @escaping ([PHAsset]) -> Void) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let allPhotos = PHAsset.fetchAssets(with: fetchOptions)
        var assets: [PHAsset] = []

        allPhotos.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }

        completion(assets)
    }

    func getImageData(from asset: PHAsset, completion: @escaping (Data?) -> Void) {
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat

        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
            completion(data)
        }
    }
}
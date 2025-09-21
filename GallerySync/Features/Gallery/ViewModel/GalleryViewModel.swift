import UIKit
import Photos
import Combine

class GalleryViewModel: ObservableObject {
    @Published var galleryItems: [GalleryItem] = []
    @Published var isLoading: Bool = false
    @Published var error: String?

    private var cancellables = Set<AnyCancellable>()
    private let photoLibraryService = PhotoLibraryService()
    private let cloudSyncService = CloudSyncService()

    init() {
        requestPhotoLibraryPermission()
    }

    func requestPhotoLibraryPermission() {
        photoLibraryService.requestPermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.loadGalleryItems()
                } else {
                    self?.error = "Photo library permission denied"
                }
            }
        }
    }

    func loadGalleryItems() {
        isLoading = true
        photoLibraryService.fetchAssets { [weak self] assets in
            DispatchQueue.main.async {
                self?.galleryItems = assets.map { GalleryItem(asset: $0) }
                self?.isLoading = false
            }
        }
    }

    func syncToCloud(items: [GalleryItem]) {
        isLoading = true
        cloudSyncService.uploadItems(items) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.loadGalleryItems()
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}
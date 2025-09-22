import UIKit
import Photos
import Combine

class GalleryViewModel: ObservableObject {
    @Published var galleryItems: [GalleryItem] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var isSelectionMode: Bool = false
    @Published var selectedItemsCount: Int = 0

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
                self?.updateSelectedItemsCount()
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

    // MARK: - Selection Management
    func toggleSelectionMode() {
        isSelectionMode.toggle()
        if !isSelectionMode {
            clearAllSelections()
        }
    }

    func exitSelectionMode() {
        isSelectionMode = false
        clearAllSelections()
    }

    func toggleItemSelection(at index: Int) {
        guard index < galleryItems.count else { return }
        galleryItems[index].toggleSelection()
        updateSelectedItemsCount()
    }

    func selectAllItems() {
        for i in 0..<galleryItems.count {
            galleryItems[i].isSelected = true
        }
        updateSelectedItemsCount()
    }

    private func clearAllSelections() {
        for i in 0..<galleryItems.count {
            galleryItems[i].isSelected = false
        }
        updateSelectedItemsCount()
    }

    private func updateSelectedItemsCount() {
        selectedItemsCount = galleryItems.filter { $0.isSelected }.count
    }

    // MARK: - Upload/Download Operations
    func uploadAllItems() {
        let itemsToUpload = galleryItems.filter { !$0.isSynced }
        uploadItems(itemsToUpload)
    }

    func uploadSelectedItems() {
        let selectedItems = galleryItems.filter { $0.isSelected }
        uploadItems(selectedItems)
        exitSelectionMode()
    }

    private func uploadItems(_ items: [GalleryItem]) {
        guard !items.isEmpty else {
            error = "No items to upload"
            return
        }

        isLoading = true

        // Update status to uploading
        for item in items {
            if let index = galleryItems.firstIndex(where: { $0.id == item.id }) {
                galleryItems[index].updateSyncStatus(.uploading)
            }
        }

        cloudSyncService.uploadItems(items) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    // Update status to uploaded
                    for item in items {
                        if let index = self?.galleryItems.firstIndex(where: { $0.id == item.id }) {
                            self?.galleryItems[index].updateSyncStatus(.uploaded)
                        }
                    }
                case .failure(let error):
                    // Update status to failed
                    for item in items {
                        if let index = self?.galleryItems.firstIndex(where: { $0.id == item.id }) {
                            self?.galleryItems[index].updateSyncStatus(.failed(error))
                        }
                    }
                    self?.error = error.localizedDescription
                }
            }
        }
    }

    func downloadFromCloud() {
        isLoading = true
        cloudSyncService.downloadItems { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let downloadedItems):
                    // Handle downloaded items - this would typically involve
                    // merging with existing gallery items or showing them separately
                    self?.error = "Downloaded \(downloadedItems.count) items from cloud"
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }
        }
    }
}
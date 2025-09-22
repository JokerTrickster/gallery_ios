import XCTest
import Photos
@testable import GallerySync

class GalleryItemTests: XCTestCase {

    var mockAsset: PHAsset!

    override func setUp() {
        super.setUp()
        mockAsset = PHAsset()
    }

    override func tearDown() {
        mockAsset = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testGalleryItemInitialization() {
        // When: Create GalleryItem with default values
        let item = GalleryItem(asset: mockAsset)

        // Then: Should have correct default values
        XCTAssertEqual(item.id, mockAsset.localIdentifier, "ID should match asset's local identifier")
        XCTAssertEqual(item.asset.localIdentifier, mockAsset.localIdentifier, "Asset should be stored correctly")
        XCTAssertNil(item.thumbnail, "Thumbnail should be nil by default")
        XCTAssertEqual(item.mediaType, mockAsset.mediaType, "Media type should match asset")
        XCTAssertFalse(item.isSelected, "Should not be selected by default")
        XCTAssertFalse(item.isSynced, "Should not be synced by default")
        XCTAssertNil(item.cloudURL, "Cloud URL should be nil by default")

        // Check sync status
        switch item.syncStatus {
        case .notSynced:
            XCTAssertTrue(true, "Sync status should be notSynced by default")
        default:
            XCTFail("Sync status should be notSynced by default")
        }
    }

    func testGalleryItemInitializationWithCustomValues() {
        // Given: Custom values
        let thumbnail = UIImage()
        let isSelected = true
        let isSynced = true
        let cloudURL = "https://example.com/image.jpg"

        // When: Create GalleryItem with custom values
        let item = GalleryItem(
            asset: mockAsset,
            thumbnail: thumbnail,
            isSelected: isSelected,
            isSynced: isSynced,
            cloudURL: cloudURL
        )

        // Then: Should have correct custom values
        XCTAssertEqual(item.thumbnail, thumbnail, "Thumbnail should be set correctly")
        XCTAssertEqual(item.isSelected, isSelected, "Selection state should be set correctly")
        XCTAssertEqual(item.isSynced, isSynced, "Sync state should be set correctly")
        XCTAssertEqual(item.cloudURL, cloudURL, "Cloud URL should be set correctly")

        // Check sync status when isSynced is true
        switch item.syncStatus {
        case .uploaded:
            XCTAssertTrue(true, "Sync status should be uploaded when isSynced is true")
        default:
            XCTFail("Sync status should be uploaded when isSynced is true")
        }
    }

    // MARK: - Selection Tests

    func testToggleSelection() {
        // Given: GalleryItem not selected
        var item = GalleryItem(asset: mockAsset, isSelected: false)
        XCTAssertFalse(item.isSelected, "Precondition: Item should not be selected")

        // When: Toggle selection
        item.toggleSelection()

        // Then: Item should be selected
        XCTAssertTrue(item.isSelected, "Item should be selected after toggle")

        // When: Toggle again
        item.toggleSelection()

        // Then: Item should not be selected
        XCTAssertFalse(item.isSelected, "Item should not be selected after second toggle")
    }

    func testToggleSelectionFromSelected() {
        // Given: GalleryItem already selected
        var item = GalleryItem(asset: mockAsset, isSelected: true)
        XCTAssertTrue(item.isSelected, "Precondition: Item should be selected")

        // When: Toggle selection
        item.toggleSelection()

        // Then: Item should not be selected
        XCTAssertFalse(item.isSelected, "Item should not be selected after toggle")
    }

    // MARK: - Sync Status Tests

    func testUpdateSyncStatusToNotSynced() {
        // Given: GalleryItem with uploaded status
        var item = GalleryItem(asset: mockAsset, isSynced: true)

        // When: Update sync status to notSynced
        item.updateSyncStatus(.notSynced)

        // Then: Should have correct state
        switch item.syncStatus {
        case .notSynced:
            XCTAssertTrue(true, "Sync status should be notSynced")
        default:
            XCTFail("Sync status should be notSynced")
        }
        XCTAssertFalse(item.isSynced, "isSynced should be false")
    }

    func testUpdateSyncStatusToUploading() {
        // Given: GalleryItem with default status
        var item = GalleryItem(asset: mockAsset)

        // When: Update sync status to uploading
        item.updateSyncStatus(.uploading)

        // Then: Should have correct state
        switch item.syncStatus {
        case .uploading:
            XCTAssertTrue(true, "Sync status should be uploading")
        default:
            XCTFail("Sync status should be uploading")
        }
        XCTAssertFalse(item.isSynced, "isSynced should be false during upload")
    }

    func testUpdateSyncStatusToUploaded() {
        // Given: GalleryItem with uploading status
        var item = GalleryItem(asset: mockAsset)
        item.updateSyncStatus(.uploading)

        // When: Update sync status to uploaded
        item.updateSyncStatus(.uploaded)

        // Then: Should have correct state
        switch item.syncStatus {
        case .uploaded:
            XCTAssertTrue(true, "Sync status should be uploaded")
        default:
            XCTFail("Sync status should be uploaded")
        }
        XCTAssertTrue(item.isSynced, "isSynced should be true when uploaded")
    }

    func testUpdateSyncStatusToDownloading() {
        // Given: GalleryItem with default status
        var item = GalleryItem(asset: mockAsset)

        // When: Update sync status to downloading
        item.updateSyncStatus(.downloading)

        // Then: Should have correct state
        switch item.syncStatus {
        case .downloading:
            XCTAssertTrue(true, "Sync status should be downloading")
        default:
            XCTFail("Sync status should be downloading")
        }
        XCTAssertFalse(item.isSynced, "isSynced should be false during download")
    }

    func testUpdateSyncStatusToFailed() {
        // Given: GalleryItem with uploading status
        var item = GalleryItem(asset: mockAsset)
        item.updateSyncStatus(.uploading)
        let testError = NSError(domain: "TestError", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test error"])

        // When: Update sync status to failed
        item.updateSyncStatus(.failed(testError))

        // Then: Should have correct state
        switch item.syncStatus {
        case .failed(let error):
            XCTAssertEqual((error as NSError).domain, "TestError", "Should preserve error domain")
            XCTAssertEqual((error as NSError).code, 123, "Should preserve error code")
        default:
            XCTFail("Sync status should be failed")
        }
        XCTAssertFalse(item.isSynced, "isSynced should be false when failed")
    }

    // MARK: - Sync Status Transitions

    func testSyncStatusTransitionSequence() {
        // Given: GalleryItem with default status
        var item = GalleryItem(asset: mockAsset)

        // Verify initial state
        switch item.syncStatus {
        case .notSynced:
            XCTAssertTrue(true, "Should start as notSynced")
        default:
            XCTFail("Should start as notSynced")
        }
        XCTAssertFalse(item.isSynced, "Should not be synced initially")

        // When: Transition to uploading
        item.updateSyncStatus(.uploading)
        XCTAssertFalse(item.isSynced, "Should not be synced while uploading")

        // When: Transition to uploaded
        item.updateSyncStatus(.uploaded)
        XCTAssertTrue(item.isSynced, "Should be synced when uploaded")

        // When: Transition back to notSynced
        item.updateSyncStatus(.notSynced)
        XCTAssertFalse(item.isSynced, "Should not be synced when reset")
    }

    // MARK: - Edge Cases

    func testMultipleSelectionToggles() {
        // Given: GalleryItem
        var item = GalleryItem(asset: mockAsset, isSelected: false)

        // When: Toggle multiple times
        for i in 1...10 {
            item.toggleSelection()

            // Then: Selection state should alternate correctly
            let expectedState = i % 2 == 1
            XCTAssertEqual(item.isSelected, expectedState, "Selection state should be correct after \\(i) toggles")
        }
    }

    func testSyncStatusWithErrorMessage() {
        // Given: GalleryItem and specific error
        var item = GalleryItem(asset: mockAsset)
        let customError = NSError(
            domain: "CloudSync",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "File not found"]
        )

        // When: Update to failed status with custom error
        item.updateSyncStatus(.failed(customError))

        // Then: Should preserve error details
        switch item.syncStatus {
        case .failed(let error):
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "CloudSync", "Should preserve error domain")
            XCTAssertEqual(nsError.code, 404, "Should preserve error code")
            XCTAssertEqual(nsError.localizedDescription, "File not found", "Should preserve error message")
        default:
            XCTFail("Should be in failed state")
        }
    }

    func testImmutablePropertiesAfterInit() {
        // Given: GalleryItem
        let item = GalleryItem(asset: mockAsset)

        // Then: Immutable properties should remain consistent
        XCTAssertEqual(item.id, mockAsset.localIdentifier, "ID should remain consistent")
        XCTAssertEqual(item.asset.localIdentifier, mockAsset.localIdentifier, "Asset should remain consistent")
        XCTAssertEqual(item.creationDate, mockAsset.creationDate, "Creation date should remain consistent")
        XCTAssertEqual(item.mediaType, mockAsset.mediaType, "Media type should remain consistent")
    }
}
import XCTest
import Photos
import Combine
@testable import GallerySync

class GalleryViewModelTests: XCTestCase {

    var viewModel: GalleryViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = GalleryViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Selection Mode Tests

    func testToggleSelectionMode() {
        // Given: Initial state
        XCTAssertFalse(viewModel.isSelectionMode, "Initial selection mode should be false")

        // When: Toggle selection mode
        viewModel.toggleSelectionMode()

        // Then: Selection mode should be enabled
        XCTAssertTrue(viewModel.isSelectionMode, "Selection mode should be enabled after toggle")

        // When: Toggle again
        viewModel.toggleSelectionMode()

        // Then: Selection mode should be disabled
        XCTAssertFalse(viewModel.isSelectionMode, "Selection mode should be disabled after second toggle")
    }

    func testExitSelectionMode() {
        // Given: Selection mode is enabled
        viewModel.toggleSelectionMode()
        XCTAssertTrue(viewModel.isSelectionMode, "Precondition: Selection mode should be enabled")

        // When: Exit selection mode
        viewModel.exitSelectionMode()

        // Then: Selection mode should be disabled
        XCTAssertFalse(viewModel.isSelectionMode, "Selection mode should be disabled after exit")
    }

    func testSelectionModePublisher() {
        // Given: Expectation for publisher
        let expectation = XCTestExpectation(description: "Selection mode publisher should emit values")
        var receivedValues: [Bool] = []

        // When: Subscribe to selection mode publisher
        viewModel.$isSelectionMode
            .sink { value in
                receivedValues.append(value)
                if receivedValues.count == 3 { // Initial + 2 toggles
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Toggle selection mode twice
        viewModel.toggleSelectionMode()
        viewModel.toggleSelectionMode()

        // Then: Should receive correct sequence of values
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedValues, [false, true, false], "Should receive correct sequence of selection mode values")
    }

    func testItemSelectionToggle() {
        // Given: Mock gallery items
        let mockAsset = PHAsset()
        let mockItems = [
            GalleryItem(asset: mockAsset, isSelected: false),
            GalleryItem(asset: mockAsset, isSelected: false)
        ]
        viewModel.galleryItems = mockItems

        // When: Toggle item selection
        viewModel.toggleItemSelection(at: 0)

        // Then: Item should be selected and count updated
        XCTAssertTrue(viewModel.galleryItems[0].isSelected, "First item should be selected")
        XCTAssertFalse(viewModel.galleryItems[1].isSelected, "Second item should remain unselected")
        XCTAssertEqual(viewModel.selectedItemsCount, 1, "Selected items count should be 1")

        // When: Toggle same item again
        viewModel.toggleItemSelection(at: 0)

        // Then: Item should be deselected
        XCTAssertFalse(viewModel.galleryItems[0].isSelected, "First item should be deselected")
        XCTAssertEqual(viewModel.selectedItemsCount, 0, "Selected items count should be 0")
    }

    func testSelectAllItems() {
        // Given: Mock gallery items
        let mockAsset = PHAsset()
        let mockItems = [
            GalleryItem(asset: mockAsset, isSelected: false),
            GalleryItem(asset: mockAsset, isSelected: false),
            GalleryItem(asset: mockAsset, isSelected: true)
        ]
        viewModel.galleryItems = mockItems

        // When: Select all items
        viewModel.selectAllItems()

        // Then: All items should be selected
        XCTAssertTrue(viewModel.galleryItems[0].isSelected, "First item should be selected")
        XCTAssertTrue(viewModel.galleryItems[1].isSelected, "Second item should be selected")
        XCTAssertTrue(viewModel.galleryItems[2].isSelected, "Third item should remain selected")
        XCTAssertEqual(viewModel.selectedItemsCount, 3, "All items should be selected")
    }

    func testSelectedItemsCountPublisher() {
        // Given: Mock gallery items and expectation
        let mockAsset = PHAsset()
        let mockItems = [
            GalleryItem(asset: mockAsset, isSelected: false),
            GalleryItem(asset: mockAsset, isSelected: false)
        ]
        viewModel.galleryItems = mockItems

        let expectation = XCTestExpectation(description: "Selected items count should update")
        var receivedCounts: [Int] = []

        // When: Subscribe to count publisher
        viewModel.$selectedItemsCount
            .sink { count in
                receivedCounts.append(count)
                if receivedCounts.count == 3 { // Initial + 2 selections
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Select items
        viewModel.toggleItemSelection(at: 0)
        viewModel.toggleItemSelection(at: 1)

        // Then: Should receive correct count updates
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedCounts, [0, 1, 2], "Should receive correct selected items count sequence")
    }

    // MARK: - Upload Tests

    func testUploadAllItemsWithNonSyncedItems() {
        // Given: Mix of synced and non-synced items
        let mockAsset = PHAsset()
        let mockItems = [
            GalleryItem(asset: mockAsset, isSelected: false, isSynced: false),
            GalleryItem(asset: mockAsset, isSelected: false, isSynced: true),
            GalleryItem(asset: mockAsset, isSelected: false, isSynced: false)
        ]
        viewModel.galleryItems = mockItems

        // When: Upload all items
        let expectation = XCTestExpectation(description: "Upload should start loading")

        viewModel.$isLoading
            .dropFirst() // Skip initial false value
            .sink { isLoading in
                if isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.uploadAllItems()

        // Then: Should start upload process for non-synced items only
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.isLoading, "Should be loading during upload")
    }

    func testUploadSelectedItems() {
        // Given: Selected and unselected items
        let mockAsset = PHAsset()
        let mockItems = [
            GalleryItem(asset: mockAsset, isSelected: true, isSynced: false),
            GalleryItem(asset: mockAsset, isSelected: false, isSynced: false),
            GalleryItem(asset: mockAsset, isSelected: true, isSynced: false)
        ]
        viewModel.galleryItems = mockItems
        viewModel.isSelectionMode = true

        // When: Upload selected items
        let expectation = XCTestExpectation(description: "Upload should start and exit selection mode")

        var loadingStates: [Bool] = []
        var selectionModes: [Bool] = []

        viewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
            }
            .store(in: &cancellables)

        viewModel.$isSelectionMode
            .dropFirst() // Skip initial value
            .sink { isSelectionMode in
                selectionModes.append(isSelectionMode)
                if selectionModes.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.uploadSelectedItems()

        // Then: Should start upload and exit selection mode
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isSelectionMode, "Should exit selection mode after upload")
    }

    func testUploadItemsWithEmptySelection() {
        // Given: No items selected
        let mockAsset = PHAsset()
        let mockItems = [
            GalleryItem(asset: mockAsset, isSelected: false, isSynced: false)
        ]
        viewModel.galleryItems = mockItems

        // When: Upload selected items (none selected)
        viewModel.uploadSelectedItems()

        // Then: Should exit selection mode without starting upload
        XCTAssertFalse(viewModel.isSelectionMode, "Should exit selection mode")
        XCTAssertFalse(viewModel.isLoading, "Should not start loading for empty selection")
    }

    // MARK: - Download Tests

    func testDownloadFromCloud() {
        // Given: Initial state
        XCTAssertFalse(viewModel.isLoading, "Should not be loading initially")

        // When: Start download
        let expectation = XCTestExpectation(description: "Download should start loading")

        viewModel.$isLoading
            .dropFirst() // Skip initial false value
            .sink { isLoading in
                if isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.downloadFromCloud()

        // Then: Should start loading
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.isLoading, "Should be loading during download")
    }

    // MARK: - Error Handling Tests

    func testErrorStatePublisher() {
        // Given: Error expectation
        let expectation = XCTestExpectation(description: "Error should be published")

        viewModel.$error
            .compactMap { $0 } // Filter out nil values
            .sink { error in
                XCTAssertEqual(error, "Test error", "Should receive test error message")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When: Set error
        viewModel.error = "Test error"

        // Then: Error should be published
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Edge Cases

    func testToggleItemSelectionWithInvalidIndex() {
        // Given: Empty gallery items
        viewModel.galleryItems = []

        // When: Try to toggle item at invalid index
        viewModel.toggleItemSelection(at: 0)

        // Then: Should not crash and count should remain 0
        XCTAssertEqual(viewModel.selectedItemsCount, 0, "Selected count should remain 0 for invalid index")
    }

    func testSelectionModeBehaviorConsistency() {
        // Given: Items with mixed selection states
        let mockAsset = PHAsset()
        let mockItems = [
            GalleryItem(asset: mockAsset, isSelected: true, isSynced: false),
            GalleryItem(asset: mockAsset, isSelected: false, isSynced: false)
        ]
        viewModel.galleryItems = mockItems
        viewModel.isSelectionMode = true

        // When: Exit selection mode
        viewModel.exitSelectionMode()

        // Then: All selections should be cleared
        XCTAssertFalse(viewModel.galleryItems[0].isSelected, "First item should be deselected")
        XCTAssertFalse(viewModel.galleryItems[1].isSelected, "Second item should remain deselected")
        XCTAssertEqual(viewModel.selectedItemsCount, 0, "Selected count should be 0")
        XCTAssertFalse(viewModel.isSelectionMode, "Selection mode should be disabled")
    }
}
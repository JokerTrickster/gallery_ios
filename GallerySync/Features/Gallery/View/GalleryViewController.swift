import UIKit
import Combine

class GalleryViewController: UIViewController {

    weak var coordinator: GalleryCoordinator?
    private let viewModel: GalleryViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: "GalleryCell")
        return collectionView
    }()

    private lazy var selectButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectButtonTapped))
    }()

    private lazy var uploadButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(uploadButtonTapped))
    }()

    private lazy var downloadButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(downloadButtonTapped))
    }()

    private lazy var syncButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Sync", style: .plain, target: self, action: #selector(syncButtonTapped))
    }()

    private lazy var settingsButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsButtonTapped))
    }()

    private lazy var cancelButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
    }()

    private lazy var selectAllButton: UIBarButtonItem = {
        UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectAllButtonTapped))
    }()

    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.isHidden = true
        return toolbar
    }()

    private var isSelectionMode = false

    init(viewModel: GalleryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    private func setupUI() {
        title = "Gallery"
        view.backgroundColor = .systemBackground

        navigationItem.rightBarButtonItems = [settingsButton, downloadButton, uploadButton, selectButton]

        view.addSubview(toolbar)
        updateToolbarItems()

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),

            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$galleryItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateButtonStates(isLoading: isLoading)
            }
            .store(in: &cancellables)

        viewModel.$isSelectionMode
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSelectionMode in
                self?.updateSelectionMode(isSelectionMode)
            }
            .store(in: &cancellables)

        viewModel.$selectedItemsCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.updateToolbarItems(selectedCount: count)
            }
            .store(in: &cancellables)
    }

    private func updateButtonStates(isLoading: Bool) {
        uploadButton.isEnabled = !isLoading
        downloadButton.isEnabled = !isLoading
        selectButton.isEnabled = !isLoading
        syncButton.isEnabled = !isLoading
    }

    private func updateSelectionMode(_ isSelectionMode: Bool) {
        self.isSelectionMode = isSelectionMode

        if isSelectionMode {
            navigationItem.leftBarButtonItem = cancelButton
            navigationItem.rightBarButtonItems = [selectAllButton]
            toolbar.isHidden = false
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItems = [settingsButton, downloadButton, uploadButton, selectButton]
            toolbar.isHidden = true
        }

        collectionView.allowsMultipleSelection = isSelectionMode
        collectionView.reloadData()
    }

    private func updateToolbarItems(selectedCount: Int = 0) {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let selectedLabel = UIBarButtonItem(title: "\(selectedCount) Selected", style: .plain, target: nil, action: nil)
        selectedLabel.isEnabled = false

        let uploadSelectedButton = UIBarButtonItem(title: "Upload Selected", style: .plain, target: self, action: #selector(uploadSelectedButtonTapped))
        uploadSelectedButton.isEnabled = selectedCount > 0

        toolbar.setItems([selectedLabel, flexibleSpace, uploadSelectedButton], animated: false)
    }

    @objc private func selectButtonTapped() {
        viewModel.toggleSelectionMode()
    }

    @objc private func cancelButtonTapped() {
        viewModel.exitSelectionMode()
    }

    @objc private func selectAllButtonTapped() {
        viewModel.selectAllItems()
        collectionView.reloadData()
    }

    @objc private func uploadButtonTapped() {
        viewModel.uploadAllItems()
    }

    @objc private func uploadSelectedButtonTapped() {
        viewModel.uploadSelectedItems()
    }

    @objc private func downloadButtonTapped() {
        viewModel.downloadFromCloud()
    }

    @objc private func syncButtonTapped() {
        coordinator?.showCloudSync()
    }

    @objc private func settingsButtonTapped() {
        coordinator?.showSettings()
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.galleryItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        let item = viewModel.galleryItems[indexPath.item]
        cell.configure(with: item, isSelectionMode: isSelectionMode)
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelectionMode {
            viewModel.toggleItemSelection(at: indexPath.item)
            collectionView.reloadItems(at: [indexPath])
        } else {
            let item = viewModel.galleryItems[indexPath.item]
            // Handle item preview/detail view
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        if isSelectionMode {
            viewModel.toggleItemSelection(at: indexPath.item)
            collectionView.reloadItems(at: [indexPath])
        }
        return !isSelectionMode
    }
}
import UIKit
import Combine

class GalleryViewController: UIViewController {

    weak var coordinator: GalleryCoordinator?
    private let viewModel: GalleryViewModel
    private var cancellables = Set<AnyCancellable>()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 2
        let itemsPerRow: CGFloat = 3
        let totalSpacing = spacing * (itemsPerRow + 1)
        let itemWidth = (UIScreen.main.bounds.width - totalSpacing) / itemsPerRow

        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GalleryCell.self, forCellWithReuseIdentifier: "GalleryCell")
        return collectionView
    }()

    private lazy var uploadButton: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "icloud.and.arrow.up"), style: .plain, target: self, action: #selector(uploadButtonTapped))
    }()

    private lazy var downloadButton: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "icloud.and.arrow.down"), style: .plain, target: self, action: #selector(downloadButtonTapped))
    }()

    private lazy var settingsButton: UIBarButtonItem = {
        UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(settingsButtonTapped))
    }()

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

        navigationItem.rightBarButtonItems = [settingsButton, downloadButton, uploadButton]

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
    }

    private func updateButtonStates(isLoading: Bool) {
        uploadButton.isEnabled = !isLoading
        downloadButton.isEnabled = !isLoading
    }

    @objc private func uploadButtonTapped() {
        viewModel.uploadAllItems()
    }

    @objc private func downloadButtonTapped() {
        viewModel.downloadFromCloud()
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
        cell.configure(with: item)
        return cell
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
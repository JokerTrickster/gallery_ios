import UIKit
import Photos

class GalleryCell: UICollectionViewCell {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        return imageView
    }()

    private let syncStatusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 6
        view.isHidden = true
        return view
    }()

    private let progressIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(syncStatusView)
        contentView.addSubview(progressIndicator)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            syncStatusView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            syncStatusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            syncStatusView.widthAnchor.constraint(equalToConstant: 8),
            syncStatusView.heightAnchor.constraint(equalToConstant: 8),

            progressIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with item: GalleryItem) {
        updateSyncStatus(item.syncStatus)

        if let thumbnail = item.thumbnail {
            imageView.image = thumbnail
        } else {
            loadThumbnail(for: item.asset)
        }
    }

    private func updateSyncStatus(_ status: GalleryItem.SyncStatus) {
        progressIndicator.stopAnimating()

        switch status {
        case .notSynced:
            syncStatusView.isHidden = true
        case .uploading, .downloading:
            syncStatusView.isHidden = true
            progressIndicator.startAnimating()
        case .uploaded:
            syncStatusView.isHidden = false
            syncStatusView.backgroundColor = .systemGreen
        case .failed:
            syncStatusView.isHidden = false
            syncStatusView.backgroundColor = .systemRed
        }
    }

    private func loadThumbnail(for asset: PHAsset) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .opportunistic

        manager.requestImage(
            for: asset,
            targetSize: CGSize(width: 100, height: 100),
            contentMode: .aspectFill,
            options: options
        ) { [weak self] image, _ in
            DispatchQueue.main.async {
                self?.imageView.image = image
            }
        }
    }
}
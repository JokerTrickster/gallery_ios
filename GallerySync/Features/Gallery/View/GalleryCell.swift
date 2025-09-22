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

    private let selectionIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        view.isHidden = true
        return view
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
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
        contentView.addSubview(selectionIndicator)
        contentView.addSubview(progressIndicator)
        selectionIndicator.addSubview(checkmarkImageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            syncStatusView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            syncStatusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            syncStatusView.widthAnchor.constraint(equalToConstant: 12),
            syncStatusView.heightAnchor.constraint(equalToConstant: 12),

            selectionIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            selectionIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            selectionIndicator.widthAnchor.constraint(equalToConstant: 24),
            selectionIndicator.heightAnchor.constraint(equalToConstant: 24),

            checkmarkImageView.centerXAnchor.constraint(equalTo: selectionIndicator.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: selectionIndicator.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 16),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 16),

            progressIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            progressIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with item: GalleryItem, isSelectionMode: Bool = false) {
        // Update sync status
        updateSyncStatus(item.syncStatus)

        // Update selection state
        selectionIndicator.isHidden = !isSelectionMode
        if isSelectionMode {
            if item.isSelected {
                selectionIndicator.backgroundColor = .systemBlue
                checkmarkImageView.isHidden = false
            } else {
                selectionIndicator.backgroundColor = .clear
                selectionIndicator.layer.borderColor = UIColor.white.cgColor
                checkmarkImageView.isHidden = true
            }
        }

        // Add selection overlay
        if isSelectionMode && !item.isSelected {
            imageView.alpha = 0.7
        } else {
            imageView.alpha = 1.0
        }

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
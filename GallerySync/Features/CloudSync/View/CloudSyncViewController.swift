import UIKit
import Combine

class CloudSyncViewController: UIViewController {

    weak var coordinator: CloudSyncCoordinator?
    private let viewModel: CloudSyncViewModel
    private var cancellables = Set<AnyCancellable>()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()

    private let syncButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start Sync", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private let lastSyncLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()

    init(viewModel: CloudSyncViewModel) {
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
        title = "Cloud Sync"
        view.backgroundColor = .systemBackground

        view.addSubview(statusLabel)
        view.addSubview(progressView)
        view.addSubview(syncButton)
        view.addSubview(lastSyncLabel)

        syncButton.addTarget(self, action: #selector(syncButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),

            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            syncButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 40),
            syncButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            syncButton.widthAnchor.constraint(equalToConstant: 120),
            syncButton.heightAnchor.constraint(equalToConstant: 44),

            lastSyncLabel.topAnchor.constraint(equalTo: syncButton.bottomAnchor, constant: 20),
            lastSyncLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$syncStatus
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: statusLabel)
            .store(in: &cancellables)

        viewModel.$syncProgress
            .receive(on: DispatchQueue.main)
            .assign(to: \.progress, on: progressView)
            .store(in: &cancellables)

        viewModel.$isSyncing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSyncing in
                self?.syncButton.setTitle(isSyncing ? "Stop Sync" : "Start Sync", for: .normal)
                self?.syncButton.backgroundColor = isSyncing ? .systemRed : .systemBlue
            }
            .store(in: &cancellables)

        viewModel.$lastSyncDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                if let date = date {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    self?.lastSyncLabel.text = "Last sync: \(formatter.string(from: date))"
                } else {
                    self?.lastSyncLabel.text = "Never synced"
                }
            }
            .store(in: &cancellables)
    }

    @objc private func syncButtonTapped() {
        if viewModel.isSyncing {
            viewModel.stopSync()
        } else {
            viewModel.startSync()
        }
    }
}
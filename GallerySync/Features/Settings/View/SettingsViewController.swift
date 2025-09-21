import UIKit
import Combine

class SettingsViewController: UIViewController {

    weak var coordinator: SettingsCoordinator?
    private let viewModel: SettingsViewModel
    private var cancellables = Set<AnyCancellable>()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    init(viewModel: SettingsViewModel) {
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
        title = "Settings"
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$autoSyncEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$storageUsed
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2 // Sync settings
        case 1: return 2 // Account
        case 2: return 1 // Storage
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Sync Settings"
        case 1: return "Account"
        case 2: return "Storage"
        default: return nil
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")

        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Auto Sync"
                let switchControl = UISwitch()
                switchControl.isOn = viewModel.autoSyncEnabled
                switchControl.addTarget(self, action: #selector(autoSyncToggled(_:)), for: .valueChanged)
                cell.accessoryView = switchControl
            } else {
                cell.textLabel?.text = "Sync Quality"
                cell.detailTextLabel?.text = viewModel.syncQuality.rawValue
                cell.accessoryType = .disclosureIndicator
            }
        case 1:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Account Status"
                cell.detailTextLabel?.text = viewModel.accountStatus
            } else {
                cell.textLabel?.text = "Sign Out"
                cell.textLabel?.textColor = .systemRed
            }
        case 2:
            cell.textLabel?.text = "Clear Cache"
            cell.detailTextLabel?.text = viewModel.storageUsed
        default:
            break
        }

        return cell
    }

    @objc private func autoSyncToggled(_ sender: UISwitch) {
        viewModel.autoSyncEnabled = sender.isOn
        viewModel.saveSettings()
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 && indexPath.row == 1 {
            // Sign out
            viewModel.signOut()
        } else if indexPath.section == 2 {
            // Clear cache
            viewModel.clearCache()
        }
    }
}
//
//  ActionSheetViewController.swift
//  CustomActionSheet
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit
import Combine

final class ActionSheetViewController: UIViewController {

    // MARK: - Defaults
    private enum Defaults {

        enum TitleLabel {
            static let top: CGFloat = 32
            static let horizontal: CGFloat = 16
        }

        enum TableView {
            static let top: CGFloat = 8
            static let cellHeight: CGFloat = 72
            static let bottom: CGFloat = 16
            static let enableScrollCount = 6
        }

        // action sheet default max height
        static let maxHeight: CGFloat = 500

        static let fontTitle: UIFont = .systemFont(ofSize: 20, weight: .heavy)
        static let fontDescription: UIFont = .systemFont(ofSize: 14, weight: .medium)
    }

    // MARK: - Properties

    var numberOfItems = 0

    // MARK: - Private properties
    private lazy var dataSource = ActionSheetDataSource(tableView: tableView)
    private var viewModel: ActionSheetViewModelProtocol?

    private let onLoad = PassthroughSubject<Void, Never>()
    private let onDismissSubj = PassthroughSubject<Void, Never>()
    private let onItemSubj = PassthroughSubject<Int, Never>()
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Subviews
    private let titleLabel: UILabel = {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.numberOfLines = .zero
        $0.text = "Select Breed"
        return $0
    }(UILabel())

    private let tableView = UITableView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
        onLoad.send(())
        setup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismissSubj.send()
    }
}

// MARK: - Internal methods
extension ActionSheetViewController {

    func setDependencies(viewModel: ActionSheetViewModelProtocol) {
        self.viewModel = viewModel
    }
}

// MARK: - Bind
private extension ActionSheetViewController {

    func bind(to viewModel: ActionSheetViewModelProtocol?) {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()

        let input = ActionSheet.Models.ViewModelInput(
            onLoad: onLoad.eraseToAnyPublisher(),
            onDismiss: onDismissSubj.eraseToAnyPublisher(),
            onItem: onItemSubj.eraseToAnyPublisher()
        )
        viewModel?.process(input: input)

        viewModel?.viewState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                self?.render(state)
            }).store(in: &subscriptions)

        viewModel?.route
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] route in
                self?.handleRoute(route)
            }).store(in: &subscriptions)
    }

    func render(_ state: ActionSheet.Models.ViewState) {
        switch state {
        case .idle:
            updateSnapshot([], animated: false)
        case let .plain(items):
            updateSnapshot(items, animated: false)
        }
    }

    func handleRoute(_ route: ActionSheet.Models.ViewRoute) {
        switch route {
        case .dismiss:
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - DataSource
private extension ActionSheetViewController {

    func updateSnapshot(_ items: [ActionSheet.Models.Item], animated: Bool = true) {
        numberOfItems = items.count
        tableView.isScrollEnabled = numberOfItems >= Defaults.TableView.enableScrollCount
        dataSource.updateSnapshot(items, animated: animated)
    }
}

// MARK: - Private
private extension ActionSheetViewController {

    func setup() {
        tableView.separatorStyle = .none
        tableView.delegate = self

        view.add(views: [titleLabel, tableView],
                 with: titleConstraints + tableViewConstraints)

        view.backgroundColor = .systemBackground
    }
}

// MARK: - Constraints
private extension ActionSheetViewController {

    var titleConstraints: [NSLayoutConstraint] {
        [
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: Defaults.TitleLabel.top),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Defaults.TitleLabel.horizontal),
            view.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Defaults.TitleLabel.horizontal)
        ]
    }

    var tableViewConstraints: [NSLayoutConstraint] {
        [
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Defaults.TableView.top),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
    }
}

// MARK: - PanModalPresentable
extension ActionSheetViewController: PanModalPresentable {

    var longFormHeight: PanModalHeight {
        let insets: CGFloat = Defaults.TitleLabel.top + Defaults.TableView.top + Defaults.TableView.bottom + CGFloat.safeAreaBottom
        let titleWidth: CGFloat = CGFloat.appWidth - 2 * Defaults.TitleLabel.horizontal
        var heights: CGFloat = .zero
        heights += titleLabel.text?.height(withConstrainedWidth: titleWidth, font: Defaults.fontTitle) ?? .zero
        heights += Defaults.TableView.cellHeight * CGFloat(numberOfItems)
        let height = insets + heights
        return PanModalHeight.contentHeightIgnoringSafeArea(
            height > Defaults.maxHeight ? Defaults.maxHeight : height
        )
    }
}

// MARK: - UITableViewDelegate
extension ActionSheetViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .zero
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Defaults.TableView.cellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onItemSubj.send(indexPath.row)
    }
}

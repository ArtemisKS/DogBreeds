//
//  BreedViewController.swift
//  Breeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit
import Combine

final class BreedViewController: BaseViewController, ErrorStateView {

    // MARK: - Defaults
    private enum Defaults {

        enum TitleLabel {
            static let top: CGFloat = 16
            static let horizontal: CGFloat = 16
        }

        enum BreedsFilterButton {
            static let height: CGFloat = 36
            static let cornerRadius: CGFloat = 8
            static let horizontal: CGFloat = 16
        }

        enum CollectionView {
            static let cellHeight: CGFloat = 72
            static let bottom: CGFloat = 16
            static let enableScrollCount = 5
            static func top(_ isFilterVisible: Bool) -> CGFloat {
                isFilterVisible ? 24 : 16
            }
        }

        enum ErrorView {
            static let horizontalInset: CGFloat = 24
        }

        static let maxHeight: CGFloat = 400

        static let fontTitle: UIFont = .systemFont(ofSize: 20, weight: .heavy)
        static let fontDescription: UIFont = .systemFont(ofSize: 14, weight: .medium)
    }

    struct Config {
        let title: String
        let isFilterVisible: Bool
        let shouldRemoveItemOnTap: Bool
    }

    // MARK: - Properties
    private lazy var dataSource = BreedDataSource(collectionView: collectionView)
    private var viewModel: BreedViewModelProtocol?
    private var config: Config

    private let onLoad = PassthroughSubject<Void, Never>()
    private let onDismissSubj = PassthroughSubject<Void, Never>()
    private let onItemSubj = PassthroughSubject<Breed.Models.OnItemTapData, Never>()
    private let onUpdateCollectionSubj = PassthroughSubject<String, Never>()
    private let onFilterTappedSubj = PassthroughSubject<Void, Never>()
    private let onRetryTappedSubj = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()

    private var numberOfItems = 0

    // MARK: - Subviews
    private lazy var titleLabel: UILabel = {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.numberOfLines = .zero
        $0.text = config.title
        return $0
    }(UILabel())

    private lazy var breedsFilterButton: BreedsFilterButton = {
        $0.setTitle("Filter by breed", for: .normal)
        $0.backColor = .carolinaBlue
        $0.isHidden = !config.isFilterVisible
        $0.round(with: Defaults.BreedsFilterButton.cornerRadius)
        $0.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return $0
    }(BreedsFilterButton())

    private let collectionView: UICollectionView = {
        $0.showsVerticalScrollIndicator = false
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: .init()))

    private lazy var _errorView: ErrorView = {
        $0.isHidden = true
        $0.retryAction = { [weak self] in
            self?.onRetryTapped()
        }
        return $0
    }(ErrorView())

    // MARK: - Properties
    var errorView: ErrorView {
        _errorView
    }

    var nonErrorViews: [UIView] {
        [titleLabel, breedsFilterButton, collectionView]
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
        onLoad.send()
        setup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onDismissSubj.send()
    }

    init(config: Config) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Internal methods
extension BreedViewController {

    func setDependencies(viewModel: BreedViewModelProtocol) {
        self.viewModel = viewModel
    }
}

// MARK: - Bind
private extension BreedViewController {

    func bind(to viewModel: BreedViewModelProtocol?) {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()

        let input = Breed.Models.ViewModelInput(
            onLoad: onLoad.eraseToAnyPublisher(),
            onDismiss: onDismissSubj.eraseToAnyPublisher(),
            onItem: onItemSubj.eraseToAnyPublisher(),
            onUpdateCollectionSubj: onUpdateCollectionSubj.eraseToAnyPublisher(),
            onFilterTapped: onFilterTappedSubj.eraseToAnyPublisher(),
            onRetryTapped: onRetryTappedSubj.eraseToAnyPublisher()
        )
        viewModel?.process(input: input)

        viewModel?.viewState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] state in
                self?.render(state)
            }).store(in: &subscriptions)

        viewModel?.viewAction
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] action in
                self?.handleAction(action)
            }).store(in: &subscriptions)

        viewModel?.route
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] route in
                self?.handleRoute(route)
            }).store(in: &subscriptions)
    }

    func render(_ state: Breed.Models.ViewState) {
        switch state {
        case .loading:
            setLoading(true)
        case let .error(message):
            setLoading(false)
            setViews(hidden: true, errorViewHidden: false)
            errorView.state = .init(text: message)
        case let .plain(items):
            setLoading(false)
            setViews(hidden: false, errorViewHidden: true)
            breedsFilterButton.isHidden = !config.isFilterVisible
            updateSnapshot(items, animated: false)
        }
    }

    func handleRoute(_ route: Breed.Models.ViewRoute) {
        switch route {
        case .dismiss:
            dismiss(animated: true, completion: nil)
        }
    }

    func handleAction(_ action: Breed.Models.ViewAction) {
        switch action {
        case let .setTitle(title):
            self.title = title
        case let .showError(message):
            showOkAlert(message: message, completion:  { [weak self] in
                self?.render(.error(message))
            })
        case let .showActionSheet(items):
            let actionSheetController = ActionSheet.Assembly.createModule(items: items.map { .init(text: $0.text, url: $0.url) }) { item in
                self.onUpdateCollectionSubj.send(item?.text ?? "")
            }
            presentPanModal(actionSheetController)
        }
    }
}

// MARK: - DataSource
private extension BreedViewController {

    func updateSnapshot(_ items: [Breed.Models.Item], animated: Bool = true) {
        numberOfItems = items.count
        collectionView.isScrollEnabled = numberOfItems >= Defaults.CollectionView.enableScrollCount
        dataSource.updateSnapshot(items, animated: animated)
    }
}

// MARK: - Private
private extension BreedViewController {

    func setup() {
        collectionView.delegate = self

        view.add(views: [titleLabel, breedsFilterButton, collectionView, errorView],
                 with: titleConstraints +
                 collectionViewConstraints +
                 breedsFilterButtonConstraints +
                 errorViewConstraints)

        view.backgroundColor = .systemBackground
    }

    @objc
    func filterButtonTapped() {
        onFilterTappedSubj.send()
    }

    func onRetryTapped() {
        onRetryTappedSubj.send()
    }
}

// MARK: - Constraints
private extension BreedViewController {

    var titleConstraints: [NSLayoutConstraint] {
        [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Defaults.TitleLabel.top),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Defaults.TitleLabel.horizontal),
            view.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Defaults.TitleLabel.horizontal)
        ]
    }

    var breedsFilterButtonConstraints: [NSLayoutConstraint] {
        [
            breedsFilterButton.heightAnchor.constraint(equalToConstant: Defaults.BreedsFilterButton.height),
            breedsFilterButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            breedsFilterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Defaults.BreedsFilterButton.horizontal)
        ]
    }

    var collectionViewConstraints: [NSLayoutConstraint] {
        [
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Defaults.CollectionView.top(config.isFilterVisible)),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
    }

    var errorViewConstraints: [NSLayoutConstraint] {
        [
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Defaults.ErrorView.horizontalInset),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Defaults.ErrorView.horizontalInset),
            errorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
    }
}

// MARK: - UICollectionViewDelegate
extension BreedViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if !config.shouldRemoveItemOnTap {
            (collectionView.cellForItem(at: indexPath) as? BreedCollectionViewCell)?.wasSelected.toggle()
        }
        onItemSubj.send(.init(
            index: indexPath.row,
            shouldRemoveItem: config.shouldRemoveItemOnTap
        ))
    }
}

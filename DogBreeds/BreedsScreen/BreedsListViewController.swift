//
//  BreedsListViewController.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit
import Combine

final class BreedsListViewController: BaseViewController {

    // MARK: - Defaults
    private enum Defaults {

        enum TitleLabel {
            static let top: CGFloat = 16
            static let horizontal: CGFloat = 16
        }

        enum BreedsFilterButton {
            static let size: CGSize = .init(width: 148, height: 36)
            static let cornerRadius: CGFloat = 8
            static let horizontal: CGFloat = 16
        }

        enum CollectionView {
            static let top: CGFloat = 8
            static let cellHeight: CGFloat = 72
            static let bottom: CGFloat = 16
            static let enableScrollCount = 5
        }

        enum ErrorView {
            static let horizontalInset: CGFloat = 24
        }

        static let maxHeight: CGFloat = 400

        static let fontTitle: UIFont = .systemFont(ofSize: 20, weight: .heavy)
        static let fontDescription: UIFont = .systemFont(ofSize: 14, weight: .medium)
    }

    // MARK: - Properties
    private lazy var dataSource = BreedsListDataSource(collectionView: collectionView)
    private var viewModel: BreedsListViewModelProtocol?

    private let onLoad = PassthroughSubject<Void, Never>()
    private let onItemSubj = PassthroughSubject<Int, Never>()
    private let onUpdateCollectionSubj = PassthroughSubject<String, Never>()
    private let onFavoritePicsTappedSubj = PassthroughSubject<Void, Never>()
    private let onRetryTappedSubj = PassthroughSubject<Void, Never>()
    private var subscriptions = Set<AnyCancellable>()

    private var numberOfItems = 0

    // MARK: - Subviews
    private lazy var titleLabel: UILabel = {
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.numberOfLines = .zero
        $0.text = "Dog breeds"
        return $0
    }(UILabel())

    private lazy var favoritePicsButton: CustomButton = {
        $0.setTitle("Favorite pics", for: .normal)
        $0.backColor = .carolinaBlue
        $0.round(with: Defaults.BreedsFilterButton.cornerRadius)
        $0.addTarget(self, action: #selector(favoritePicsButtonTapped), for: .touchUpInside)
        return $0
    }(CustomButton())

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
    override var errorView: ErrorView {
        _errorView
    }

    override var nonErrorViews: [UIView] {
        [titleLabel, favoritePicsButton, collectionView]
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
        onLoad.send(())
        setup()
    }
}

// MARK: - Internal methods
extension BreedsListViewController {

    func setDependencies(viewModel: BreedsListViewModelProtocol) {
        self.viewModel = viewModel
    }
}

// MARK: - Bind
private extension BreedsListViewController {

    func bind(to viewModel: BreedsListViewModelProtocol?) {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()

        let input = BreedsList.Models.ViewModelInput(
            onLoad: onLoad.eraseToAnyPublisher(),
            onItem: onItemSubj.eraseToAnyPublisher(),
            onUpdateCollectionSubj: onUpdateCollectionSubj.eraseToAnyPublisher(),
            onFavoritePicsTapped: onFavoritePicsTappedSubj.eraseToAnyPublisher(),
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

    func render(_ state: BreedsList.Models.ViewState) {
        switch state {
        case .loading:
            setLoading(true)
        case let .error(message):
            setLoading(false)
            setAllViews(hidden: true, errorViewHidden: false)
            errorView.state = .init(text: message)
        case let .plain(items):
            setLoading(false)
            setAllViews(hidden: false, errorViewHidden: true)
            updateSnapshot(items, animated: false)
        }
    }

    func handleRoute(_ route: BreedsList.Models.ViewRoute) {
        switch route {
        case .dismiss:
            dismiss(animated: true, completion: nil)
        }
    }

    func handleAction(_ action: BreedsList.Models.ViewAction) {
        switch action {
        case let .showError(message):
            showOkAlert(message: message, completion:  { [weak self] in
                self?.render(.error(message))
            })
        case let .moveToFavoritePicsScreen(diProvider), let .moveToBreedPicsScreen(_, diProvider):
            var breed: String?
            let config: BreedViewController.Config
            if case let .moveToBreedPicsScreen(item, _) = action {
                breed = item.text
                config = makeBreedPicsConfig()
            } else {
                config = makeFavoritePicsConfig()
            }
            let controller = Breed.Assembly.createModule(
                breed: breed,
                config: config,
                diProvider: diProvider
            ) { _ in
                // not needed for now, but would be nice for future functionality
            }
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: - DataSource
private extension BreedsListViewController {

    func updateSnapshot(_ items: [BreedsList.Models.Item], animated: Bool = true) {
        numberOfItems = items.count
        collectionView.isScrollEnabled = numberOfItems >= Defaults.CollectionView.enableScrollCount
        dataSource.updateSnapshot(items, animated: animated)
    }
}

// MARK: - Constraints
private extension BreedsListViewController {

    var titleConstraints: [NSLayoutConstraint] {
        [
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Defaults.TitleLabel.top),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Defaults.TitleLabel.horizontal),
            view.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: Defaults.TitleLabel.horizontal)
        ]
    }

    var favoritePicsButtonConstraints: [NSLayoutConstraint] {
        [
            favoritePicsButton.widthAnchor.constraint(equalToConstant: Defaults.BreedsFilterButton.size.width),
            favoritePicsButton.heightAnchor.constraint(equalToConstant: Defaults.BreedsFilterButton.size.height),
            favoritePicsButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            favoritePicsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Defaults.BreedsFilterButton.horizontal)
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

    var collectionViewConstraints: [NSLayoutConstraint] {
        [
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Defaults.CollectionView.top),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
    }
}

// MARK: - Private
private extension BreedsListViewController {

    func setup() {

        title = "Breeds"

        collectionView.delegate = self

        view.add(views: [titleLabel, favoritePicsButton, collectionView, errorView],
                 with: titleConstraints +
                 collectionViewConstraints +
                 favoritePicsButtonConstraints +
                 errorViewConstraints)

        view.backgroundColor = .systemBackground
    }

    @objc
    func favoritePicsButtonTapped() {
        onFavoritePicsTappedSubj.send()
    }

    func onRetryTapped() {
        onRetryTappedSubj.send()
    }

    func makeBreedPicsConfig() -> BreedViewController.Config {
        .init(title: "Breed pictures",
              isFilterVisible: false,
              shouldRemoveItemOnTap: false)
    }

    func makeFavoritePicsConfig() -> BreedViewController.Config {
        .init(title: "Favorite pictures",
              isFilterVisible: true,
              shouldRemoveItemOnTap: true)
    }
}

// MARK: - UICollectionViewDelegate
extension BreedsListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        onItemSubj.send(indexPath.row)
    }
}


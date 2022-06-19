//
//  BreedsListViewModel.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Combine
import UIKit

protocol BreedsListViewModelProtocol: AnyObject {
    var viewState: AnyPublisher<BreedsList.Models.ViewState, Never> { get }
    var viewAction: AnyPublisher<BreedsList.Models.ViewAction, Never> { get }
    var route: AnyPublisher<BreedsList.Models.ViewRoute, Never> { get }

    func process(input: BreedsList.Models.ViewModelInput)
}

final class BreedsListViewModel {

    // MARK: - Properties
    private let diProvider: DIProviderProtocol
    private var items: [BreedsList.Models.ItemModel] = []
    private var lastDisplayedItems: [BreedsList.Models.ItemModel] = []
    private var selectedItems: [BreedsList.Models.ItemModel] = []
    private var requestQueue: Queue<ActionHandler> = .init()

    private let viewStateSubj = CurrentValueSubject<BreedsList.Models.ViewState, Never>(.loading)
    private let viewActionSubj = PassthroughSubject<BreedsList.Models.ViewAction, Never>()
    private let routeSubj = PassthroughSubject<BreedsList.Models.ViewRoute, Never>()

    private var subscriptions = Set<AnyCancellable>()

    init(diProvider: DIProviderProtocol) {
        self.diProvider = diProvider
    }
}

// MARK: - BreedsListViewModelProtocol
extension BreedsListViewModel: BreedsListViewModelProtocol {

    var viewState: AnyPublisher<BreedsList.Models.ViewState, Never> { viewStateSubj.eraseToAnyPublisher() }
    var viewAction: AnyPublisher<BreedsList.Models.ViewAction, Never> { viewActionSubj.eraseToAnyPublisher() }
    var route: AnyPublisher<BreedsList.Models.ViewRoute, Never> { routeSubj.eraseToAnyPublisher() }

    func process(input: BreedsList.Models.ViewModelInput) {
        input.onLoad.sink { [weak self] _ in
            self?.loadBreeds()
        }.store(in: &subscriptions)

        input.onItem.sink { [weak self] index in
            guard let self = self else { return }
            self.viewActionSubj.send(
                .moveToBreedPicsScreen(breed: self.items[index], diProvider: self.diProvider)
            )
            self.update()
        }.store(in: &subscriptions)

        input.onUpdateCollectionSubj.sink { [weak self] breedsList in
            guard let self = self else { return }
            self.update(with: self.items.filter { breedsList.isEmpty || $0.text.contains(breedsList.trimmed) })
        }.store(in: &subscriptions)

        input.onFavoriteTapped.sink { [weak self] in
            guard let self = self else { return }
            self.viewActionSubj.send(.moveToFavoriteScreen(diProvider: self.diProvider))
        }.store(in: &subscriptions)

        input.onRetryTapped.sink { [weak self] in
            let request = self?.requestQueue.dequeue()
            request?()
        }.store(in: &subscriptions)
        
        input.onSearchQuery
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] query in
            self?.reloadBreeds(for: query)
        }.store(in: &subscriptions)
        
        input.onReset.sink { [weak self] in
            self?.update()
        }.store(in: &subscriptions)
    }
}

// MARK: - Private
private extension BreedsListViewModel {
    
    func reloadBreeds(for query: String) {
        let filteredItems: [BreedsList.Models.ItemModel]
        if query.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { $0.text.lowercased().contains(query.lowercased()) }
        }
        guard filteredItems.count != lastDisplayedItems.count else { return }
        update(with: filteredItems)
    }

    func loadBreeds() {
        viewStateSubj.send(.loading)
        diProvider.breedsController
            .getBreedsList()
            .sink(receiveCompletion: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case let .failure(error):
                    self.requestQueue.enqueue(self.loadBreeds)
                    self.viewActionSubj.send(.showError(message: error.localizedDescription))
                case .finished:
                    break
                }
            }) { breeds in
                self.items = breeds.sorted(by: { $0.text < $1.text })
                self.update()
            }
            .store(in: &subscriptions)
    }

    /// Sole entry point for collection view update
    func update(with items: [BreedsList.Models.ItemModel]? = nil) {
        let items = items ?? self.items
        lastDisplayedItems = items
        viewStateSubj.send(.plain(mapItems(items)))
    }

    func mapItems(_ items: [BreedsList.Models.ItemModel]) -> [BreedsList.Models.Item] {
        items.map { .item(.init(text: $0.text)) }
    }
}



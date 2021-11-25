//
//  BreedViewModel.swift
//  Breeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Combine
import UIKit

protocol BreedViewModelProtocol: AnyObject {
    var viewState: AnyPublisher<Breed.Models.ViewState, Never> { get }
    var viewAction: AnyPublisher<Breed.Models.ViewAction, Never> { get }
    var route: AnyPublisher<Breed.Models.ViewRoute, Never> { get }

    func process(input: Breed.Models.ViewModelInput)
}

final class BreedViewModel {

    // MARK: - Private properties
    private let breed: String?
    private let diProvider: DIProviderProtocol
    private var items: [Breed.Models.BreedItemModel] = []
    private var selectedItems: [Breed.Models.BreedItemModel] = []
    // not needed for now, but would be nice for future functionality
    private let completion: (([Breed.Models.BreedItemModel]) -> Void)?
    private var requestQueue: Queue<ActionHandler> = .init()
    private let generator = UIImpactFeedbackGenerator(style: .medium)

    private let viewStateSubj = CurrentValueSubject<Breed.Models.ViewState, Never>(.loading)
    private let viewActionSubj = PassthroughSubject<Breed.Models.ViewAction, Never>()
    private let routeSubj = PassthroughSubject<Breed.Models.ViewRoute, Never>()

    private var subscriptions = Set<AnyCancellable>()

    // flag whether to hide like in collection view item
    private var shouldHideItemLike = true

    init(breed: String?,
         diProvider: DIProviderProtocol,
         completion: (([Breed.Models.BreedItemModel]) -> Void)?) {
        self.breed = breed
        self.diProvider = diProvider
        self.completion = completion
    }
}

// MARK: - BreedViewModelProtocol
extension BreedViewModel: BreedViewModelProtocol {

    var viewState: AnyPublisher<Breed.Models.ViewState, Never> { viewStateSubj.eraseToAnyPublisher() }
    var viewAction: AnyPublisher<Breed.Models.ViewAction, Never> { viewActionSubj.eraseToAnyPublisher() }
    var route: AnyPublisher<Breed.Models.ViewRoute, Never> { routeSubj.eraseToAnyPublisher() }

    func process(input: Breed.Models.ViewModelInput) {
        input.onLoad.sink { [weak self] in
            guard let self = self else { return }
            self.viewActionSubj.send(.setTitle(self.breed?.capitalized ?? "Favorite"))
            self.loadImages()
        }.store(in: &subscriptions)

        input.onDismiss.sink { [weak self] _ in
            guard let self = self else { return }
            self.selectedItems = self.items.filter(\.selected)
            self.completion?(self.selectedItems)
        }.store(in: &subscriptions)

        input.onItem.sink { [weak self] tapData in
            guard let self = self else { return }
            let item = self.items[tapData.index]
            if tapData.shouldRemoveItem {
                self.items.remove(at: tapData.index)
            } else {
                if !item.selected {
                    self.generator.impactOccurred()
                }
                item.selected.toggle()
            }
            self.diProvider.breedsService.toggle(breed: item)
            self.update()
        }.store(in: &subscriptions)

        input.onUpdateCollectionSubj.sink { [weak self] breed in
            guard let self = self else { return }
            self.update(with: self.items.filter { breed.isEmpty || $0.text.contains(breed.trimmed.lowercased()) })
        }.store(in: &subscriptions)

        input.onFilterTapped.sink { [weak self] in
            guard let self = self else { return }
            self.viewActionSubj.send(.showActionSheet(items: self.uniqueBreeds()))
        }.store(in: &subscriptions)

        input.onRetryTapped.sink { [weak self] in
            guard let self = self else { return }
            let request = self.requestQueue.dequeue()
            request?()
        }.store(in: &subscriptions)
    }
}

// MARK: - Private
private extension BreedViewModel {

    func loadImages() {
        guard let breed = breed else {
            items = diProvider.breedsService.favoriteBreeds
            update()
            return
        }
        viewStateSubj.send(.loading)
        diProvider.breedsController
            .getBreedImages(breed)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case let .failure(error):
                    self.requestQueue.enqueue(self.loadImages)
                    self.viewActionSubj.send(.showError(message: error.localizedDescription))
                case .finished:
                    break
                }
            }) { imageUrls in
                self.items = imageUrls.sorted(by: <).map {
                    let item = BreedItemModel(text: breed, url: $0)
                    item.selected = self.diProvider.breedsService.contains(breed: item)
                    return item
                }
                self.update()
            }
            .store(in: &subscriptions)
    }

    func update(with items: [Breed.Models.BreedItemModel]? = nil) {
        let items = items ?? self.items
        viewStateSubj.send(.plain(mapItems(items)))
    }

    func mapItems(_ items: [Breed.Models.BreedItemModel]) -> [Breed.Models.Item] {
        items.map {
            .item(.init(
                imageUrl: $0.url,
                text: $0.text,
                isLikeHidden: !$0.selected
            ))
        }
    }

    func uniqueBreeds() -> [Breed.Models.BreedItemModel] {
        let items: [BreedItemModel] = items.map { .init(text: $0.text.capitalized, url: $0.url, selected: $0.selected, shouldHashUrl: false) }
        return Array(Set(items)).sorted(by: { $0.text < $1.text })
    }
}


//
//  ActionSheetViewModel.swift
//  CustomActionSheet
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Combine
import UIKit

protocol ActionSheetViewModelProtocol: AnyObject {
    var viewState: AnyPublisher<ActionSheet.Models.ViewState, Never> { get }
    var route: AnyPublisher<ActionSheet.Models.ViewRoute, Never> { get }

    func process(input: ActionSheet.Models.ViewModelInput)
}

final class ActionSheetViewModel {

    // MARK: - Properties
    private let items: [ActionSheet.Models.ItemModel]
    private var selectedCompany: ActionSheet.Models.ItemModel?
    private let completion: ((ActionSheet.Models.ItemModel?) -> Void)?

    private let viewStateSubj = CurrentValueSubject<ActionSheet.Models.ViewState, Never>(.idle)
    private let routeSubj = PassthroughSubject<ActionSheet.Models.ViewRoute, Never>()

    private var subscriptions = Set<AnyCancellable>()

    init(items: [ActionSheet.Models.ItemModel],
         completion: ((ActionSheet.Models.ItemModel?) -> Void)?) {
        self.items = items
        self.completion = completion
    }
}

// MARK: - ActionSheetViewModelProtocol
extension ActionSheetViewModel: ActionSheetViewModelProtocol {

    var viewState: AnyPublisher<ActionSheet.Models.ViewState, Never> { viewStateSubj.eraseToAnyPublisher() }
    var route: AnyPublisher<ActionSheet.Models.ViewRoute, Never> { routeSubj.eraseToAnyPublisher() }

    func process(input: ActionSheet.Models.ViewModelInput) {
        input.onLoad.sink { [weak self] _ in
            guard let self = self else { return }
            self.update()
        }.store(in: &subscriptions)

        input.onDismiss.sink { [weak self] _ in
            guard let self = self else { return }
            self.selectedCompany = self.items.first(where: \.selected)
            self.completion?(self.selectedCompany)
        }.store(in: &subscriptions)

        input.onItem.sink { [weak self] index in
            guard let self = self else { return }
            self.selectItem(with: index)
            self.update()
        }.store(in: &subscriptions)
    }
}

// MARK: - Private
private extension ActionSheetViewModel {
    func selectItem(with index: Int) {
        func toggleSelectedItem(_ index: Int) { items[index].selected.toggle()
        }
        guard let selectedIndex = items.firstIndex(where: \.selected) else {
            toggleSelectedItem(index)
            return
        }
        toggleSelectedItem(index)
        if selectedIndex != index {
            toggleSelectedItem(selectedIndex)
        }
    }

    func update() {
        viewStateSubj.send(.plain(parsedItems))
    }

    var parsedItems: [ActionSheet.Models.Item] {
        items.map {
            .item(.init(
                imageUrl: $0.url,
                text: $0.text,
                selected: $0.selected
            ))
        }
    }
}


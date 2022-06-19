//
//  BreedsListModels.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation
import Combine

enum BreedsList {}

extension BreedsList {
    enum Models {}
}

// MARK: - Models View Input/Output
extension BreedsList.Models {

    struct ItemModel: CustomStringConvertible {
        let text: String
        let subtypes: [String]

        init(text: String, subtypes: [String]) {
            self.text = text
            self.subtypes = subtypes
        }

        // MARK: - Mock fields
        
        static var models: [ItemModel] {
            (0..<dogBreedsLists.count).map { .init(text: "\(dogBreedsLists[$0])", subtypes: ["\($0)"]) }
        }

        static private var dogBreedsLists: [String] = [
            "retriever",
            "bulldog",
            "rottweiler",
            "doberman",
            "labrador",
            "boxer",
            "korg"
        ]

        var description: String {
            "text: \(text)"
        }
    }

    // MARK: Input
    struct ViewModelInput {
        let onLoad: AnyPublisher<Void, Never>
        let onItem: AnyPublisher<Int, Never>
        let onUpdateCollectionSubj: AnyPublisher<String, Never>
        let onFavoritePicsTapped: AnyPublisher<Void, Never>
        let onRetryTapped: AnyPublisher<Void, Never>
        let onSearchQuery: AnyPublisher<String, Never>
        let onReset: AnyPublisher<Void, Never>
    }

    // MARK: Output
    enum ViewState: Equatable {
        case loading
        case error(String)
        case plain([Item])
    }

    enum ViewAction {
        case moveToFavoritePicsScreen(diProvider: DIProviderProtocol)
        case moveToBreedPicsScreen(breed: ItemModel, diProvider: DIProviderProtocol)
        case showError(message: String)
    }

    enum ViewRoute {
        case dismiss
    }
}

// MARK: - Scene Models
extension BreedsList.Models {

    // MARK: List Models
    enum Section: Hashable {
        case main
    }

    enum Item: Hashable {
        case item(BreedsListCollectionViewCell.State)
    }
}

// MARK: - CheckBoxModel: Equatable
extension BreedsList.Models.ItemModel: Equatable {

    static func == (lhs: BreedsList.Models.ItemModel, rhs: BreedsList.Models.ItemModel) -> Bool {
        lhs.text == rhs.text
    }
}

// MARK: - CheckBoxModel: Hashable
extension BreedsList.Models.ItemModel: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
}


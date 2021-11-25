//
//  BreedModels.swift
//  Breeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation
import Combine

enum Breed {}

extension Breed {
    enum Models {}
}

// MARK: - Models View Input/Output
extension Breed.Models {

    class BreedItemModel: CustomStringConvertible, Codable {
        let text: String
        let url: String
        var selected: Bool
        var shouldHashUrl: Bool

        init(text: String,
             url: String,
             selected: Bool = false,
             shouldHashUrl: Bool = true) {
            self.text = text
            self.url = url
            self.selected = selected
            self.shouldHashUrl = shouldHashUrl
        }

        static var models: [BreedItemModel] {
            (0..<dogBreeds.count).map { .init(text: "\(dogBreeds[$0])", url: "\($0)") }
        }

        static private var dogBreeds: [String] = [
            "retriever",
            "bulldog",
            "rottweiler",
            "doberman",
            "labrador",
            "retriever",
            "boxer",
            "retriever",
            "korg"
        ]

        var description: String {
            "text: \(text), url: \(url)"
        }
    }

    // MARK: Input
    struct ViewModelInput {
        let onLoad: AnyPublisher<Void, Never>
        let onDismiss: AnyPublisher<Void, Never>
        let onItem: AnyPublisher<OnItemTapData, Never>
        let onUpdateCollectionSubj: AnyPublisher<String, Never>
        let onFilterTapped: AnyPublisher<Void, Never>
        let onRetryTapped: AnyPublisher<Void, Never>
    }

    struct OnItemTapData {
        let index: Int
        let shouldRemoveItem: Bool
    }

    // MARK: Output
    enum ViewState: Equatable {
        case loading
        case error(String)
        case plain([Item])
    }

    enum ViewAction {
        case showActionSheet(items: [BreedItemModel])
        case showError(message: String)
        case setTitle(String)
    }

    enum ViewRoute {
        case dismiss
    }
}

// MARK: - Scene Models
extension Breed.Models {

    // MARK: List Models
    enum Section: Hashable {
        case main
    }

    enum Item: Hashable {
        case item(BreedCollectionViewCell.State)
    }
}

// MARK: - CheckBoxModel: Equatable
extension Breed.Models.BreedItemModel: Equatable {

    static func == (lhs: Breed.Models.BreedItemModel, rhs: Breed.Models.BreedItemModel) -> Bool {
        var result = lhs.text == rhs.text
        if lhs.shouldHashUrl && rhs.shouldHashUrl {
            result = result && lhs.url == rhs.url
        }
        return result
    }
}

// MARK: - CheckBoxModel: Hashable
extension Breed.Models.BreedItemModel: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        if shouldHashUrl {
            hasher.combine(url)
        }
    }
}

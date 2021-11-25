//
//  ActionSheetModels.swift
//  CustomActionSheet
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation
import Combine

enum ActionSheet {}

extension ActionSheet {
    enum Models {}
}

// MARK: - Models View Input/Output
extension ActionSheet.Models {

    class ItemModel: CustomStringConvertible {
        let text: String
        let url: String
        var selected = false

        init(text: String, url: String, selected: Bool = false) {
            self.selected = selected
            self.text = text
            self.url = url
        }

        var description: String {
            "text: \(text)"
        }
    }

    // MARK: Input
    struct ViewModelInput {
        let onLoad: AnyPublisher<Void, Never>
        let onDismiss: AnyPublisher<Void, Never>
        let onItem: AnyPublisher<Int, Never>
    }

    // MARK: Output
    enum ViewState: Equatable {
        case idle
        case plain([Item])
    }

    enum ViewAction {
    }

    enum ViewRoute {
        case dismiss
    }
}

// MARK: - Scene Models
extension ActionSheet.Models {

    // MARK: List Models
    enum Section: Hashable {
        case main
    }

    enum Item: Hashable {
        case item(ActionSheetTableViewCell.State)
    }
}

// MARK: - CheckBoxModel: Equatable
extension ActionSheet.Models.ItemModel: Equatable {

    static func == (lhs: ActionSheet.Models.ItemModel, rhs: ActionSheet.Models.ItemModel) -> Bool {
        lhs.text == rhs.text && lhs.selected == rhs.selected
    }
}


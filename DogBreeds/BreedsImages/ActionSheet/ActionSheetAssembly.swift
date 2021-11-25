//
//  ActionSheetAssembly.swift
//  CustomActionSheet
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

extension ActionSheet {
    enum Assembly {}
}

extension ActionSheet.Assembly {
    static func createModule(
        items: [ActionSheet.Models.ItemModel],
        completion: ((ActionSheet.Models.ItemModel?) -> Void)?
    ) -> PanModalPresentable.LayoutType {
        let viewController = ActionSheetViewController()
        viewController.setDependencies(viewModel: ActionSheetViewModel(items: items, completion: completion))
        viewController.numberOfItems = items.count
        return viewController
    }
}

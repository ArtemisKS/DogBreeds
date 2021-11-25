//
//  BreedsListAssembly.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

extension BreedsList {
    enum Assembly {}
}

extension BreedsList.Assembly {
    static func createModule(diProvider: DIProviderProtocol) -> UIViewController {
        let viewController = BreedsListViewController()
        viewController.setDependencies(viewModel: BreedsListViewModel(diProvider: diProvider))
        return viewController
    }
}

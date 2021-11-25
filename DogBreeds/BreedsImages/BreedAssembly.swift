//
//  BreedAssembly.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

extension Breed {
    enum Assembly {}
}

extension Breed.Assembly {
    static func createModule(
        breed: String?,
        config: BreedViewController.Config,
        diProvider: DIProviderProtocol,
        completion: (([Breed.Models.BreedItemModel]) -> Void)?
    ) -> UIViewController {
        let viewController = BreedViewController(config: config)
        viewController.setDependencies(
            viewModel: BreedViewModel(
                breed: breed,
                diProvider: diProvider,
                completion: completion
            )
        )
        return viewController
    }
}

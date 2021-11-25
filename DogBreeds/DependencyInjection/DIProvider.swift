//
//  DIProvider.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation

protocol DIProviderProtocol: AnyObject {
    var breedsController: BreedsController { get }
    var breedsService: FavoriteBreedsService { get }
}

class DIProvider: DIProviderProtocol {

    private lazy var networkController = NetworkController()

    // MARK: - Properties

    private(set) lazy var breedsController = BreedsController(networkController: networkController)

    private(set) lazy var breedsService: FavoriteBreedsService = FavoriteBreedsServiceImpl()
}

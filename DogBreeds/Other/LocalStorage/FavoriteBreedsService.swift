//
//  FavoriteBreedsService.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 24.11.2021.
//

import Foundation

typealias BreedItemModel = Breed.Models.BreedItemModel

protocol FavoriteBreedsService: AnyObject {
    var favoriteBreeds: [BreedItemModel] { get }
    func toggle(breed: BreedItemModel)
    func contains(breed: BreedItemModel) -> Bool
}

class FavoriteBreedsServiceImpl: FavoriteBreedsService {

    private let userDefaults = UserDefaults.standard

    private(set) var favoriteBreeds: [BreedItemModel] {
        get {
            guard let data = userDefaults.data(forKey: #function),
                  let breeds = try? JSONDecoder().decode([BreedItemModel].self, from: data) else { return [] }
            return breeds
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            userDefaults.set(data, forKey: #function)
        }
    }

    func toggle(breed: BreedItemModel) {
        if contains(breed: breed) {
            remove(breed: breed)
        } else {
            append(breed: breed)
        }
    }

    func contains(breed: BreedItemModel) -> Bool {
        Set(favoriteBreeds).contains(breed)
    }
}

private extension FavoriteBreedsServiceImpl {

    func append(breed: BreedItemModel) {
        favoriteBreeds.append(breed)
    }

    func remove(breed: BreedItemModel) {
        guard let firstIndex = favoriteBreeds.firstIndex(of: breed) else { return }
        favoriteBreeds.remove(at: firstIndex)
    }
}

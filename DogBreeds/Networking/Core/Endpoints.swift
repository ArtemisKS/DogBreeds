//
//  Endpoints.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation

enum Endpoints {
    case allBreeds
    case breedImages(String)
}

extension Endpoints {

    var value: String {
        switch self {
        case .allBreeds:
            return "/breeds/list/all"
        case let .breedImages(breed):
            return "/breed/\(breed)/images"
        }
    }
}

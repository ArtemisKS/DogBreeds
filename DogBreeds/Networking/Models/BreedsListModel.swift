//
//  BreedsListModel.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation

struct BreedsListModel: Decodable {

    let message: [String : [String]]
    let status: String
}

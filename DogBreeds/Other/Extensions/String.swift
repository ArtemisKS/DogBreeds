//
//  String.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation

extension String {

    var trimmed: Self {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

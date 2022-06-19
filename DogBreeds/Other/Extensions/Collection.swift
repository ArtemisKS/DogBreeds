//
//  Collection.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 19.06.2022.
//

import Foundation

extension Collection {
    
    var isNotEmpty: Bool { !isEmpty }
    
    func count(where predicate: (Element) -> Bool) -> Int {
        reduce(0) { predicate($1) ? $0 + 1 : $0 }
    }
}

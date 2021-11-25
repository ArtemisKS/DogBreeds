//
//  UIEdgeInsets.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

extension UIEdgeInsets {

    init(horizontal: CGFloat, vertical: CGFloat = .zero) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}

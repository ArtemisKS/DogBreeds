//
//  UIView.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

extension UIView {

    func round(with radius: CGFloat, shouldRasterize: Bool = false) {
        layer.cornerRadius = radius
        layer.masksToBounds = radius > 0
        if shouldRasterize {
            rasterize()
        }
    }

    private func rasterize() {
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

    func addBorder(_ cornerRadius: CGFloat = 5, borderWidth: CGFloat = 1, color: UIColor) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = color.cgColor
    }
}

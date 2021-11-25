//
//  UIColor.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//


import UIKit

extension UIColor {

    // MARK: - Custom colors
    class var textSecondary: UIColor {
        .init(r: 100, g: 111, b: 121)
    }

    class var customLightBlue: UIColor {
        .init(r: 190, g: 191, b: 221)
    }

    class var customVeryLightBlue: UIColor {
        .init(r: 230, g: 241, b: 251)
    }

    class var f4f7fb: UIColor {
        .init(hex: 0xf4f7fb)
    }

    class var carolinaBlue: UIColor {
        .init(hex: 0x4d9de0)
    }

    class var cellSelectedColor: UIColor {
        .init(rgb: 250)
    }

    class var imperialRed: UIColor {
        .init(r: 237, g: 41, b: 60)
    }

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            r: (hex >> 16) & 0xFF,
            g: (hex >> 8) & 0xFF,
            b: hex & 0xFF,
            alpha: alpha
        )
    }

    convenience init(rgb: UInt8, alpha: CGFloat = 1.0) {
        let rgb = Int(rgb)
        self.init(
            r: rgb,
            g: rgb,
            b: rgb,
            alpha: alpha
        )
    }

    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat = 1) {
        let floatColorValue: (Int) -> CGFloat = {
            CGFloat($0 % 255) / 255
        }
        self.init(red: floatColorValue(r),
                  green: floatColorValue(g),
                  blue: floatColorValue(b),
                  alpha: alpha)

    }
}


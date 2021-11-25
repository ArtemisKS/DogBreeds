//
//  String+Size.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import Foundation

import UIKit

public extension String {

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let textHeight = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).height.rounded(.up)

        return textHeight
    }

    func width(height: CGFloat, font: UIFont) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let attributedText = NSAttributedString(string: self, attributes: attributes)
        let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: height)
        let textWidth = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).width.rounded(.up)

        return textWidth
    }

}

//
//  CustomButton.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

class CustomButton: UIButton {

    // MARK: - Properties

    var backColor: UIColor = .white

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundColor = backColor.withAlphaComponent(0.75)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        backgroundColor = backColor
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = backColor
    }

    // MARK: - Lifecycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupUI()
    }
}

// MARK: - Private
private extension CustomButton {

    func setupUI() {
        backgroundColor = backColor
    }
}

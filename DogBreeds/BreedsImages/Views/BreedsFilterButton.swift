//
//  BreedsFilterButton.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

final class BreedsFilterButton: CustomButton {

    // MARK: - Outlets

    private let filterView: BreedsFilterView = {
        $0.isUserInteractionEnabled = false
        return $0
    }(BreedsFilterView())

    // MARK: - Lifecycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupUI()
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle("", for: state)
        guard let title = title else { return }
        filterView.state = .init(text: title)
    }
}

// MARK: - Private
private extension BreedsFilterButton {

    func setupUI() {
        addStretchedSubview(filterView)
    }
}

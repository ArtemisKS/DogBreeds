//
//  BreedsListCollectionViewCell.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

final class BreedsListCollectionViewCell: UICollectionViewCell, Reusable {

    private enum Defaults {

        static let cornerRadius: CGFloat = 8
    }

    struct State {
        let text: String?
    }

    // MARK: - Properties

    var state: State? {
        didSet {
            updateUI()
        }
    }

    // MARK: - Private

    private let avatarContainerView = UIView()

    private let titleLabel: UILabel = {
        $0.textAlignment = .center
        return $0
    }(UILabel())

    private let selectedView: UIView = {
        $0.backgroundColor = .f4f7fb
        return $0
    }(UIView())

    // MARK: - Initialisation
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Private
private extension BreedsListCollectionViewCell {

    func setupUI() {
        self.selectedBackgroundView = selectedView
        contentView.addCenteredSubview(titleLabel)
        contentView.round(with: Defaults.cornerRadius)
        contentView.backgroundColor = .customVeryLightBlue
    }

    func updateUI() {
        guard let state = state else { return }
        titleLabel.text = state.text
    }
}

// MARK: - Hashable
extension BreedsListCollectionViewCell.State: Hashable {

    static func == (lhs: BreedsListCollectionViewCell.State, rhs: BreedsListCollectionViewCell.State) -> Bool {
        lhs.text == rhs.text
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(text.hashValue)
    }
}

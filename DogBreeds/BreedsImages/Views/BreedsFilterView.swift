//
//  BreedsFilterView.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

final class BreedsFilterView: UIView {

    private enum Defaults {
        static let stackViewInsets: UIEdgeInsets = .init(horizontal: 8, vertical: 8)
        static let stackViewSpacing: CGFloat = 8
    }

    struct State {
        let text: String
    }

    // MARK: - Properties
    var state: State? {
        didSet {
            configure()
        }
    }

    // MARK: - Outlets

    private let filterImageView: UIImageView = {
        $0.image = .init(systemName: "line.3.horizontal.decrease.circle.fill")?
            .withRenderingMode(.alwaysTemplate)
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())

    private let textLabel: UILabel = {
        $0.font = .systemFont(ofSize: 15, weight: .semibold)
        $0.textColor = .white
        return $0
    }(UILabel())

    private let stackView: UIStackView = {
        $0.axis = .horizontal
        $0.spacing = Defaults.stackViewSpacing
        $0.alignment = .center
        return $0
    }(UIStackView())

    // MARK: - Lifecycle
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupUI()
    }
}

// MARK: - Internal methods
extension BreedsFilterView {
}

// MARK: - Private methods
private extension BreedsFilterView {

    func setupUI() {
        addStretchedSubview(stackView,
                            insets: Defaults.stackViewInsets)
        stackView.addArrangedSubviews([textLabel, filterImageView])
    }

    func configure() {
        guard let state = state else { return }
        textLabel.text = state.text
    }
}

//
//  ErrorView.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

final class ErrorView: UIView {

    private enum Defaults {
        static let stackViewSpacing: CGFloat = 32

        enum RetryButton {
            static let size: CGSize = .init(width: 160, height: 48)
            static let cornerRadius: CGFloat = 8
        }
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

    var retryAction: ActionHandler?

    // MARK: - Outlets

    private let textLabel: UILabel = {
        $0.font = .systemFont(ofSize: 21, weight: .semibold)
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = .init(white: 0.2, alpha: 1)
        return $0
    }(UILabel())

    private lazy var retryButton: CustomButton = {
        $0.setTitle("Retry", for: .normal)
        $0.backColor = .carolinaBlue
        $0.round(with: Defaults.RetryButton.cornerRadius)
        $0.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return $0
    }(CustomButton())

    private let stackView: UIStackView = {
        $0.axis = .vertical
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

// MARK: - Private methods
private extension ErrorView {

    func setupUI() {
        addStretchedSubview(stackView)
        stackView.addArrangedSubviews([textLabel, retryButton])
        NSLayoutConstraint.activate(retryButtonConstraints)
    }

    func configure() {
        guard let state = state else { return }
        textLabel.text = state.text
    }

    @objc
    func retryButtonTapped() {
        retryAction?()
    }
}

// MARK: - Constraints

private extension ErrorView {

    var retryButtonConstraints: [NSLayoutConstraint] {
        [
            retryButton.widthAnchor.constraint(equalToConstant: Defaults.RetryButton.size.width),
            retryButton.heightAnchor.constraint(equalToConstant: Defaults.RetryButton.size.height)
        ]
    }
}

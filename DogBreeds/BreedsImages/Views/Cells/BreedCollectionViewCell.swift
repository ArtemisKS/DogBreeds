//
//  BreedCollectionViewCell.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit
import Kingfisher

final class BreedCollectionViewCell: UICollectionViewCell, Reusable {

    private enum Defaults {
        static let imageSize: CGSize = .init(width: 40, height: 40)
        static let stackViewSpacing: CGFloat = 16
        static let checkImageSize: CGSize = .init(width: 16, height: 16)
        static let checkImageInsets: UIEdgeInsets = .init(horizontal: 8, vertical: 4)

        enum Images {
            static let checkmark = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        }
    }

    struct State {
        let imageUrl: String
        let text: String?
        let isLikeHidden: Bool
    }

    // MARK: - Properties

    var state: State? {
        didSet {
            updateUI()
        }
    }

    var wasSelected = false {
        didSet {
            updateLikeImage()
        }
    }

    // MARK: - Private

    private let avatarContainerView = UIView()

    private let avatarImageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        $0.kf.indicatorType = .activity
        return $0
    }(UIImageView())

    private let checkBoxImageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        $0.image = Defaults.Images.checkmark
        $0.tintColor = .imperialRed
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())

    private let stackView: UIStackView = {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = Defaults.stackViewSpacing
        return $0
    }(UIStackView())

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
private extension BreedCollectionViewCell {

    func setupUI() {
        self.selectedBackgroundView = selectedView
        contentView.addCenteredSubview(stackView)
        stackView.addArrangedSubview(avatarContainerView)
        avatarContainerView.addStretchedSubview(avatarImageView)
        avatarContainerView.addSubview(checkBoxImageView)
        NSLayoutConstraint.activate(checkboxImageConstraints)
    }

    func updateUI() {
        guard let state = state else { return }
        backgroundColor = wasSelected ? .cellSelectedColor : .white
        updateLikeImage()
        guard let url = URL(string: state.imageUrl) else { return }
        let desiredSize: CGSize = .init(width: contentView.frame.width, height: contentView.frame.height)
        let processor = DownsamplingImageProcessor(size: desiredSize) |> ResizingImageProcessor(referenceSize: desiredSize, mode: .aspectFit)
        avatarImageView.kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(0.5)),
                .cacheOriginalImage
            ])
    }

    func updateLikeImage() {
        guard let state = state else { return }
        checkBoxImageView.isHidden = state.isLikeHidden && !wasSelected
    }
}

// MARK: - Constraints

private extension BreedCollectionViewCell {

    var checkboxImageConstraints: [NSLayoutConstraint] {
        [
            checkBoxImageView.widthAnchor.constraint(equalToConstant: Defaults.checkImageSize.width),
            checkBoxImageView.heightAnchor.constraint(equalToConstant: Defaults.checkImageSize.height),
            checkBoxImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Defaults.checkImageInsets.right),
            checkBoxImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Defaults.checkImageInsets.top)
        ]
    }
}

// MARK: - Hashable
extension BreedCollectionViewCell.State: Hashable {

    static func ==(lhs: BreedCollectionViewCell.State, rhs: BreedCollectionViewCell.State) -> Bool {
        lhs.text == rhs.text &&
        lhs.imageUrl == rhs.imageUrl &&
        lhs.isLikeHidden == rhs.isLikeHidden
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(text?.hashValue)
        hasher.combine(imageUrl.hashValue)
    }
}

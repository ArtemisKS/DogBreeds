//
//  ActionSheetTableViewCell.swift
//  CustomActionSheet
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit
import Kingfisher

final class ActionSheetTableViewCell: UITableViewCell, Reusable {

    private enum Defaults {
        static let imageSize: CGSize = .init(width: 40, height: 40)
        static let stackViewSpacing: CGFloat = 16
        static let horizontalInsets: CGFloat = 16
        static let verticalInsets: CGFloat = 16
        static let checkImageSize: CGSize = .init(width: 16, height: 16)
        static let checkImageInsets: UIEdgeInsets = .init(horizontal: 4, vertical: 4)

        enum Images {
            static let checkmark = UIImage(named: "checkbox_selected")
        }
    }

    struct State {
        let imageUrl: String
        let text: String?
        let selected: Bool
    }

    // MARK: - Properties

    var state: State? {
        didSet {
            updateUI()
        }
    }

    // MARK: - Private

    private let avatarContainerView = UIView()

    private let avatarImageView: UIImageView = {
        $0.contentMode = .scaleAspectFill
        $0.kf.indicatorType = .activity
        $0.round(with: Defaults.imageSize.width / 2)
        return $0
    }(UIImageView())

    private let checkBoxImageView: UIImageView = {
        $0.contentMode = .scaleAspectFit
        $0.image = Defaults.Images.checkmark
        $0.addBorder(Defaults.checkImageSize.width / 2,
                     borderWidth: 2,
                     color: .white)
        $0.isHidden = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIImageView())

    private let titleLabel: UILabel = {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 15, weight: .light)
        return $0
    }(UILabel())

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
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
}

// MARK: - Private
private extension ActionSheetTableViewCell {

    var imageContainerConstraints: [NSLayoutConstraint] {
        [
            avatarImageView.widthAnchor.constraint(equalToConstant: Defaults.imageSize.width),
            avatarImageView.heightAnchor.constraint(equalToConstant: Defaults.imageSize.height)
        ]
    }

    var checkboxImageConstraints: [NSLayoutConstraint] {
        [
            checkBoxImageView.widthAnchor.constraint(equalToConstant: Defaults.checkImageSize.width),
            checkBoxImageView.heightAnchor.constraint(equalToConstant: Defaults.checkImageSize.height),
            checkBoxImageView.trailingAnchor.constraint(equalTo: avatarContainerView.trailingAnchor, constant: Defaults.checkImageInsets.right),
            checkBoxImageView.bottomAnchor.constraint(equalTo: avatarContainerView.bottomAnchor, constant: Defaults.checkImageInsets.bottom)
        ]
    }

    func setupUI() {
        self.selectedBackgroundView = selectedView
        contentView.addStretchedSubview(
            stackView,
            insets: .init(
                horizontal: Defaults.horizontalInsets,
                vertical: Defaults.verticalInsets
            )
        )
        stackView.addArrangedSubviews([avatarContainerView, titleLabel])
        avatarContainerView.addStretchedSubview(avatarImageView)
        avatarContainerView.addSubview(checkBoxImageView)
        NSLayoutConstraint.activate(imageContainerConstraints + checkboxImageConstraints)
    }

    func updateUI() {
        guard let state = state else { return }
        titleLabel.text = state.text

        backgroundColor = state.selected ? .cellSelectedColor : .white
        checkBoxImageView.isHidden = !state.selected
        guard let url = URL(string: state.imageUrl) else { return }
        let processor = DownsamplingImageProcessor(size: Defaults.imageSize) |> ResizingImageProcessor(referenceSize: Defaults.imageSize, mode: .aspectFit)
        avatarImageView.kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ])
    }
}

// MARK: - Hashable
extension ActionSheetTableViewCell.State: Hashable {

    static func ==(lhs: ActionSheetTableViewCell.State, rhs: ActionSheetTableViewCell.State) -> Bool {
        lhs.text == rhs.text &&
        lhs.imageUrl == rhs.imageUrl &&
        lhs.selected == rhs.selected
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(text?.hashValue)
        hasher.combine(selected.hashValue)
    }
}

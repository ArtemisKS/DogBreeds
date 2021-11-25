//
//  UIViewController.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

extension UIView {

    func add(views: [UIView], with constraints: [NSLayoutConstraint]) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate(constraints)
    }

    /// Insert `views` to the specific `position` to the `parent` with `constraints`
    func insert(views: [UIView], to parent: UIView, at position: Int, with constraints: [NSLayoutConstraint]) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            parent.insertSubview($0, at: position)
        }
        NSLayoutConstraint.activate(constraints)
    }

    /// Add subview to view with insets
    @discardableResult
    func addStretchedSubview(_ view: UIView, insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        let constraints = [view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
                           view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
                           view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
                           view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)]

        NSLayoutConstraint.activate(constraints)

        return constraints
    }

    @discardableResult
    func insertStretchedSubview(_ view: UIView, insets: UIEdgeInsets = .zero, index: Int = 0) -> [NSLayoutConstraint] {
        view.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(view, at: index)

        let constraints = [view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
                           view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
                           view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
                           view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -insets.right)]

        NSLayoutConstraint.activate(constraints)

        return constraints
    }

    /// Add subview to view with insets
    func addCenteredSubview(_ view: UIView, offset: CGPoint = .zero, size: CGSize? = nil) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([view.centerXAnchor.constraint(equalTo: centerXAnchor, constant: offset.x),
                                     view.centerYAnchor.constraint(equalTo: centerYAnchor, constant: offset.y)])

        if let size = size {
            NSLayoutConstraint.activate([view.widthAnchor.constraint(equalToConstant: size.width),
                                         view.heightAnchor.constraint(equalToConstant: size.height)])
        }
    }
}

// MARK: - UIAlertViewController

extension UIViewController {

    func showOkAlert(title: String? = nil,
                     message: String,
                     defaultAction: (() -> Void)? = nil,
                     destructiveAction: (() -> Void)? = nil,
                     completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style {
            case .default, .cancel:
                defaultAction?()
            case .destructive:
                destructiveAction?()
            @unknown default:
                break
            }
        })
        alert.addAction(action)
        present(alert, animated: true, completion: completion)
    }
}

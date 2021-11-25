//
//  BaseViewController.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: - Private
    private var spinner: UIActivityIndicatorView = {
        $0.hidesWhenStopped = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.color = .carolinaBlue
        return $0
    }(UIActivityIndicatorView(style: .medium))

    // MARK: - Properties
    var nonErrorViews: [UIView] { [] }
    var errorView: ErrorView { .init() }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Methods
    func startAnimating() {
        view.bringSubviewToFront(spinner)
        spinner.startAnimating()
        view.isUserInteractionEnabled = false
    }

    func stopAnimating() {
        spinner.stopAnimating()
        view.isUserInteractionEnabled = true
    }

    func setLoading(_ loading: Bool) {
        loading ? startAnimating() : stopAnimating()
        if loading {
            setAllViews(hidden: true, errorViewHidden: true)
        }
    }

    func setAllViews(hidden: Bool, errorViewHidden: Bool) {
        nonErrorViews.forEach { $0.isHidden = hidden }
        errorView.isHidden = errorViewHidden
    }
}

private extension BaseViewController {

    func setupUI() {
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

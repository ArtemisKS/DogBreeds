//
//  BaseViewController.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

class BaseViewController: UIViewController, LoadingStateView {

    // MARK: - Private
    
    private var spinner: UIActivityIndicatorView = {
        $0.hidesWhenStopped = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.color = .carolinaBlue
        return $0
    }(UIActivityIndicatorView(style: .medium))

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    // MARK: - Private
    
    func showLoading(_ loading: Bool) {
        loading ? startAnimating() : stopAnimating()
    }
}

// MARK: - Private

private extension BaseViewController {

    func setupUI() {
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func startAnimating() {
        view.bringSubviewToFront(spinner)
        spinner.startAnimating()
        view.isUserInteractionEnabled = false
    }

    func stopAnimating() {
        spinner.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}

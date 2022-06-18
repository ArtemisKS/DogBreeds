//
//  ErrorStateView.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 18.06.2022.
//

import UIKit

protocol ErrorStateView: AnyObject {
    var nonErrorViews: [UIView] { get }
    var errorView: ErrorView { get }
}

extension ErrorStateView {
    func setViews(hidden: Bool, errorViewHidden: Bool) {
        nonErrorViews.forEach { $0.isHidden = hidden }
        errorView.isHidden = errorViewHidden
    }
}

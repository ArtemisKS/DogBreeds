//
//  LoadingStateView.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 18.06.2022.
//

import Foundation

protocol LoadingStateView: AnyObject {
    func setLoading(_ loading: Bool)
}

extension LoadingStateView where Self: BaseViewController {
    func setLoading(_ loading: Bool) {
        showLoading(loading)
        if loading, let errorStateView = self as? ErrorStateView {
            errorStateView.setViews(hidden: true, errorViewHidden: true)
        }
    }
}

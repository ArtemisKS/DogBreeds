//
//  CGFloat+Screen.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

public extension CGFloat {
    static var appHeight: CGFloat {
        UIApplication.shared.keyWindow?.rootViewController?.view.frame.height ?? 0.0
    }

    static var appWidth: CGFloat {
        UIApplication.shared.keyWindow?.rootViewController?.view.frame.width ?? 0.0
    }

    static var safeAreaTop: CGFloat {
        UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0
    }

    static var safeAreaBottom: CGFloat {
        UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
    }
}

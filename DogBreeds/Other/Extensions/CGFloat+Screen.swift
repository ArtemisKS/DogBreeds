//
//  CGFloat+Screen.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

public extension CGFloat {
    static var appHeight: CGFloat {
        UIApplication.shared.windows.first?.rootViewController?.view.frame.height ?? 0.0
    }

    static var appWidth: CGFloat {
        UIApplication.shared.windows.first?.rootViewController?.view.frame.width ?? 0.0
    }

    static var safeAreaTop: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0.0
    }

    static var safeAreaBottom: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
    }
}

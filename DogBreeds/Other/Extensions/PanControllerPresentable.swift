//
//  PanControllerPresentable.swift
//  DogBreeds
//
//  Created by Artem Kupriianets on 23.11.2021.
//

import UIKit

extension PanModalPresentable where Self: UIViewController {

    var indicatorYOffset: CGFloat {
        10
    }

    var dragIndicatorSize: CGSize {
        CGSize(width: 64, height: 4)
    }

    var panScrollable: UIScrollView? {
        nil
    }

    var topOffset: CGFloat {
        topLayoutOffset + 11.0
    }

    var shortFormHeight: PanModalHeight {
        longFormHeight
    }

    var longFormHeight: PanModalHeight {

        guard let scrollView = panScrollable else {
            return .maxHeight
        }

        scrollView.layoutIfNeeded()
        return .contentHeight(scrollView.contentSize.height)
    }

    var cornerRadius: CGFloat {
        20.0
    }

    var animationMode: AnimationMode {
        .normal
    }

    var springDamping: CGFloat {
        0.8
    }

    var springDampingFullScreen: CGFloat {
        1.0
    }

    var transitionDuration: Double {
        0.25
    }

    var transitionAnimationOptions: UIView.AnimationOptions {
        [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState]
    }

    var panModalBackgroundColor: UIColor {
        UIColor.black.withAlphaComponent(0.4)
    }

    var dragIndicatorBackgroundColor: UIColor {
        UIColor.lightGray
    }

    var scrollIndicatorInsets: UIEdgeInsets {
        let top = shouldRoundTopCorners.shouldRound(topOffset: topOffset) ? cornerRadius : 0
        return UIEdgeInsets(top: CGFloat(top), left: 0, bottom: bottomLayoutOffset, right: 0)
    }

    var anchorModalToLongForm: Bool {
        true
    }

    var allowsExtendedPanScrolling: Bool {

        guard panScrollable != nil else {
            return false
        }

        return true
    }

    var allowsDragToDismiss: Bool {
        true
    }

    var allowsTapToDismiss: Bool {
        true
    }

    var isUserInteractionEnabled: Bool {
        true
    }

    var isHapticFeedbackEnabled: Bool {
        false
    }

    var shouldRoundTopCorners: ShouldRoundTopCorners {
        isPanModalPresented ? .automatic : .never
    }

    var showDragIndicator: Bool {
        shouldRoundTopCorners.shouldRound(topOffset: topOffset)
    }

    func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool { true }

    func willRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) { }

    func shouldTransition(to state: PanModalPresentationController.PresentationState) -> Bool {
        true
    }

    func shouldPrioritize(panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        false
    }

    func willTransition(to state: PanModalPresentationController.PresentationState) {}

    func panModalWillDismiss() { }

    func panModalDidDismiss() { }

    func panModalStartDragging() { }

    func panModalStopDragging() { }
}

// MARK: - Defaults for animation
public extension PanModalAnimator {
    static let defaultCubic: AnimationMode = .cubicBezier(controlPoint1: CGPoint(x: 0.41, y: 0.18),
                                                          controlPoint2: CGPoint(x: 0.14, y: 1))
}

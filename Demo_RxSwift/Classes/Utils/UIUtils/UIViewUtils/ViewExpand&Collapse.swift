//
//  ViewExpand&Collapse.swift
//  Demo_RxSwift
//
//  Created by Maksims Peļņa on 07/05/2020.
//  Copyright © 2020 Maksims Peļņa. All rights reserved.
//

import UIKit

extension UIView {

    private var sideConstraint: CGFloat {
        return 16
    }

    private var expandedViewCornerRadius: CGFloat {
        return 10
    }

    private var collapsedViewCornerRadius: CGFloat {
        return 5
    }

    private var imageContainerFreeSpace: CGFloat {
        return 148
    }

    private func getHeight(windowFrame: CGRect, aspectRatio: Double) -> CGFloat {
        let width = windowFrame.width - sideConstraint * 2
        return CGFloat(aspectRatio) * (width - 16)
    }

    func expand(from frame: CGRect, windowFrame: CGRect, aspRatio: Double, completionHandler: @escaping () -> Void) {
        let imageHeight = getHeight(windowFrame: windowFrame, aspectRatio: aspRatio)
        let originalFrame = CGRect(x: sideConstraint,
                                   y: (windowFrame.height - imageHeight - imageContainerFreeSpace) / 2 + 10,
                                   width: windowFrame.width - sideConstraint * 2,
                                   height: imageHeight + imageContainerFreeSpace)

        let copyOfGifFrameView = UIView(frame: frame)
        copyOfGifFrameView.layer.cornerRadius = collapsedViewCornerRadius
        copyOfGifFrameView.backgroundColor = UIColor.black.withAlphaComponent(0.95)
        copyOfGifFrameView.alpha = 0
        self.addSubview(copyOfGifFrameView)

        let clearBg = UIView(frame: windowFrame)
        clearBg.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        clearBg.alpha = 0
        self.addSubview(clearBg)

        UIView.animate(withDuration: 0.7,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut,
                       animations: { [unowned self] in
            copyOfGifFrameView.layer.cornerRadius = self.expandedViewCornerRadius
            copyOfGifFrameView.frame = originalFrame
            copyOfGifFrameView.alpha = 1
            clearBg.alpha = 1
        }, completion: { _ in
            completionHandler()
            DispatchQueue.main.async {
                clearBg.removeFromSuperview()
                copyOfGifFrameView.removeFromSuperview()
            }
        })
    }

    func collapse(to frame: CGRect, windowFrame: CGRect, aspRatio: Double) {
        let imageHeight = getHeight(windowFrame: windowFrame, aspectRatio: aspRatio)
        let originalFrame = CGRect(x: sideConstraint,
                                   y: (windowFrame.height - imageHeight - imageContainerFreeSpace) / 2 + 10,
                                   width: windowFrame.width - sideConstraint * 2,
                                   height: imageHeight + imageContainerFreeSpace)

        let copyOfGifFrameView = UIView(frame: originalFrame)
        copyOfGifFrameView.layer.cornerRadius = expandedViewCornerRadius
        copyOfGifFrameView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        copyOfGifFrameView.alpha = 1
        self.addSubview(copyOfGifFrameView)

        let clearBg = UIView(frame: windowFrame)
        clearBg.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        clearBg.alpha = 1
        self.addSubview(clearBg)

        UIView.animate(withDuration: 0.7,
                        delay: 0,
                        usingSpringWithDamping: 0.5,
                        initialSpringVelocity: 0.5,
                        options: .curveEaseIn,
                        animations: { [unowned self] in
            copyOfGifFrameView.layer.cornerRadius = self.collapsedViewCornerRadius
            copyOfGifFrameView.frame = frame
            clearBg.alpha = 0
        }, completion: { _ in
            copyOfGifFrameView.removeFromSuperview()
            clearBg.removeFromSuperview()
        })

        UIView.animate(withDuration: 0.5, animations: {
            copyOfGifFrameView.alpha = 0
        })
    }
}

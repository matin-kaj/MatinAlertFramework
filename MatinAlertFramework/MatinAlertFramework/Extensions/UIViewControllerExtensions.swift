//
//  UIViewControllerExtensions.swift
//  MatinAlertFramework
//
//  Created by Matin Kajabadi on 12/31/20.
//

import UIKit

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        let drag: UIPanGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(drag)
    }

    @objc func dismissKeyboard(gesture: UIGestureRecognizer) {
        gesture.cancelsTouchesInView = false
        view.endEditing(true)
    }
}

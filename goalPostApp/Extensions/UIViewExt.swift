//
//  UIViewExt.swift
//  goalPostApp
//
//  Created by Kaushik Talluri on 04/08/20.
//  Copyright © 2020 tckr. All rights reserved.
//

import UIKit

extension UIView {
    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillchange(_:)), name: UIApplication.keyboardWillChangeFrameNotification, object: nil)
    }
    @objc func keyboardWillchange (_ notification: NSNotification) {
        // Allows for keyframe animation, moving the button up with the keyboard.
               // It binds the object with the button
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        let startingFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endingFrame =  (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = endingFrame.origin.y - startingFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
    }
}

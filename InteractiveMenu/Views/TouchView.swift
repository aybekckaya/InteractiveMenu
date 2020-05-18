//
//  TouchView.swift
//  InteractiveMenu
//
//  Created by aybek can kaya on 13.05.2020.
//  Copyright © 2020 aybek can kaya. All rights reserved.
//

import Foundation
import UIKit

class TouchView: UIView {
    fileprivate var animator = UIViewPropertyAnimator()
    
    func beganTouch(point : CGPoint) {
        self.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        self.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.layer.cornerRadius = self.frame.size.width / 2
        self.alpha = 0
        self.center = point
        
        self.animator = UIViewPropertyAnimator(duration: 0.3, curve: UIView.AnimationCurve.easeInOut, animations: {
            self.alpha = 0.7
        })
        self.animator.startAnimation()
 
    }
    
    func endTouch(completion: @escaping ()->()) {
        self.animator = UIViewPropertyAnimator(duration: 0.3, curve: UIView.AnimationCurve.easeInOut, animations: {
            self.alpha = 0
        })
        self.animator.startAnimation()
        self.animator.addCompletion { _ in
            self.removeFromSuperview()
            completion()
        }
 
    }
}

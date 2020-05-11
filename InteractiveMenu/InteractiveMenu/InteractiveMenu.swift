//
//  InteractiveMenu.swift
//  InteractiveMenu
//
//  Created by aybek can kaya on 8.05.2020.
//  Copyright © 2020 aybek can kaya. All rights reserved.
//

import UIKit


//MARK: Interactive Menu DataSource
protocol InteractiveMenuDataSource {
    func interactiveMenuViewInContainerView(interactiveMenu: InteractiveMenu)->UIView
}

// MARK: Interactive Menu Configuration
class InteractiveMenuConfiguration {
    var containerViewHeight:CGFloat = 600
    var containerViewBackgroundColor:UIColor = #colorLiteral(red: 0.06666666667, green: 0.07058823529, blue: 0.07450980392, alpha: 1)
}





// MARK: Interactive Menu {Class}
class InteractiveMenu: UIView {
     fileprivate let containerViewBottomMarginRate:CGFloat = 0.5 // Addition to bottom of view
    
    fileprivate let viewBlurBackground:UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = true
        blurView.alpha = 0.8
        //blurView.backgroundColor = UIColor.blue
        return blurView
    }()
    
    fileprivate let containerView:UIView = {
           let view = UIView(frame: CGRect.zero)
           view.translatesAutoresizingMaskIntoConstraints = true
           view.backgroundColor = #colorLiteral(red: 0.06666666667, green: 0.07058823529, blue: 0.07450980392, alpha: 1)
           view.layer.cornerRadius = 16
           view.layer.masksToBounds = true
           return view
       }()
    
    fileprivate var configuration:InteractiveMenuConfiguration = InteractiveMenuConfiguration()
    fileprivate var dataSource:InteractiveMenuDataSource!
    fileprivate var frameClosedPosition:CGRect = CGRect.zero
    fileprivate var frameOpenPosition:CGRect = CGRect.zero
    fileprivate var animator:UIViewPropertyAnimator = UIViewPropertyAnimator()
    
    fileprivate var totalHeightContainerView:CGFloat {
        return self.configuration.containerViewHeight + self.configuration.containerViewHeight * self.containerViewBottomMarginRate
    }
   
    
    init(embedIn view:UIView , dataSource : InteractiveMenuDataSource , configuration:InteractiveMenuConfiguration) {
        super.init(frame: CGRect.zero)
        self.dataSource = dataSource
        self.configuration = configuration
        view.addSubview(self)
        self.setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Set Up
extension InteractiveMenu {
    fileprivate func setUpUI() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.frame = CGRect(x: 0, y: 0, width: superview!.frame.size.width, height: superview!.frame.size.height)
        self.addSubview(self.viewBlurBackground)
        self.viewBlurBackground.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        self.addSubview(self.containerView)
        self.containerView.frame = CGRect(x: 0, y: self.frame.size.height - self.configuration.containerViewHeight, width: self.frame.size.width , height: self.totalHeightContainerView)
        
        let viewInContainer = self.dataSource.interactiveMenuViewInContainerView(interactiveMenu: self)
        viewInContainer.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width , height: self.configuration.containerViewHeight)
        self.containerView.addSubview(viewInContainer)
        viewInContainer.layoutIfNeeded()
        
        self.frameOpenPosition = CGRect(x: 0, y: self.frame.size.height - self.configuration.containerViewHeight, width: self.frame.size.width , height: self.totalHeightContainerView)
        self.frameClosedPosition = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width , height: self.totalHeightContainerView)
        self.containerView.frame = self.frameClosedPosition
        self.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: self.frame.size.height)
     
        let tapGestureBlurView = UITapGestureRecognizer(target: self, action: #selector(blurViewDidTapped))
        self.viewBlurBackground.addGestureRecognizer(tapGestureBlurView)
        
        let panGestureContainerView = UIPanGestureRecognizer(target: self, action: #selector(containerViewPanned(recognizer:)))
        self.containerView.addGestureRecognizer(panGestureContainerView)
        
    }
    
}


// MARK: Show / Hide
extension InteractiveMenu {
    @objc fileprivate func blurViewDidTapped() {
        self.hideView()
    }
    
    @objc fileprivate func containerViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        
        case .began:
            self.animator.stopAnimation(false)
        
        case .changed:
            let currentTranslation = recognizer.translation(in: recognizer.view!)
            let yPosNext =  recognizer.view!.center.y + currentTranslation.y
            let openedCenterYPos:CGFloat = self.frameOpenPosition.origin.y + self.frameOpenPosition.size.height / 2
            let closedCenterYPos:CGFloat = self.frameClosedPosition.origin.y + self.frameClosedPosition.size.height / 2
            let openPosDistance:CGFloat = recognizer.view!.frame.origin.y - self.frameOpenPosition.origin.y
            let maxDistance:CGFloat = self.frameClosedPosition.origin.y - self.frameOpenPosition.origin.y
            let rateOpened:CGFloat = openPosDistance / maxDistance
            let blurViewAlpha:CGFloat = min(0.7, 1-rateOpened)
            self.viewBlurBackground.alpha = blurViewAlpha
            if yPosNext < openedCenterYPos {
                let translationY = recognizer.translation(in: recognizer.view!).y * 0.05
                recognizer.view!.center = CGPoint(x: recognizer.view!.center.x, y: recognizer.view!.center.y + translationY)
            }
            else if yPosNext > closedCenterYPos {
                let translationY = recognizer.translation(in: recognizer.view!).y * 0.05
                recognizer.view!.center = CGPoint(x: recognizer.view!.center.x, y: recognizer.view!.center.y + translationY)
            }
            else {
                recognizer.view!.center = CGPoint(x: recognizer.view!.center.x, y: yPosNext)
            }
            
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view!)
            
            
        case .ended , .cancelled:
            let openedCenterYPos:CGFloat = self.frameOpenPosition.origin.y + self.frameOpenPosition.size.height / 2
            let closedCenterYPos:CGFloat = self.frameClosedPosition.origin.y + self.frameClosedPosition.size.height / 2
            let velocity = recognizer.velocity(in: recognizer.view!).y
            let distance = self.distanceForVelocity(velocity: velocity)
            var prefferedVelocity = velocity / distance
            if prefferedVelocity < 0 {
                prefferedVelocity = max(-30 , prefferedVelocity)
            }
            print("Pref Velocity : \(prefferedVelocity) , Velocity : \(velocity)")
            if abs(prefferedVelocity) <= 1.5 {
                let diffOpenYPos:CGFloat = abs(recognizer.view!.frame.origin.y - self.frameOpenPosition.origin.y)
                let diffCloseYPos:CGFloat = abs(recognizer.view!.frame.origin.y - self.frameClosedPosition.origin.y)
                if diffOpenYPos <= diffCloseYPos {
                    self.showView()
                }
                else {
                    self.hideView()
                }
            }
            else {
                let newCenterYPos = prefferedVelocity < 0 ? openedCenterYPos  : closedCenterYPos
                let vectorVelocity = abs(prefferedVelocity * 1)
                let timingParameters =  UISpringTimingParameters(damping: 1.5, response: 0.5, initialVelocity: CGVector(dx: vectorVelocity , dy: vectorVelocity))
                self.animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
                self.animator.addAnimations {
                    recognizer.view!.center = CGPoint(x: recognizer.view!.center.x, y: newCenterYPos)
                    if velocity >= 0 { self.viewBlurBackground.alpha = 0 }
                    else { self.viewBlurBackground.alpha = 0.7 }
                }
                self.animator.addCompletion { pos in
                    guard pos == .end else { return }
                    if velocity >= 0 {  self.hideView() }
                    else { self.showView() }
                    
                }
            }
           
            self.animator.startAnimation()
        default: break
        }
    }
    
    
    
    fileprivate func distanceForVelocity(velocity:CGFloat)->CGFloat {
        let openedCenterYPos:CGFloat = self.frameOpenPosition.origin.y + self.frameOpenPosition.size.height / 2
        let closedCenterYPos:CGFloat = self.frameClosedPosition.origin.y + self.frameClosedPosition.size.height / 2
        if velocity < 0 { return abs(openedCenterYPos - self.containerView.center.y) }
        return abs(closedCenterYPos - self.containerView.center.y)
    }
    
    fileprivate func showView() {
         if self.animator.isRunning { self.animator.stopAnimation(true) }
        self.frame = CGRect(x: self.frame.origin.x, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.viewBlurBackground.alpha = 0.7
        let timingParameters =  UISpringTimingParameters(damping: 0.6, response: 0.5)
        self.animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        self.animator.addAnimations {
            self.containerView.frame = self.frameOpenPosition
        }
        self.animator.addCompletion { pos in
            guard pos == .end else { return }
            // fire delegate
        }
        
        self.animator.startAnimation()
    }
    
    fileprivate func hideView() {
        if self.animator.isRunning { self.animator.stopAnimation(true) }
         
        let timingParameters =  UISpringTimingParameters(damping: 1.5, response: 0.5)
        self.animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        self.animator.addAnimations {
            self.containerView.frame = self.frameClosedPosition
            self.viewBlurBackground.alpha = 0
        }
        
        self.animator.addCompletion { pos in
            guard pos == .end else { return }
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.size.height, width: self.frame.size.width, height: self.frame.size.height)
            // fire delegate
        }
        
        self.animator.startAnimation()
    }
    
}



//MARK: Public Functions
extension InteractiveMenu {

    func show() {
        self.showView()
    }
    
    func hide() {
        self.hideView()
    }
}

// MARK: UISpringTimingParameters init
fileprivate extension UISpringTimingParameters {
    convenience init(damping: CGFloat, response: CGFloat, initialVelocity: CGVector = .zero) {
        let stiffness = pow(2 * .pi / response, 2)
        let damp = 4 * .pi * damping / response
        self.init(mass: 1, stiffness: stiffness, damping: damp, initialVelocity: initialVelocity)
    }
}

//MARK: InstantPanGesture
class InstantPanGesture : UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
 
}

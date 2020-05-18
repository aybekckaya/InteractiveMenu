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
    func interactiveMenuViewScrollableContentView(interactiveMenu : InteractiveMenu)->UIScrollView?
}

protocol InteractiveMenuDelegate {
    // What should be in HERE
    
}

// MARK: Interactive Menu Configuration
class InteractiveMenuConfiguration {
    var containerViewHeight:CGFloat = 600
    var containerViewBackgroundColor:UIColor = #colorLiteral(red: 0.06666666667, green: 0.07058823529, blue: 0.07450980392, alpha: 1)
}





// MARK: Interactive Menu {Class}
class InteractiveMenu: UIView {
     fileprivate let containerViewBottomMarginRate:CGFloat = 0.5 // Addition to bottom of view
    fileprivate let dampingValue:CGFloat = 0.7
    fileprivate let responseValue:CGFloat = 0.5
    
    fileprivate let viewBlurBackground:UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = true
        blurView.alpha = 0.8
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
    fileprivate var delegate:InteractiveMenuDelegate?
    fileprivate var frameClosedPosition:CGRect = CGRect.zero
    fileprivate var frameOpenPosition:CGRect = CGRect.zero
    fileprivate var animator:UIViewPropertyAnimator = UIViewPropertyAnimator()
    fileprivate var viewInContainer:UIView!
    fileprivate var scrollableContentView:UIScrollView?
    fileprivate var panGestureContainerView:InstantPanGesture!
    fileprivate var panGestureScrollableContent:UIPanGestureRecognizer?

    
    fileprivate var totalHeightContainerView:CGFloat {
        return self.configuration.containerViewHeight + self.configuration.containerViewHeight * self.containerViewBottomMarginRate
    }
   
    
    init(embedIn view:UIView , dataSource : InteractiveMenuDataSource , delegate:InteractiveMenuDelegate? , configuration:InteractiveMenuConfiguration) {
        super.init(frame: CGRect.zero)
        self.dataSource = dataSource
        self.configuration = configuration
        self.delegate = delegate
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
        
        self.viewInContainer = self.dataSource.interactiveMenuViewInContainerView(interactiveMenu: self)
        viewInContainer.frame = CGRect(x: 0, y: 0, width: self.containerView.frame.size.width , height: self.configuration.containerViewHeight)
        self.containerView.addSubview(viewInContainer)
        viewInContainer.layoutIfNeeded()
        
        if let scrollableContent = self.dataSource.interactiveMenuViewScrollableContentView(interactiveMenu: self) {
            scrollableContent.addObserver(self, forKeyPath: "contentOffset", options: [.new , .old], context: nil)
            self.panGestureScrollableContent = scrollableContent.gestureRecognizers?.first(where: { rec -> Bool in
                if let _:UIPanGestureRecognizer = rec as? UIPanGestureRecognizer {
                    return true
                }
                return false
            }) as? UIPanGestureRecognizer
            self.scrollableContentView = scrollableContent
            
        }
       
        self.frameOpenPosition = CGRect(x: 0, y: self.frame.size.height - self.configuration.containerViewHeight, width: self.frame.size.width , height: self.totalHeightContainerView)
        self.frameClosedPosition = CGRect(x: 0, y: self.frame.size.height + 50, width: self.frame.size.width , height: self.totalHeightContainerView)
        self.containerView.frame = self.frameClosedPosition
        self.frame = CGRect(x: 0, y: self.frame.size.height, width: self.frame.size.width, height: self.frame.size.height)
     
        let tapGestureBlurView = UITapGestureRecognizer(target: self, action: #selector(blurViewDidTapped))
        self.viewBlurBackground.addGestureRecognizer(tapGestureBlurView)
        
        self.panGestureContainerView = InstantPanGesture(target: self, action: #selector(containerViewPanned(recognizer:)))
        self.panGestureContainerView.name = "PanContent"
        self.panGestureContainerView.setCanDetected(enabled: true)
        self.containerView.addGestureRecognizer(self.panGestureContainerView)
        if self.scrollableContentView != nil {
            self.panGestureContainerView.setCanDetected(enabled: false)
        }
        
        panGestureContainerView.delegate = self
       self.containerView.backgroundColor = self.configuration.containerViewBackgroundColor
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = keyPath , key == "contentOffset" , let scroll = object as? UIScrollView  {
            if scroll.contentOffset.y <= 0 {
                scroll.setContentOffset(CGPoint(x: scroll.contentOffset.x, y: 0), animated: false )
            }
            
        }
    }
    
}

// MARK: Gesture Delegate
extension InteractiveMenu : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let _ = self.panGestureScrollableContent {
            if self.scrollableContentView!.contentOffset.y <= 0 {
                return true
            }
            
            return false
        }
        return true
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
            self.setContainerViewCenter(currentTranslation: currentTranslation)
            self.setBlurViewAlpha()
            recognizer.setTranslation(CGPoint.zero, in: recognizer.view!)
            
            
        case .ended , .cancelled:
            let velocity = recognizer.velocity(in: recognizer.view!).y
            let distance = self.distanceForVelocity(velocity: velocity)
            var prefferedVelocity = velocity / distance
            if prefferedVelocity < 0 { prefferedVelocity = max(-30 , prefferedVelocity) }
            let diffOpenYPos:CGFloat = abs(recognizer.view!.frame.origin.y - self.frameOpenPosition.origin.y)
            let diffCloseYPos:CGFloat = abs(recognizer.view!.frame.origin.y - self.frameClosedPosition.origin.y)
           
            let velocityTreshold:CGFloat = 0.5
            if abs(prefferedVelocity) <= velocityTreshold && diffOpenYPos <= diffCloseYPos {
                self.showView()
            }
            else if abs(prefferedVelocity) <= velocityTreshold && diffOpenYPos > diffCloseYPos {
                self.hideView()
            }
            else if abs(prefferedVelocity) > velocityTreshold && prefferedVelocity < 0 {
                let velocityValue = velocity * 0.01
                self.showView(initialVelocity: velocityValue)
            }
            else if abs(prefferedVelocity) > velocityTreshold && prefferedVelocity >= 0 {
                let velocityValue = velocity * 0.01
                self.hideView(initialVelocity: velocityValue)
            }
            else {
                self.showView()
            }

        default: break
        }
    }
    
    
    
    private func applyRubberBandingIfNeeded(currentTranslation: CGPoint)->Bool {
           let yPosNext =  self.containerView.center.y + currentTranslation.y
           let openedCenterYPos:CGFloat = self.frameOpenPosition.origin.y + self.frameOpenPosition.size.height / 2
           let closedCenterYPos:CGFloat = self.frameClosedPosition.origin.y + self.frameClosedPosition.size.height / 2
           guard yPosNext < openedCenterYPos || yPosNext > closedCenterYPos else { return false }
           let translationY = currentTranslation.y * 0.05
           self.containerView.center = CGPoint(x: self.containerView.center.x, y: self.containerView.center.y + translationY)
           return true
       }
       
       
       private func setContainerViewCenter(currentTranslation: CGPoint) {
           guard self.applyRubberBandingIfNeeded(currentTranslation: currentTranslation) else {
               self.containerView.center = CGPoint(x: self.containerView.center.x, y: self.containerView.center.y + currentTranslation.y)
               return
           }
       }
       
       private func setBlurViewAlpha() {
           let openPosDistance:CGFloat = self.containerView.frame.origin.y - self.frameOpenPosition.origin.y
           let maxDistance:CGFloat = self.frameClosedPosition.origin.y - self.frameOpenPosition.origin.y
           let rateOpened:CGFloat = openPosDistance / maxDistance
           let blurViewAlpha:CGFloat = min(0.7, 1-rateOpened)
           self.viewBlurBackground.alpha = blurViewAlpha
       }
    
     private func distanceForVelocity(velocity:CGFloat)->CGFloat {
        let openedCenterYPos:CGFloat = self.frameOpenPosition.origin.y + self.frameOpenPosition.size.height / 2
        let closedCenterYPos:CGFloat = self.frameClosedPosition.origin.y + self.frameClosedPosition.size.height / 2
        if velocity < 0 { return abs(openedCenterYPos - self.containerView.center.y) }
        return abs(closedCenterYPos - self.containerView.center.y)
    }
    
    fileprivate func showView(initialVelocity: CGFloat = 0 ) {
         if self.animator.isRunning { self.animator.stopAnimation(true) }
        self.frame = CGRect(x: self.frame.origin.x, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        self.viewBlurBackground.alpha = 0.7
        print("Velocity : \(initialVelocity)")
        let timingParameters =  UISpringTimingParameters(damping: self.dampingValue, response: self.responseValue , initialVelocity: CGVector(dx: initialVelocity, dy: initialVelocity))
        self.animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters )
        self.animator.addAnimations {
            self.containerView.frame = self.frameOpenPosition
        }
        self.animator.addCompletion { pos in
            guard pos == .end else { return }
            // fire delegate
        }
        
        self.animator.startAnimation()
    }
    
    fileprivate func hideView(initialVelocity: CGFloat = 0) {
        if self.animator.isRunning { self.animator.stopAnimation(true) }
        
        let timingParameters =  UISpringTimingParameters(damping: self.dampingValue, response: self.responseValue , initialVelocity: CGVector(dx: initialVelocity, dy: initialVelocity))
        self.animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters )
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
    fileprivate var canDetected:Bool = true
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        guard self.canDetected else { return }
        self.state = .began
    }
    
    func setCanDetected(enabled:Bool) {
        self.canDetected = enabled
    }
 
}

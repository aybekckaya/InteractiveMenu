//
//  MainViewController.swift
//  InteractiveMenu
//
//  Created by aybek can kaya on 8.05.2020.
//  Copyright © 2020 aybek can kaya. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    fileprivate var viewTouch:TouchView?
    
    fileprivate let btnOptions:UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImage(systemName: "slider.horizontal.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: UIImage.SymbolWeight.thin) )
        btn.tintColor = UIColor.white
        btn.setImage(icon, for: UIControl.State.normal)
        return btn
    }()
    
    fileprivate var interactiveMenu:InteractiveMenu!
    fileprivate var vcBottom = BottomVC()
   

}

//MARK: LifeCycle
extension MainViewController : InteractiveMenuDataSource , InteractiveMenuDelegate {
    override func viewDidLoad() {
           super.viewDidLoad()
        self.setUpUI()
        let config = InteractiveMenuConfiguration()
        config.containerViewHeight = self.view.frame.size.height - 100
        config.containerViewBackgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        self.interactiveMenu = InteractiveMenu(embedIn: self.view, dataSource: self , delegate: self,  configuration: config)
        
        let tapGesture = InstantPanGesture(target: self, action: #selector(viewDidTapped(recognizer:)))
           tapGesture.delegate = self
           //self.view.addGestureRecognizer(tapGesture)
       }
    
    func interactiveMenuViewInContainerView(interactiveMenu: InteractiveMenu) -> UIView {
        return self.vcBottom.view
    }
    
    func interactiveMenuViewScrollableContentView(interactiveMenu: InteractiveMenu) -> UIScrollView? {
        return self.vcBottom.tableViewContent
    }
}


// MARK: Set Up
extension MainViewController {
    fileprivate func setUpUI() {
        self.view.backgroundColor = #colorLiteral(red: 0.06666666667, green: 0.07058823529, blue: 0.07450980392, alpha: 1)
        self.view.addSubview(self.btnOptions)
        self.btnOptions.activateViewConstraint(constraint: ViewConstraint(top: 48, leading: nil, trailing: -16, bottom: nil, height: 44, width: 44, centerX: nil, centerY: nil), constraintBased: true)
        self.btnOptions.addTarget(self, action: #selector(customizeOnTap), for: UIControl.Event.touchUpInside)
    }
}

// MARK: Actions
extension MainViewController : UIGestureRecognizerDelegate {
    @objc fileprivate func customizeOnTap() {
        self.interactiveMenu.show()
    }
    
    @objc private func viewDidTapped(recognizer:UITapGestureRecognizer) {
         
           let touchPoint = recognizer.location(in: self.view)
           switch recognizer.state {
           case .began :
               let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
               self.viewTouch = TouchView()
               keyWindow!.addSubview(self.viewTouch!)
               self.viewTouch?.beganTouch(point: touchPoint)
               if self.btnOptions.frame.contains(touchPoint) {
                self.customizeOnTap()
               }
           case .changed:
             
               self.viewTouch!.center = touchPoint
           case .ended:
               
               self.viewTouch!.endTouch {
                   
               }
           default:
               break
           }
       }
       
       func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
              return true
          }
}

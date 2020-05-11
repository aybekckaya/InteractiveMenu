//
//  MainViewController.swift
//  InteractiveMenu
//
//  Created by aybek can kaya on 8.05.2020.
//  Copyright © 2020 aybek can kaya. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    fileprivate let btnOptions:UIButton = {
        let btn = UIButton(frame: CGRect.zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        let icon = UIImage(systemName: "slider.horizontal.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: UIImage.SymbolWeight.thin) )
        btn.tintColor = UIColor.white
        btn.setImage(icon, for: UIControl.State.normal)
        return btn
    }()
    
    fileprivate var interactiveMenu:InteractiveMenu!
    fileprivate var vcConfiguration:ConfigurationVC = ConfigurationVC()
   

}

//MARK: LifeCycle
extension MainViewController : InteractiveMenuDataSource {
    override func viewDidLoad() {
           super.viewDidLoad()
        self.setUpUI()
        let config = InteractiveMenuConfiguration()
        config.containerViewHeight = 700 
        self.interactiveMenu = InteractiveMenu(embedIn: self.view, dataSource: self , configuration: config)
    
       }
    
    func interactiveMenuViewInContainerView(interactiveMenu: InteractiveMenu) -> UIView {
        return self.vcConfiguration.view 
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
extension MainViewController {
    @objc fileprivate func customizeOnTap() {
        self.interactiveMenu.show()
    }
}

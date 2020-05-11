//
//  ConfigurationVC.swift
//  InteractiveMenu
//
//  Created by aybek can kaya on 9.05.2020.
//  Copyright © 2020 aybek can kaya. All rights reserved.
//

import UIKit

class ConfigurationVC: UIViewController {
    fileprivate let viewSample:UIView = {
        let vv = UIView(frame: CGRect.zero)
        vv.translatesAutoresizingMaskIntoConstraints = false
        vv.backgroundColor = UIColor.green
        return vv
    }()
}


// MARK: Lifecycle
extension ConfigurationVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.viewSample)
        self.viewSample.activateViewConstraint(constraint: ViewConstraint(top: 36, leading: 36, trailing: -36, bottom: -36, height: nil, width: nil, centerX: nil, centerY: nil), constraintBased: true)
        self.view.backgroundColor = UIColor.clear
        
    }
}

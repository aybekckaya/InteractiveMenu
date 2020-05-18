//
//  BottomVC.swift
//  InteractiveMenu
//
//  Created by aybek can kaya on 12.05.2020.
//  Copyright © 2020 aybek can kaya. All rights reserved.
//

import UIKit

// MARK: BottomCell Class
class BottomCell:UITableViewCell {
    static let reuseIdentifier:String = "BottomCell"
    
    fileprivate let lblTitle:UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.addSubview(self.lblTitle)
        self.lblTitle.activateViewConstraint(constraint: ViewConstraint(top: 8, leading: 8, trailing: -8, bottom: -8, height: nil, width: nil, centerX: nil, centerY: nil), constraintBased: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateCell(title:String) {
        self.lblTitle.text = title
    }
    
    static func height()->CGFloat {
        return 64
    }
    
}

// MARK: BottomVC Class
class BottomVC: UIViewController {
    fileprivate let lblSample:UILabel = {
        let lbl = UILabel(frame: CGRect.zero)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        return lbl
    }()
    
    
    fileprivate let tableViewSample:UITableView = {
        let table = UITableView(frame: CGRect.zero, style: UITableView.Style.plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = UIColor.clear
        table.isScrollEnabled = true
        return table
    }()
    
    var tableViewContent:UITableView {
        return self.tableViewSample
    }
    
}

// MARK: LifeCycle
extension BottomVC {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
}

// MARK: Set Up UI
extension BottomVC {
    fileprivate func setUpUI() {
        self.view.backgroundColor = UIColor.clear
        
        //self.view.backgroundColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        self.view.addSubview(self.tableViewSample)
        self.tableViewSample.fitIntoSuperView()
        self.tableViewSample.register(BottomCell.self, forCellReuseIdentifier: BottomCell.reuseIdentifier)
        self.tableViewSample.delegate = self
        self.tableViewSample.dataSource = self
        self.tableViewSample.reloadData()
        
        /*
        self.view.addSubview(self.lblSample)
        self.lblSample.activateViewConstraint(constraint: ViewConstraint(top: 8, leading: 8, trailing: -8, bottom: -8, height: nil, width: nil, centerX: nil, centerY: nil), constraintBased: true)
        self.lblSample.text = "Hello World :)"
        */
        
    }
}

// MARK: UITableView Datasource / Delegate
extension BottomVC: UITableViewDelegate , UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : BottomCell = tableView.dequeueReusableCell(withIdentifier: BottomCell.reuseIdentifier, for: indexPath) as! BottomCell
        let txt = "Cell - \(indexPath.row)"
        cell.updateCell(title: txt)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BottomCell.height()
    }
}

//
//  SchoolFood.swift
//  Berzan
//
//  Created by Luka Janković on 2017-11-16.
//  Copyright © 2017 ALI Team. All rights reserved.
//

import UIKit

class SchoolFood:UITableViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Other UI setup
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    //UITableView Setup
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }
        
        cell?.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        cell?.textLabel?.text = "Test"
        
        return cell!;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.size.height / 5
    }
}

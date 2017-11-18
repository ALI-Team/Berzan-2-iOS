//
//  SchoolFood.swift
//  Berzan
//
//  Created by Luka Janković on 2017-11-16.
//  Copyright © 2017 ALI Team. All rights reserved.
//

import UIKit
import Alamofire

class SchoolFood:UITableViewController {
    
    var contentArray = [AnyObject]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Tableview setup
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(reloadTableView(_:)), for: .valueChanged)
        
        //Other UI setup
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    //UITableView Setup
    @IBAction func reloadTableView(_ sender: UIRefreshControl) {
        
        Alamofire.request("http://skolmaten.se/berzeliusskolan/?&offset=&limit=1&fmt=json").responseJSON(completionHandler: { responseObject in
            
            if let responseDict = responseObject.result.value as? NSDictionary {
                
                let weeksArray = responseDict["weeks"]! as! NSArray
                let currentWeek = weeksArray[0] as! NSDictionary
                
                self.contentArray = currentWeek["days"] as! Array
                
            } else {
                //Connection error
            }
            
            self.tableView.reloadData()
            self.refreshControl!.endRefreshing()
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        }
        
        cell?.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        cell?.textLabel?.numberOfLines = 0
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = NSLocalizedString("monday", comment: "")
            break
        case 1:
            cell?.textLabel?.text = NSLocalizedString("tuesday", comment: "")
            break
        case 2:
            cell?.textLabel?.text = NSLocalizedString("wednesday", comment: "")
            break
        case 3:
            cell?.textLabel?.text = NSLocalizedString("thursday", comment: "")
            break
        case 4:
            cell?.textLabel?.text = NSLocalizedString("friday", comment: "")
            break
        default:
            break
        }
        
        if contentArray.count > 0 {
            
            var contentString = (contentArray[indexPath.row]["items"]! as! Array).joined(separator: "\n")
            contentString = contentString.replacingOccurrences(of: "\\(.{0,}\\)", with: "", options: .regularExpression)
            
            cell?.detailTextLabel?.text = contentString
        }
        
        return cell!;
    }
}

//
//  SchoolFood.swift
//  Berzan
//
//  Created by Luka Janković on 2017-11-16.
//  Copyright © 2017 ALI Team. All rights reserved.
//

import UIKit
import Alamofire

class SchoolFoodCell:UITableViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var item0Label: UILabel!
    @IBOutlet weak var item1Label: UILabel!
    @IBOutlet weak var item2Label: UILabel!
    @IBOutlet weak var emoji0Label: UILabel!
    @IBOutlet weak var emoji1Label: UILabel!
    @IBOutlet weak var emoji2Label: UILabel!
}

class SchoolFood:UITableViewController {
    
    var contentArray = [AnyObject]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Tableview setup
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(reloadTableView(_:)), for: .valueChanged)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.layoutMargins = UIEdgeInsets.zero
        self.tableView.separatorInset = UIEdgeInsets.zero
        
        //Other UI setup
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.refreshControl!.beginRefreshing()
        self.tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl!.frame.size.height), animated: true)
        
        reloadTableView(self.refreshControl!)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SchoolFoodCell
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.textLabel?.numberOfLines = 0
        
        switch indexPath.row {
        case 0:
            cell.dayLabel.text = NSLocalizedString("monday-short", comment: "")
            break
        case 1:
            cell.dayLabel.text = NSLocalizedString("tuesday-short", comment: "")
            break
        case 2:
            cell.dayLabel.text = NSLocalizedString("wednesday-short", comment: "")
            break
        case 3:
            cell.dayLabel.text = NSLocalizedString("thursday-short", comment: "")
            break
        case 4:
            cell.dayLabel.text = NSLocalizedString("friday-short", comment: "")
            break
        default:
            break
        }
        
        if contentArray.count > 0 {
            
            let content = contentArray[indexPath.row]["items"]! as! NSArray
            
            for i in 0...2 {
                switch i {
                case 0:
                    cell.item0Label.text = (content[i] as! String).replacingOccurrences(of: "\\(.{0,}\\)", with: "", options: .regularExpression)
                    cell.emoji0Label.text = emojiForLine(input: (content[i] as! String))
                    break
                case 1:
                    cell.item1Label.text = (content[i] as! String).replacingOccurrences(of: "\\(.{0,}\\)", with: "", options: .regularExpression)
                    cell.emoji1Label.text = emojiForLine(input: (content[i] as! String))
                    break
                case 2:
                    cell.item2Label.text = (content[i] as! String).replacingOccurrences(of: "\\(.{0,}\\)", with: "", options: .regularExpression)
                    cell.emoji2Label.text = emojiForLine(input: (content[i] as! String))
                    break
                default:
                    break
                }
            }
        }
        
        return cell
    }
    
    func emojiForLine(input: String) -> String {
        let tagRegex = "\\(([^,)]+)"
        
        if input.range(of: tagRegex, options: .regularExpression, range: nil, locale: nil) != nil {
            var tag = input[input.range(of: tagRegex, options: .regularExpression, range: nil, locale: nil)!]
            tag.remove(at: tag.startIndex)
            
            switch tag {
            case "Fågel":
                return "🐦"
            case "Fisk":
                return "🐟"
            case "Ko":
                return "🐄"
            case "Fläsk":
                return "🐖"
            case "Vegetariskt":
                return "🍏"
            default:
                return "b"
            }
        } else {
            return "a"
        }
    }
}

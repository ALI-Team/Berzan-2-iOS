//
//  TodayViewController.h
//  Skolmat
//
//  Created by Luka Janković on 2016-12-10.
//  Copyright © 2016 Luka Janković. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *food_list;
@property (weak, nonatomic) IBOutlet UITableView *food_controller;

@end


//
//  TodayViewController.m
//  Skolmat
//
//  Created by Luka Janković on 2016-12-10.
//  Copyright © 2016 Luka Janković. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://skolmaten.se/berzeliusskolan/?&offset=0&limit=1&fmt=json"]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (data) {
            NSDictionary *food = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (food) {
                
                NSDate *tody = [NSDate date];
                NSDateFormatter *myFormatter = [[NSDateFormatter alloc] init];
                [myFormatter setDateFormat:@"EEEE"];
                [myFormatter setDateFormat:@"c"];
                [myFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"sv_SE"]];
                
                int today = [myFormatter stringFromDate:tody].intValue - 1;
                
                if (today <= 5) {
                    NSDictionary *meals = food[@"weeks"][0][@"days"][today];
                    
                    self.food_list = [NSMutableArray arrayWithArray:meals[@"items"]];
                    
                    [self.food_controller reloadData];
                }
                
                else {
                    self.food_list = @[@"Helg!"].mutableCopy;
                    [self.food_controller reloadData];
                }
            }
            
            else {
                self.food_list = @[@"Ingen data."].mutableCopy;
                [self.food_controller reloadData];
            }
        }
        
        else {
            self.food_list = @[@"Ingen data."].mutableCopy;
            [self.food_controller reloadData];
        }
    }];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
    
    completionHandler(NCUpdateResultNewData);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.food_list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.text = self.food_list[indexPath.row];
    
    return cell;
}

@end


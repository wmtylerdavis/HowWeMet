//
//  HWMFriendStoryViewController.h
//  HowWeMet
//
//  Created by Tyler Davis on 5/22/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWMFriendStoryDataSource.h"

@interface HWMFriendStoryViewController : UIViewController <UITableViewDelegate, HWMDataSourceDelegate>
{
    //NSArray* _dataSources;
    UITapGestureRecognizer* tap;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *noDataLabel;
@property (nonatomic, retain) PFUser* customer;
@property (nonatomic, retain) HWMFriendStoryDataSource* dataSource;

@end

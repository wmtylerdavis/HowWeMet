//
//  HWMRightViewController.h
//  HowWeMet
//
//  Created by Tyler Davis on 4/20/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "HWMGenericDataSource.h"
#import "HWMFacebookDataSource.h"

@interface HWMRightViewController : UIViewController<UITableViewDelegate, HWMDataSourceDelegate, UISearchBarDelegate>
{
    // data sources for each tab
    // featured, facebook, twitter, search
    
    NSArray* _dataSources;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

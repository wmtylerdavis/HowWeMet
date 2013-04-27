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

}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) HWMFacebookDataSource* dataSource;

@end

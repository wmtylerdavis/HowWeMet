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

@interface HWMRightViewController : UIViewController<UITableViewDelegate, HWMDataSourceDelegate, UISearchBarDelegate,UISearchBarDelegate>
{
    UITapGestureRecognizer* tap;
}

@property (strong, nonatomic) IBOutlet UITableViewCell *headerCell;
@property (strong, nonatomic) IBOutlet UILabel *headerLabel;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) HWMFacebookDataSource* dataSource;

@end

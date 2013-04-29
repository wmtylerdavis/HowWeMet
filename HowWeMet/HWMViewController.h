//
//  HWMViewController.h
//  HowWeMet
//
//  Created by Tyler Davis on 4/20/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "HWMGenericDataSource.h"
#import "HWMStoryDataSource.h"
#import "HWMFacebookDataSource.h"

@interface HWMViewController : UIViewController <UITableViewDelegate, HWMDataSourceDelegate, UISearchBarDelegate>
{
    // data sources for each tab
    // featured, facebook, twitter, search
    
    //NSArray* _dataSources;
    UITapGestureRecognizer* tap;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) HWMStoryDataSource* dataSource;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

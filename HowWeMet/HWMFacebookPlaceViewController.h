//
//  HWMFacebookPlaceViewController.h
//  HowWeMet
//
//  Created by Tyler Davis on 5/4/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <FacebookSDK.h>
#import "HWMGenericDataSource.h"
#import "HWMFacebookPlaceDataSource.h"

@class HWMFacebookPlaceViewController;

@interface HWMFacebookPlacePickerTarget : NSObject

@property (nonatomic, retain) id<FBGraphPlace> target;

@end

@protocol HWMFacebookPlacePickerDelegate <NSObject>

-(void)targetPicker:(HWMFacebookPlaceViewController*)targetPicker placeSelected:(HWMFacebookPlacePickerTarget*)target;

@end

@interface HWMFacebookPlaceViewController : UIViewController<UITableViewDelegate, HWMDataSourceDelegate, UISearchBarDelegate,UISearchBarDelegate>
{
    UITapGestureRecognizer* tap;
    NSString* placeSearch;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) HWMFacebookPlaceDataSource* dataSource;
@property (nonatomic, assign) id<HWMFacebookPlacePickerDelegate> delegate;

@end
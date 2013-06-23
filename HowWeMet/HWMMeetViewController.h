//
//  HWMMeetViewController.h
//  HowWeMet
//
//  Created by Tyler Davis on 5/4/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <FacebookSDK.h>
#import "HWMGrayButton.h"

@interface HWMMeetViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>
{
    UIView* photoView;
    UIView* whenView;
    UIView* whereView;
    UIView* storyCell;
    UIView* commentsFooter;
    
    UITapGestureRecognizer* tap;
    BOOL suppressKeyboardEvents;
    UITextField* commentField;
}

@property (strong, nonatomic) UILabel *nameLabel1;
@property (strong, nonatomic) UILabel *nameLabel2;
@property (strong, nonatomic) FBProfilePictureView * profileImage1;
@property (strong, nonatomic) FBProfilePictureView * profileImage2;
@property (nonatomic, retain) UIView* headerController;
@property (nonatomic, retain) UITableView* activityTable;


@property (nonatomic, retain) PFObject* meet;
@property (nonatomic, retain) NSArray* tableData;

@end

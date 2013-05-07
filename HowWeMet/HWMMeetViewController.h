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

@interface HWMMeetViewController : UIViewController <UITableViewDelegate>
{
    UIView* photoView;
    UIView* whenView;
    UIView* whereView;
    UIView* storyCell;
}

@property (strong, nonatomic) UILabel *nameLabel1;
@property (strong, nonatomic) UILabel *nameLabel2;
@property (strong, nonatomic) FBProfilePictureView * profileImage1;
@property (strong, nonatomic) FBProfilePictureView * profileImage2;
@property (nonatomic, retain) UIView* headerController;
@property (strong, nonatomic) IBOutlet UITableView *activityTable;
@property (nonatomic, retain) PFObject* meet;

@end

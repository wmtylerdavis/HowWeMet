//
//  HWMAddStoryViewController.h
//  HowWeMet
//
//  Created by Tyler Davis on 4/26/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EGOImageView.h"
#import "EGOImageButton.h"

@interface HWMAddStoryViewController : UIViewController

@property (strong, nonatomic) IBOutlet EGOImageView *friendAvatar;
@property (strong, nonatomic) IBOutlet UILabel *friendName;
@property (strong, nonatomic) IBOutlet UILabel *friendRelationship;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UITextView *howWeMetStory;
@property (strong, nonatomic) IBOutlet EGOImageButton *howWeMetImage;

@property (nonatomic, retain) PFObject* meet;

- (IBAction)addImageTapped:(id)sender;



@end

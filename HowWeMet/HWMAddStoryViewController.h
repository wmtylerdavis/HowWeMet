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
#import "HWMGrayButton.h"
#import "TDDatePickerController.h"
#import "HWMFacebookImagesViewController.h"

extern const int kAddMeetTypePhotoRoll;
extern const int kAddMeetTypeCamera;
extern const int kAddMeet;
extern NSString* const kMeetActionSheetPickFromPhotoRoll;
extern NSString* const kMeetActionSheetTakePhotoOrVideo;
extern NSString* const kMeetActionSheetPicFromFacebook;
extern NSString* const kMeetActionSheetCancel;

typedef void(^SelectItemCallback)(id sender, id selectedItem);

@interface HWMAddStoryViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate,
TDDatePickerControllerDelegate,EGOImageLoaderObserver, HWMFacebookPhotoPickerDelegate>
{
    UIToolbar* accessoryBar;
    BOOL _isPrivate;
    BOOL dateTimePicked;
    NSDate* selectedDate;
    TDDatePickerController* datePickerView;
    UITapGestureRecognizer *tap;
    NSDateFormatter *dateFormatter;
    UIImage* resizedImage;
}

@property (strong, nonatomic) IBOutlet EGOImageView *friendAvatar;
@property (strong, nonatomic) IBOutlet UILabel *friendName;
@property (strong, nonatomic) IBOutlet UILabel *friendRelationship;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UITextView *howWeMetStory;
@property (strong, nonatomic) IBOutlet UIImageView *howWeMetImage;
@property (strong, nonatomic) IBOutlet HWMGrayButton *createStoryButton;
@property (strong, nonatomic) IBOutlet HWMGrayButton *privacyButton;
@property (nonatomic, assign) int imageType;

@property (nonatomic, retain) PFObject* meet;
@property (strong, nonatomic) IBOutlet HWMGrayButton *followingRelationship;
@property (strong, nonatomic) IBOutlet HWMGrayButton *buddiesRelationship;
@property (strong, nonatomic) IBOutlet HWMGrayButton *coworkersRelationship;
@property (strong, nonatomic) IBOutlet HWMGrayButton *acqRelationship;
@property (strong, nonatomic) IBOutlet HWMGrayButton *questionRelationship;



- (IBAction)relationshipButtonTapped:(id)sender;
- (IBAction)whenYouMetTap:(id)sender;

- (IBAction)addImageTapped:(id)sender;

- (IBAction)privacyTapped:(id)sender;

- (IBAction)createStoryTapped:(id)sender;


@end

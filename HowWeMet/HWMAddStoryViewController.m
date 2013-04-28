//
//  HWMAddStoryViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/26/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMAddStoryViewController.h"
#import "HowWeMetAPI.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>

const int kAddEvidenceTypePhotoRoll=0;
const int kAddEvidenceTypeCamera=1;
NSString* const kEvidenceActionSheetPickFromPhotoRoll=@"Pick from Photo Roll";
NSString* const kEvidenceActionSheetTakePhotoOrVideo=@"Take Photo or Video";
NSString* const kEvidenceActionSheetCancel=@"Cancel";

@interface HWMAddStoryViewController ()

@end

@implementation HWMAddStoryViewController

@synthesize meet = _meet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[self registerForKeyboardNotifications];
    }
    return self;
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, -kbSize.height, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    [self.view endEditing:YES];
}

-(void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    [textView setText:@"We met "];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Here's the Story";
    self.howWeMetStory.delegate = self;
    //[self setAccessoryForTextField:self.howWeMetStory];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d y"];
    
    tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(keyboardWillHide:)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refresh];
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setFriendAvatar:nil];
    [self setFriendName:nil];
    [self setFriendRelationship:nil];
    [self setTimeLabel:nil];
    [self setHowWeMetStory:nil];
    [self setHowWeMetImage:nil];
    [self setCreateStoryButton:nil];
    [self setPrivacyButton:nil];
    [super viewDidUnload];
}

-(void)setMeet:(PFObject *)meet
{
    _meet = meet;
    
}

-(PFObject*)meet
{
    return _meet;
}

- (IBAction)relationshipButtonTapped:(id)sender {
}

-(void)refreshDate
{
    self.timeLabel.text= [dateFormatter stringFromDate:selectedDate];
}

-(void)datePickerSetDate:(TDDatePickerController *)viewController
{
    selectedDate=viewController.datePicker.date;
    [self dismissSemiModalViewController:viewController];
    tap.enabled = YES;
    
    [self refreshDate];
    dateTimePicked=YES;
}

-(void)datePickerCancel:(TDDatePickerController *)viewController
{
    tap.enabled = YES;
    [self dismissSemiModalViewController:viewController];
}

-(void)datePickerClearDate:(TDDatePickerController *)viewController
{
    selectedDate=nil;
    dateTimePicked=NO;
}

- (IBAction)whenYouMetTap:(id)sender {
    
    datePickerView = [[TDDatePickerController alloc]
                      initWithNibName:@"TDDatePickerController"
                      bundle:nil];
    datePickerView.delegate = self;
    
    [self.view endEditing:YES];
    tap.enabled = NO;
    [self presentSemiModalViewController:datePickerView];
    
}

-(void)refresh
{
    if(self.meet==nil) return;
    
    PFFile* imgFileData=[self.meet objectForKey:@"Photo"];
    [imgFileData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        UIImage* meetImage=[UIImage imageWithData:data];
//        self.howWeMetImage.imageView = meetImage;
    }];
    
    self.friendName.text=[self.meet objectForKey:@"Name"];
//    self.friendRelationship = [self.meet objectForKey:@"Relationship"];
    [self.friendAvatar setImageURL:[self.meet objectForKey:@"AvatarURL"]];
    
}

-(void)imagePickerActionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* buttonText=[actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonText isEqualToString:kEvidenceActionSheetPickFromPhotoRoll])
    {
        self.imageType=kAddEvidenceTypePhotoRoll;
    }
    else if([buttonText isEqualToString:kEvidenceActionSheetTakePhotoOrVideo])
    {
        self.imageType=kAddEvidenceTypeCamera;
    }
    else if (buttonIndex == [actionSheet cancelButtonIndex])
    {
        return;
    }

    [self showImagePicker];
   
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if(CFStringCompare((__bridge CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        resizedImage=[info objectForKey:UIImagePickerControllerOriginalImage];
        [self.howWeMetImage setImage:resizedImage forState:UIControlStateNormal];
        
        [[picker presentingViewController] dismissViewControllerAnimated:YES completion:^(void) {
            if(self.imageType!=kAddEvidenceTypePhotoRoll) // don't duplicate images in the photo roll
                UIImageWriteToSavedPhotosAlbum([info objectForKey:UIImagePickerControllerOriginalImage], nil, nil, nil);
        }];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch(actionSheet.tag)
    {
        default:
        case 0:
            [self imagePickerActionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
            break;
    }
}

-(void) showImagePicker
{
    UIImagePickerController* imagePicker=[[UIImagePickerController alloc] init];
    
    [imagePicker setDelegate:self];
    imagePicker.allowsEditing=YES;
    
    if(self.imageType==kAddEvidenceTypePhotoRoll)
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        imagePicker.mediaTypes =[[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage,nil];
    }
    else if(self.imageType==kAddEvidenceTypeCamera)
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker.mediaTypes =[[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
    }
    
    [self presentViewController:imagePicker animated:YES completion:^(void){
    }];

}


- (IBAction)addImageTapped:(id)sender {
    
    UIActionSheet* actionSheet;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kEvidenceActionSheetTakePhotoOrVideo, kEvidenceActionSheetPickFromPhotoRoll, nil];
    else
        actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kEvidenceActionSheetPickFromPhotoRoll, nil];
    
    [actionSheet showInView:[self.navigationController view]];
}

- (IBAction)privacyTapped:(id)sender {
    _isPrivate = YES;
}

- (IBAction)createStoryTapped:(id)sender {
    
    PFObject* newMeet;
    
    if(self.meet!=nil)
    {
        newMeet=self.meet;
    }
    else
        newMeet=[PFObject objectWithClassName:@"Meet"];
    
    if (selectedDate) {
        [newMeet setObject:[dateFormatter stringFromDate:selectedDate] forKey:@"Date"];
    }
    else if (![newMeet objectForKey:@"Date"]) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Without a date it's like it never happened..." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil] show];
        return;
    }
    
    if(resizedImage!=nil)
    {
        NSData* imageData=UIImageJPEGRepresentation(resizedImage, 0.8);
        PFFile* imageFile=[PFFile fileWithName:[NSString stringWithFormat:@"%@.jpg", [[NSProcessInfo processInfo] globallyUniqueString]] data:imageData];
        
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [newMeet setObject:imageFile forKey:@"Photo"];
            [self triggerSave:newMeet];
        } progressBlock:^(int percentDone) {
        }];
    }
    
}

-(void)triggerSave:(PFObject*)newMeet
{
    [newMeet setObject:[self.meet objectForKey:@"FacebookID"]  forKey:@"FacebookID"];
    [newMeet setObject:[PFUser currentUser] forKey:@"Owner"];
    [newMeet setObject:self.howWeMetStory.text forKey:@"Story"];
    if(_isPrivate)
    {
        newMeet.ACL=[PFACL ACLWithUser:[PFUser currentUser]];
    }
    [newMeet saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded)
        {
            NSLog(@"Holy crap");
        }
    }];
}
@end

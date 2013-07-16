//
//  HWMAddStoryViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/26/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMAddStoryViewController.h"
#import "HowWeMetAPI.h"
#import "HWMFacebookImagesViewController.h"
#import "HWMFacebookPlaceViewController.h"
#import "HWMViewController.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import "KGModal.h"
#import "HWMFBOpenGraphAction.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>

const int kAddMeetTypePhotoRoll=0;
const int kAddMeetTypeCamera=1;
const int kAddMeetTypeFacebook=2;
NSString* const kMeetActionSheetPickFromPhotoRoll=@"Pick from Photo Roll";
NSString* const kMeetActionSheetTakePhotoOrVideo=@"Take Photo or Video";
NSString* const kMeetActionSheetPicFromFacebook=@"Pick from Facebook Photos";
NSString* const kMeetActionSheetCancel=@"Cancel";

@interface HWMAddStoryViewController ()
- (id<HWMFBOpenGraphObject>)meetObjectforMeet:(NSString *)meet : (NSString*) text;
@end

@implementation HWMAddStoryViewController

@synthesize meet = _meet;
@synthesize howWeMetImage;
@synthesize scrollView;
@synthesize selectedPlace = _selectedPlace;
@synthesize shouldShowTrash = _shouldShowTrash;

// FBSample logic
// This is a helper function that returns an FBGraphObject representing a meal
- (id<HWMFBOpenGraphObject>)meetObjectforMeet:(NSString *)meet : (NSString*) text {
    
    // This URL is specific to this sample, and can be used to
    // create arbitrary OG objects for this app; your OG objects
    // will have URLs hosted by your server.
//    NSString *format =
//    @"https://guarded-wave-5266.herokuapp.com/request.php?"
//    @"fb:app_id=118613704982422&og:type=%@&"
//    @"og:title=%@&og:description=%%22%@%%22&howmuchapp:requestID=%@";

    
    // We create an FBGraphObject object, but we can treat it as
    // an SCOGMeal with typed properties, etc. See <FacebookSDK/FBGraphObject.h>
    // for more details.
    // We create an FBGraphObject object, but we can treat it as an SCOGMeal with typed
    // properties, etc. See <FacebookSDK/FBGraphObject.h> for more details.
    id<HWMFBOpenGraphObject> result = (id<HWMFBOpenGraphObject>)[FBGraphObject graphObject];
    
    // Give it a URL that will echo back the name of the meal as its title,
    // description, and body.
//    NSLog(@"%@", _thisRequest.requestID);
   // result.url = [NSString stringWithFormat:profile,
//                  @"howmuchapp:request", request, text, (long)_thisRequest.requestID];
    
    return result;
}

- (void) postStory {
    // First create the Open Graph meal object for the meal we ate.
    id<HWMFBOpenGraphObject> requestObject = [self meetObjectforMeet :[_meet objectForKey:@"Story"] :[_meet objectForKey:@"Relationship"]];
    
    // Now create an Open Graph eat action with the meal, our location,
    // and the people we were with.
    id<HWMMeetAction> action =
    (id<HWMMeetAction>)[FBGraphObject graphObject];
    action.meet = requestObject;
    NSString * openGraphMessage = [NSString stringWithFormat:@"%@", self.howWeMetStory.text];
    action.message = openGraphMessage;
    action.place = [self.meet objectForKey:@"Place"];
    
    NSDateFormatter* fbDateFormatter = [[NSDateFormatter alloc] init];
    [fbDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString* dateString= [NSString stringWithFormat:@"%@T15:18:26-08:00", [fbDateFormatter stringFromDate:[self.meet objectForKey:@"DateDate"]]];
    NSString* dateString2= [NSString stringWithFormat:@"%@T15:18:27-08:00", [fbDateFormatter stringFromDate:[self.meet objectForKey:@"DateDate"]]];
    
    NSString* post = [NSString stringWithFormat:@"me/howwemetapp:meet?profile=%@&start_time=%@&end_time=%@&fb:explicitly_shared=true",[self.meet objectForKey:@"FacebookID"], dateString, dateString2];
    [FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, FBLoggingBehaviorFBURLConnections, nil]];
    
    [FBRequestConnection startForPostWithGraphPath:post
                                       graphObject:action
                                 completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         NSString *alertText;
         if (!error) {
             alertText = [NSString stringWithFormat:
                          @"Posted Meet to Facebook"];
         } else {
             NSLog(@"%@", error);
             alertText = [NSString stringWithFormat:
                          @"Sorry we couldn't post to Facebook"];
         }
         [[[UIAlertView alloc] initWithTitle:@"Facebook"
                                     message:alertText
                                    delegate:nil
                           cancelButtonTitle:@"Thanks!"
                           otherButtonTitles:nil]
          show];
     }
     ];
}

// FBSample logic
// Creates the Open Graph Action.
- (void)postOpenGraphAction {
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        // Permission hasn't been granted, so ask for publish_actions
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                             if (FBSession.activeSession.isOpen && !error) {
                                                 // Publish the story if permission was granted
                                                 [self postStory];
                                             }
                                         }];
    } else {
        // If permissions present, publish the story
        [self postStory];
    }
}

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
    tap.enabled = YES;
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, -kbSize.height, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    tap.enabled = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    [self.view endEditing:YES];
}

-(void)dismissKeyboard
{
    tap.enabled = NO;
    [self.view endEditing:YES];
}

-(void)setAccessoryForTextField:(id)field
{
    if(accessoryBar==nil)
    {
        accessoryBar=[[UIToolbar alloc] init];
        UIBarButtonItem* doneButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissKeyboard)];
        UIBarButtonItem* space=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [accessoryBar setItems:@[space, doneButton]];
        [accessoryBar sizeToFit];
    }
    [field setInputAccessoryView:accessoryBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Edit Story";
    
    self.scrollView=[[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.scrollView addSubview:self.view];
    self.view=self.scrollView;
    self.view.clipsToBounds = YES;
    self.scrollView.contentSize=CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+(self.view.frame.size.height/2)+5);
    [self.scrollView setScrollEnabled:NO];
    // [self registerForKeyboardNotifications];
     
    if (_shouldShowTrash) {
        UIBarButtonItem* deleteButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTapped:)];
        
        [self.navigationItem setRightBarButtonItem:deleteButton];
    }
    
    self.howWeMetStory.delegate = self;
    [self setAccessoryForTextField:self.howWeMetStory];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d y"];
    
    tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(keyboardWillHide:)];
    
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    
    [self refresh];
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
    [self setFollowingRelationship:nil];
    [self setBuddiesRelationship:nil];
    [self setCoworkersRelationship:nil];
    [self setAcqRelationship:nil];
    [self setQuestionRelationship:nil];
    [self setLocationLabel:nil];
    [self setFamiliesRelationship:nil];
    [self setClassmatesRelationship:nil];
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
    
    UIView* relationshipDialog=[[[NSBundle mainBundle] loadNibNamed:@"HWMrelationships" owner:self options:nil] objectAtIndex:0];
    relationshipDialog.backgroundColor = [[HowWeMetAPI sharedInstance] redColor];
    relationshipDialog.clipsToBounds = YES;
    relationshipDialog.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [[KGModal sharedInstance] setShowCloseButton:YES];
    [[KGModal sharedInstance] setTapOutsideToDismiss:YES];
    
    [[KGModal sharedInstance] showWithContentView:relationshipDialog andAnimated:YES];
}

- (IBAction)relationshipSelected:(id)sender {
    HWMGrayButton *resultButton = (HWMGrayButton *)sender;
    NSString* relationshipTitle = resultButton.title;
    if([relationshipTitle isEqualToString:@"?????"])
    {
        [self.meet setObject:@"question" forKey:@"Relationship"];
    }
    else {
        [self.meet setObject:relationshipTitle forKey:@"Relationship"];
    }
    [_friendRelationship setText:relationshipTitle];
    [[KGModal sharedInstance] hide];

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
    
    if ([self.meet objectForKey:@"Photo"] != [NSNull null]) {
        PFFile* imgFileData=[self.meet objectForKey:@"Photo"];
        [imgFileData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage* meetImage=[UIImage imageWithData:data];
            [self.howWeMetImage setImage:meetImage];
        }];
    }
    if ([self.meet objectForKey:@"Date"]) {
        self.timeLabel.text = [self.meet objectForKey:@"Date"];
    }
    
    if ([self.meet objectForKey:@"Relationship"]) {
        _friendRelationship.text = [self.meet objectForKey:@"Relationship"];
    }
    
    if ([self.meet objectForKey:@"Place"])
    {
        [_locationLabel setText:[[self.meet objectForKey:@"Place"] objectForKey:@"name"]];
    }
    
    if ([self.meet objectForKey:@"Story"]) {
        self.howWeMetStory.text = [self.meet objectForKey:@"Story"];
    }
    
    self.friendName.text=[self.meet objectForKey:@"FriendName"];
    [self.friendAvatar setImageURL:[self.meet objectForKey:@"FriendAvatarURL"]];
    
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    if ([self.meet objectForKey:@"Story"]) {
        self.howWeMetStory.text = [self.meet objectForKey:@"Story"];
    }
    else {
        self.howWeMetStory.text = @"We met ";
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    [self.meet setObject:self.howWeMetStory.text forKey:@"Story"];
    return YES;
}

-(void)imagePickerActionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* buttonText=[actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonText isEqualToString:kMeetActionSheetPickFromPhotoRoll])
    {
        self.imageType=kAddMeetTypePhotoRoll;
    }
    else if([buttonText isEqualToString:kMeetActionSheetTakePhotoOrVideo])
    {
        self.imageType=kAddMeetTypeCamera;
    }
    else if([buttonText isEqualToString:kMeetActionSheetPicFromFacebook])
    {
        self.imageType=kAddMeetTypeFacebook;
    }
    else if (buttonIndex == [actionSheet cancelButtonIndex])
    {
        return;
    }

    [self showImagePicker];
   
}

- (void)resizeSelectedImage:(UIImage*)image
{
    resizedImage=image;
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [howWeMetImage setImage:resizedImage];
    });
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:^(void) {
        UIImageWriteToSavedPhotosAlbum([info objectForKey:UIImagePickerControllerOriginalImage], nil, nil, nil);
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            [self resizeSelectedImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
        });

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
    BOOL imagePick = YES;
    
    if(self.imageType==kAddMeetTypePhotoRoll)
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        imagePicker.mediaTypes =[[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage,nil];
    }
    else if(self.imageType==kAddMeetTypeCamera)
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker.mediaTypes =[[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
    }
    else if(self.imageType==kAddMeetTypeFacebook)
    {
        imagePick = NO;
        [self pickFacebookImage];
    }
    
    if (imagePick) {
        [self presentViewController:imagePicker animated:YES completion:^(void){
        }];
    }

}

-(void)targetPicker:(HWMFacebookImagesViewController*)targetPicker targetSelected:(HWMFacebookPhotoPickerTarget *)target
{
    [self.navigationController popToViewController:self animated:YES];
    //photo stuff
    UIImage* meetImage=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: target.imageURL]]];
    [self resizeSelectedImage:meetImage];
}

-(void)targetPicker:(HWMFacebookPlaceViewController*)targetPicker placeSelected:(HWMFacebookPlacePickerTarget*)target
{
    [self.navigationController popToViewController:self animated:YES];
    _selectedPlace = (id<FBGraphPlace>)target;
    [self.meet setObject:target forKey:@"Place"];
    [self refresh];
}

-(void) pickFacebookImage
{
    HWMFacebookImagesViewController* imageView = [[HWMFacebookImagesViewController alloc] init];
    imageView.delegate=self;
    imageView.facebookID = [self.meet objectForKey:@"FacebookID"];
    [self.navigationController pushViewController:imageView animated:YES];
}

- (IBAction)addImageTapped:(id)sender {
    
    UIActionSheet* actionSheet;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kMeetActionSheetTakePhotoOrVideo, kMeetActionSheetPickFromPhotoRoll, kMeetActionSheetPicFromFacebook,nil];
    else
        actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kMeetActionSheetPickFromPhotoRoll, kMeetActionSheetPicFromFacebook, nil];
    
    [actionSheet showInView:[self.navigationController view]];
}

- (IBAction)privacyTapped:(id)sender {
    if (_isPrivate) {
        _isPrivate = NO;
        [self.privacyButton setTitle:@"Public" forState:UIControlStateNormal];
        //self.privacyButton.titleLabel.text = @"Public";
    }
    else {
        _isPrivate = YES;
        [self.privacyButton setTitle:@"Private" forState:UIControlStateNormal];
        //self.privacyButton.titleLabel.text=@"Private";
    }
}

- (IBAction)createStoryTapped:(id)sender {
    
    PFObject* newMeet;
    
    if(self.meet!=nil)
    {
        newMeet=self.meet;
    }
    
    if (selectedDate) {
        [newMeet setObject:selectedDate forKey:@"DateDate"];
        [newMeet setObject:[dateFormatter stringFromDate:selectedDate] forKey:@"Date"];
    }
    else if (![newMeet objectForKey:@"Date"]) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Without a date it's like it never happened...You can fudge it a little, if necessary." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil] show];
        return;
    }
    
    if (![newMeet objectForKey:@"Relationship"]) {
        [newMeet setObject:@"Following" forKey:@"Relationship"];
    }
    if (![newMeet objectForKey:@"Place"]) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"Where did this happen then? Space?" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil] show];
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
    else if([self.meet objectForKey:@"Photo"] == [NSNull null]) {
        [newMeet setObject:[NSNull null] forKey:@"Photo"];
        [self triggerSave:newMeet];
    }
    else {
        [self triggerSave:newMeet];
    }
    
}

- (IBAction)addLocationTapped:(id)sender {
    HWMFacebookPlaceViewController* placePicker = [[HWMFacebookPlaceViewController alloc] init];
    placePicker.delegate = self;
    [self.navigationController pushViewController:placePicker animated:YES];
}

-(void)triggerSave:(PFObject*)newMeet
{
    [newMeet setObject:[self.meet objectForKey:@"FacebookID"]  forKey:@"FacebookID"];
    [newMeet setObject:[PFUser currentUser] forKey:@"Owner"];
    [newMeet setObject:[[PFUser currentUser] objectForKey:@"Name"] forKey:@"OwnerName"];
    [newMeet setObject:[[PFUser currentUser] objectForKey:@"AvatarURL"] forKey:@"OwnerAvatar"];
    [newMeet setObject:[[PFUser currentUser] objectForKey:@"facebookID"] forKey:@"OwnerFacebookID"];
    [newMeet setObject:self.howWeMetStory.text forKey:@"Story"];
    if(_isPrivate)
    {
        newMeet.ACL=[PFACL ACLWithUser:[PFUser currentUser]];
    }
    [newMeet saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded)
        {
            if ([[HowWeMetAPI sharedInstance] automaticFacebookPost] && !_isPrivate) {
                 [self postOpenGraphAction];
            }
            NSLog(@"Holy crap");
            HWMViewController* mainView = [[HWMViewController alloc] init];
            self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:mainView];
        }
    }];
}

-(void)deleteTapped:(id)sender
{
    if(self.meet!=nil)
    {
        //[DejalBezelActivityView activityViewForView:self.view withLabel:@"Deleting..."];
        [self.meet deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            [[self.navigationController presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end

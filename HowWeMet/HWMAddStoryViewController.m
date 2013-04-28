//
//  HWMAddStoryViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/26/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMAddStoryViewController.h"
#import "HowWeMetAPI.h"

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

- (IBAction)addImageTapped:(id)sender {
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

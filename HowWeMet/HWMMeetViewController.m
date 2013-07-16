//
//  HWMMeetViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 5/4/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMMeetViewController.h"
#import "HWMAddStoryViewController.h"
#import "HWMReportViewController.h"

@interface HWMMeetViewController ()

@end

@implementation HWMMeetViewController

@synthesize nameLabel1 = _nameLabel1;
@synthesize nameLabel2 = _nameLabel2;
@synthesize profileImage1 = _profileImage1;
@synthesize profileImage2 = _profileImage2;
@synthesize activityTable = _activityTable;
@synthesize headerController = _headerController;
@synthesize tableData = _tableData;

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"The Story";
    
    if ([[_meet objectForKey:@"OwnerFacebookID"] isEqual:[[PFUser currentUser] objectForKey:@"facebookID"] ]) {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editMeet:)]];
    }
    else {
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Report" style:UIBarButtonItemStylePlain target:self action:@selector(reportMeet:)]];
    }
    
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(keyboardWillHide:)];
    
    [self.view addGestureRecognizer:tap];
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableData==nil)
        return 44.0f;
    
    float startingHeight=44.0f;
    
    PFUser* userData=[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"FromUser"];
    NSString* activityLabel=[NSString stringWithFormat:@"%@: %@", [userData objectForKey:@"Name"], [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"Content"]];
    
    CGSize theStringSize = [activityLabel sizeWithFont:[UIFont systemFontOfSize:12.0f] constrainedToSize:CGSizeMake(254, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    
    return startingHeight+theStringSize.height;
}

-(void)loadView
{
    [super loadView];
    
    self.activityTable=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-47)];
    self.activityTable.autoresizingMask=UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.activityTable];
    
    self.activityTable.tableHeaderView=[[[NSBundle mainBundle] loadNibNamed:@"HWMMeetViewHeader" owner:self options:nil] objectAtIndex:0];
    self.activityTable.tableHeaderView.autoresizingMask =YES;
    self.activityTable.tableHeaderView.clipsToBounds = YES;
    
    self.profileImage1 = (FBProfilePictureView*)[_activityTable.tableHeaderView viewWithTag:1];
    self.profileImage2 = (FBProfilePictureView*)[_activityTable.tableHeaderView viewWithTag:2];
    self.nameLabel1 = (UILabel*)[_activityTable.tableHeaderView viewWithTag:3];
    self.nameLabel2 = (UILabel*)[_activityTable.tableHeaderView viewWithTag:4];
    
    self.profileImage1.profileID = [self.meet objectForKey:@"OwnerFacebookID"];
    self.profileImage2.profileID = [self.meet objectForKey:@"FacebookID"];
    self.nameLabel1.font=[UIFont fontWithName:@"Chalkduster" size:12.0f];
    self.nameLabel2.font=[UIFont fontWithName:@"Chalkduster" size:12.0f];
    self.nameLabel1.text = [self.meet objectForKey:@"OwnerName"];
    self.nameLabel2.text = [self.meet objectForKey:@"FriendName"];
    [self.nameLabel1 setAdjustsFontSizeToFitWidth:YES];
    [self.nameLabel1 setMinimumScaleFactor:0.5];
    [self.nameLabel2 setAdjustsFontSizeToFitWidth:YES];
    [self.nameLabel2 setMinimumScaleFactor:0.5];
    
    self.activityTable.delegate=self;
    self.activityTable.dataSource= self;
    self.activityTable.separatorColor=[UIColor whiteColor];
    self.activityTable.backgroundColor=[UIColor darkGrayColor];

    [self loadInteractables];
    self.activityTable.tableHeaderView=self.activityTable.tableHeaderView;
    [self.view addSubview:self.activityTable];
    
    //
    // Footer begins.
    commentsFooter=[[[NSBundle mainBundle] loadNibNamed:@"HWMCommentFooter" owner:self options:nil] objectAtIndex:0];
    //commentsFooter.frame=CGRectMake(0, self.view.frame.size.height-self.view.frame.origin.y-26, 320, 47);
    commentsFooter.frame=CGRectMake(0, self.view.frame.size.height, commentsFooter.frame.size.width, commentsFooter.frame.size.height);
    self.view.frame=CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height+commentsFooter.frame.size.height);
    commentsFooter.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    commentsFooter.backgroundColor = [[HowWeMetAPI sharedInstance] redColor];
    commentsFooter.userInteractionEnabled=YES;
    //commentsFooter.clipsToBounds=YES;
    
    [self.view addSubview:commentsFooter];
    
    commentField=(UITextField*)[commentsFooter viewWithTag:1];
    
    UIButton* addCommentButton=(UIButton*)[commentsFooter viewWithTag:2];
    [addCommentButton addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view layoutSubviews];
}

-(void)loadInteractables
{
    if([_meet objectForKey:@"Photo"])
    {
        [self loadPhoto];
    }
    whenView=[[[NSBundle mainBundle] loadNibNamed:@"AddieHeaderCell" owner:self options:nil] objectAtIndex:0];
    whenView.frame=CGRectMake(0, 230, whenView.frame.size.width, whenView.frame.size.height);
    whenView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    whereView=[[[NSBundle mainBundle] loadNibNamed:@"AddieHeaderCell" owner:self options:nil] objectAtIndex:0];
    whereView.frame=CGRectMake(0, 230, whereView.frame.size.width, whereView.frame.size.height);
    
    storyCell=[[[NSBundle mainBundle] loadNibNamed:@"HWMMeetStoryCell" owner:self options:nil] objectAtIndex:0];
    
    UILabel* storyLabel = (UILabel*)[storyCell viewWithTag:1];
    storyLabel.font= [UIFont fontWithName:@"Helvetica" size:11.0];
    storyLabel.text = [NSString stringWithFormat:@"%@\n%@",[_meet objectForKey:@"Relationship"],[_meet objectForKey:@"Story"]];
    [storyCell sizeToFit];
    
    float height=storyCell.frame.size.height;
    
    NSString* cellText=storyLabel.text;
    CGSize stringSize=[cellText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f] constrainedToSize:CGSizeMake(254, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    height=height + (abs(stringSize.height) - 70);
    
    NSMutableAttributedString* string=[[NSMutableAttributedString alloc] initWithString:cellText];
    [string addAttribute:NSForegroundColorAttributeName value:[[HowWeMetAPI sharedInstance] redColor] range:[[string string] rangeOfString:[_meet objectForKey:@"Relationship"]]];
    storyLabel.attributedText=string;
    
    storyCell.frame=CGRectMake(storyCell.frame.origin.x, storyCell.frame.origin.y, storyCell.frame.size.width, height);
    storyCell.frame=CGRectMake(0, 230, storyCell.frame.size.width, storyCell.frame.size.height);
//    
    CGRect headerFrame=self.activityTable.tableHeaderView.frame;
    self.activityTable.tableHeaderView.frame=CGRectMake(headerFrame.origin.x, headerFrame.origin.y, headerFrame.size.width, headerFrame.size.height+whenView.frame.size.height+whereView.frame.size.height+storyCell.frame.size.height);
    whenView.frame=CGRectMake(0, headerFrame.size.height, whenView.frame.size.width, whenView.frame.size.height);
    whereView.frame=CGRectMake(0, headerFrame.size.height+whenView.frame.size.height, whereView.frame.size.width, whereView.frame.size.height);
    storyCell.frame=CGRectMake(10, headerFrame.size.height+whenView.frame.size.height+whereView.frame.size.height, storyCell.frame.size.width, storyCell.frame.size.height);
    [self.activityTable.tableHeaderView addSubview:whenView];
    [self.activityTable.tableHeaderView addSubview:whereView];
    [self.activityTable.tableHeaderView addSubview:storyCell];
    

    UILabel* whenLabel = (UILabel*)[whenView viewWithTag:1];
    whenLabel.font= [UIFont fontWithName:@"Chalkduster" size:14.0];
    whenLabel.text = @"When";
    UILabel* timeLabel=(UILabel*)[whenView viewWithTag:2];
    timeLabel.font= [UIFont fontWithName:@"Helvetica" size:12.0];
    timeLabel.text = [self.meet objectForKey:@"Date"];
    
    UILabel* whereLabel = (UILabel*)[whereView viewWithTag:1];
    whereLabel.font= [UIFont fontWithName:@"Chalkduster" size:14.0];
    whereLabel.text = @"Where";
    UILabel* placeLabel=(UILabel*)[whereView viewWithTag:2];
    placeLabel.font= [UIFont fontWithName:@"Helvetica" size:12.0];
    placeLabel.text = [[self.meet objectForKey:@"Place"] objectForKey:@"name"];
    
    //
    // When you resize a table header after it's been assigned,
    // you need to re-assign it for the tableView to pick up the new
    // dimensions.
    [self.activityTable.tableHeaderView layoutSubviews];
}

-(void)refresh
{
    if(self.meet==nil) return;

    PFQuery* activityQuery=[PFQuery queryWithClassName:@"Activity"];
    [activityQuery whereKey:@"Meet" equalTo:self.meet];
    [activityQuery includeKey:@"FromUser"];
    [activityQuery includeKey:@"Meet"];
    [activityQuery whereKey:@"Type" containedIn:[NSArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil]];
    [activityQuery orderByAscending:@"createdAt"];
    
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error)
        {
            self.tableData=objects;
            NSLog(@"%@", objects);
            [self.activityTable   reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        else {
            NSLog(@"Error! %@", error.description);
        }
    }];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self registerForKeyboardNotifications];
    //[self refresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self refresh];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[self.activityTable dequeueReusableCellWithIdentifier:@"HWMCommentCell"];
    if(cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"HWMCommentCell" owner:self options:nil] objectAtIndex:0];
    }
    [cell contentView].backgroundColor = [UIColor darkGrayColor];
    UILabel* commentLabel = (UILabel*)[cell viewWithTag:1];
    commentLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    
    PFUser* userData=[[self.tableData objectAtIndex:indexPath.row] objectForKey:@"FromUser"];
    NSString* commentText=[NSString stringWithFormat:@"%@: %@", [userData objectForKey:@"Name"], [[self.tableData objectAtIndex:indexPath.row] objectForKey:@"Content"]];
    commentLabel.text = commentText;
    
    return cell;
}

-(void)loadPhoto
{
    photoView=[[[NSBundle mainBundle] loadNibNamed:@"HWMPhotoView" owner:self options:nil] objectAtIndex:0];
    photoView.frame=CGRectMake(0, 90, photoView.frame.size.width, photoView.frame.size.height);
    
    UIImageView* image=(UIImageView*)[photoView viewWithTag:1];
    
    PFFile* imgFileData=[_meet objectForKey:@"Photo"];
    [imgFileData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage* feedImage=[UIImage imageWithData:data];
            image.image=feedImage;
        }];
    
    CGRect headerFrame=self.activityTable.tableHeaderView.frame;
    
    //photo
    self.activityTable.tableHeaderView.frame=CGRectMake(headerFrame.origin.x, headerFrame.origin.y,headerFrame.size.width, headerFrame.size.height+photoView.frame.size.height);
    photoView.frame=CGRectMake(0, headerFrame.size.height, photoView.frame.size.width, photoView.frame.size.height);
    [self.activityTable.tableHeaderView addSubview:photoView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.tableData==nil) return 0;
    return self.tableData.count;
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   //
}

-(void)addComment:(id)sender
{
    //UITextField* commentField=(UITextField*)[self.tableView.tableFooterView viewWithTag:1];
    if(commentField.text==nil || commentField.text.length==0)
        return;
    
    PFObject* commentActivity=[PFObject objectWithClassName:@"Activity"];
    [commentActivity setObject:commentField.text forKey:@"Content"];
    [commentActivity setObject:[PFUser currentUser] forKey:@"FromUser"];
    [commentActivity setObject:self.meet forKey:@"Meet"];
    [commentActivity setObject:[NSNumber numberWithInt:0] forKey:@"Type"];
    
    commentField.text=@"";
    
    [self.view endEditing:YES];
    
    [commentActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"Meet%@", self.meet.objectId]];
        
        [self refresh];
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)editMeet:(id)sender
{
    HWMAddStoryViewController* editStory = [[HWMAddStoryViewController alloc] init];
    editStory.meet = self.meet;
    editStory.shouldShowTrash = YES;
    [self.navigationController pushViewController:editStory animated:YES];
}

-(void)shareRequest:(id)sender
{
   UIActionSheet* actionSheet=[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share", @"Report", nil];
    
    [actionSheet showInView:[self.navigationController view]];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* buttonText=[actionSheet buttonTitleAtIndex:buttonIndex];
    if([buttonText isEqualToString:@"Share"])
    {
        [self shareMeetFromAction:nil];
    }
    else if([buttonText isEqualToString:@"Report"])
    {
        [self reportMeet:nil];
    }
    else if (buttonIndex == [actionSheet cancelButtonIndex])
    {
        return;
    }
}

-(void)shareMeetFromAction:(id)sender
{
    NSArray *activityItems;
    
    NSString* string = [_meet objectForKey:@"Story"];
    
    activityItems = @[string];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [activityController setCompletionHandler:^(NSString *activityType, BOOL completed) {
//        if (completed)
//            [ALToastView toastInView:self.view withText:[NSString stringWithFormat:@"%@ shared!", _requestData.title]];
    }];
    [self presentViewController:activityController animated:YES completion:nil];
}

-(void)reportMeet:(id)sender
{
    HWMReportViewController* reportView = [[HWMReportViewController alloc] init];
    reportView.meet = _meet;
    [self.navigationController pushViewController:reportView animated:YES];
}

-(void)dismiss:(id)sender
{
    if(self.presentingViewController!=nil)
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        }];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

@end


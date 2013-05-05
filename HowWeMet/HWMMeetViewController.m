//
//  HWMMeetViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 5/4/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMMeetViewController.h"
#import "HWMAddStoryViewController.h"

@interface HWMMeetViewController ()

@end

@implementation HWMMeetViewController

@synthesize nameLabel1 = _nameLabel1;
@synthesize nameLabel2 = _nameLabel2;
@synthesize profileImage1 = _profileImage1;
@synthesize profileImage2 = _profileImage2;
@synthesize activityTable = _activityTable;
@synthesize headerController = _headerController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Here's the Story";
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editMeet:)]];
    
    
    _activityTable.tableHeaderView=[[[NSBundle mainBundle] loadNibNamed:@"HWMMeetViewHeader" owner:self options:nil] objectAtIndex:0];
    _activityTable.tableHeaderView.autoresizingMask =YES;
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
    // Do any additional setup after loading the view from its nib.
//    _activityDataSource = [[HMTActivityFeedDataSource alloc] init];
//    _activityDataSource.delegate=self;
//    _activityDataSource.resourceLocation=[NSString stringWithFormat:@"customers/%@/activity", _customerID];
    
    [self loadInteractables];
    
    self.activityTable.delegate=self;
    //self.activityTable.dataSource= _activityDataSource;
    self.activityTable.separatorColor=[UIColor clearColor];
    self.activityTable.backgroundColor=[UIColor darkGrayColor];
    [[self view] addSubview:_activityTable];
}

-(void)loadInteractables
{
    //
    // header begins.
    whenView=[[[NSBundle mainBundle] loadNibNamed:@"AddieHeaderCell" owner:self options:nil] objectAtIndex:0];
    whenView.frame=CGRectMake(0, 230, whenView.frame.size.width, whenView.frame.size.height);
    whenView.autoresizingMask=UIViewAutoresizingFlexibleTopMargin;
    whereView=[[[NSBundle mainBundle] loadNibNamed:@"AddieHeaderCell" owner:self options:nil] objectAtIndex:0];
    whereView.frame=CGRectMake(0, 230, whereView.frame.size.width, whereView.frame.size.height);
    
    //
    // MC put the buttons in the table header instead and
    // make the header frame taller to fit them.
    CGRect headerFrame=self.activityTable.tableHeaderView.frame;
    self.activityTable.tableHeaderView.frame=CGRectMake(headerFrame.origin.x, headerFrame.origin.y, headerFrame.size.width, headerFrame.size.height+whenView.frame.size.height+whereView.frame.size.height);
    whenView.frame=CGRectMake(0, headerFrame.size.height, whenView.frame.size.width, whenView.frame.size.height);
    whereView.frame=CGRectMake(0, headerFrame.size.height+whenView.frame.size.height, whereView.frame.size.width, whereView.frame.size.height);
    [self.activityTable.tableHeaderView addSubview:whenView];
    [self.activityTable.tableHeaderView addSubview:whereView];
    

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
    //self.tableView.tableHeaderView=self.headerController.view;
    //[self.headerController.view layoutSubviews];
    [self.activityTable.tableHeaderView layoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return [_activityDataSource measureCell:indexPath];
    return 100.0f;
}
-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
    //return 65.0f;
}

-(void)viewDidAppear:(BOOL)animated
{
//    [self refresh];
//    [_activityDataSource refresh];
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
    [self.navigationController pushViewController:editStory animated:YES];
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


//
//  HWMFriendStoryViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 5/22/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMFriendStoryViewController.h"
#import "HWMMeetViewController.h"

@interface HWMFriendStoryViewController ()

@end

@implementation HWMFriendStoryViewController
@synthesize customer = _customer;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"How We Met";
    [self registerForKeyboardNotifications];
    
    self.tableView.delegate=self;
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    self.tableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor=[UIColor clearColor];
    
    self.noDataLabel.font = [UIFont fontWithName:@"Chalkduster" size:18.0];
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(keyboardWillHide:)];
    tap.enabled=NO;
    
    [self.view addGestureRecognizer:tap];
    // self.navigationController.navigationItem.hidesBackButton = YES;
    
    _dataSource =[[HWMFriendStoryDataSource alloc] init];
    _dataSource.customer = _customer;
    _dataSource.delegate=self;
    
    self.tableView.dataSource=_dataSource;
    [self.tableView reloadData];
    [_dataSource refresh];
}

-(void)viewDidAppear:(BOOL)animated
{
    [_dataSource refresh];
    
    if([self.tableView indexPathForSelectedRow])
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    tap.enabled = YES;
    // NSDictionary* info = [notification userInfo];
    //    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //    [UIView animateWithDuration:0.3f animations:^{
    //        self.view.frame=CGRectMake(self.view.frame.origin.x, -kbSize.height, self.view.frame.size.width, self.view.frame.size.height);
    //    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    tap.enabled=NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[_dataSource.data objectAtIndex:indexPath.row] objectForKey:@"FacebookID"]) {
        return 200.0f;
    }
    return 100.0f;
}

-(void)goToFriendProfile:(NSNumber*)customerID
{
    //    if(IS_NULL_OR_NIL(customerID)) return;
    //
    //    HMTProfileViewController* profileView=[[HMTProfileViewController alloc] init];
    //    profileView.customerID=customerID;
    //    [self.navigationController pushViewController:profileView animated:YES];
}

-(void)profileItemTapped:(NSIndexPath*)indexPath
{
    //    NSDictionary* profileData=[[((HMTGenericDataSource*)self.tableView.dataSource) data] objectAtIndex:indexPath.row];
    //    HMTProfile* profile=[HMTProfile fromDictionary:profileData];
    //    [self goToFriendProfile:profile.customerID];
}

-(void)facebookItemTapped:(NSIndexPath*)indexPath
{
    // check if they are an existing user
    //id<FBGraphUser> friend = [[((HWMGenericDataSource*)self.tableView.dataSource) data] objectAtIndex:indexPath.row];
    
    //    socialNetCustomer.socialNetworkID = friend.id;
    
    //parse stuff
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //hmmm
    PFObject *meet;
    NSDictionary* friend = [_dataSource.data objectAtIndex:indexPath.row];
    // Create the object.
    if ([friend objectForKey:@"FacebookID"]) {
        meet = (PFObject*)friend;
        HWMMeetViewController* storyController = [[HWMMeetViewController alloc] init];
        storyController.meet = meet;
        storyController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:storyController animated:YES];
    }
}

-(void)dataSource:(HWMGenericDataSource *)dataSource dataServiceUnavailable:(BOOL)unavailable reason:(NSString *)reason
{
    [self.tableView reloadData];
    [self toggleNoDataMessage:YES message:reason];
}

-(void)dataSource:(HWMGenericDataSource *)dataSource dataUpdated:(BOOL)updated
{
    [self.tableView reloadData];
    
    if(dataSource.data.count>0)
        [self toggleNoDataMessage:NO message:nil];
    else
    {
        [self emptyFeedMessageForCurrentSegment];
    }
}

-(void)dataSource:(HWMGenericDataSource *)dataSource error:(NSError *)error
{
    NSLog(@"dataSource error %@", error);
    
    [self.tableView reloadData];
}
-(void)emptyFeedMessageForCurrentSegment
{
    [self toggleNoDataMessage:YES message:[NSString stringWithFormat:@"%@ has no public meets yet", [_customer objectForKey:@"Name"]]];
}

-(void)toggleNoDataMessage:(BOOL)show message:(NSString*)message
{
    self.noDataLabel.text=message;
    self.noDataLabel.hidden=!show;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //
    [_dataSource setFilter:searchText];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
    
    if(searchBar.text==nil || searchBar.text.length==0)
    {
        [self.tableView reloadData];
    }
}

-(void)inviteFacebookFriend: (NSString*) friend
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Invite", @"title",
                                   friend, @"to",
                                   nil];
    
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Check out this app! Make challenges. Make Money!"
     title:nil
     parameters:params
     handler:nil];
    
}

- (void)viewDidUnload {
    //[self setSearchBar:nil];
    [self setNoDataLabel:nil];
    [super viewDidUnload];
}

-(void)dealloc
{
    self.tableView=nil;
}

@end
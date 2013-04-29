//
//  HWMRightViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/20/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMRightViewController.h"

@interface HWMRightViewController ()

@end

@implementation HWMRightViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"Friends";
    [self registerForKeyboardNotifications];
    [[[self navigationController] navigationBar] setTintColor:[[HowWeMetAPI sharedInstance] redColor]];
    //    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    //    [testObject setObject:@"bar" forKey:@"foo"];
    //    [testObject save];
    
    self.headerCell.backgroundColor = [[HowWeMetAPI sharedInstance] redColor];
    self.headerLabel.font = [UIFont fontWithName:@"Chalkduster" size:16.0];
    self.headerLabel.text = @"Friends";
    self.tableView.delegate=self;
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    self.searchBar.tintColor = [[HowWeMetAPI sharedInstance] redColor];
    //self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"patternBg"]];
    self.tableView.separatorColor=[UIColor clearColor];
    
    _dataSource =[[HWMFacebookDataSource alloc] init];
    _dataSource.delegate=self;

    self.tableView.dataSource=_dataSource;
    [self.tableView reloadData];
    
    self.searchBar.delegate = self;
    
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(keyboardWillHide:)];
    tap.enabled = NO;
    
    [self.view addGestureRecognizer:tap];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    tap.enabled = YES;
//    NSDictionary* info = [notification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    [UIView animateWithDuration:0.3f animations:^{
//        self.view.frame=CGRectMake(self.view.frame.origin.x, -kbSize.height, self.view.frame.size.width, self.view.frame.size.height);
//    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    tap.enabled = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    [self.view endEditing:YES];
}


-(void)viewDidAppear:(BOOL)animated
{
    [_dataSource refresh];
    
    if([self.tableView indexPathForSelectedRow])
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
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
    HWMGenericDataSource* dataSource=self.tableView.dataSource;
    return [dataSource measureCell:indexPath];
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

//-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView* header=[[[NSBundle mainBundle] loadNibNamed:@"HWMRightSectionHeader" owner:self options:nil] objectAtIndex:0];
//    header.autoresizingMask = YES;
//    UIImageView* image=(UIImageView*)[header viewWithTag:2];
//    UILabel* label=(UILabel*)[header viewWithTag:1];
//    
//    [image setContentMode:UIViewContentModeCenter];
//    [label setFont:[UIFont fontWithName:@"Chalkduster" size:17.0f]];
//    label.textColor = [UIColor whiteColor];
//    //[image setImage:[UIImage imageNamed:@"tabBarProfile"]];
//    
//    header.backgroundColor = [[HowWeMetAPI sharedInstance] redColor];
//    label.text=@"Friends";
//    
//    return header;
//}

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
    if ([[_dataSource.data objectAtIndex:indexPath.row] objectForKey:@"installed"]) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Soon... We Promise"
                              message: @"We plan to allow you to see your friend's public Meets soon."
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else 
        [self inviteFacebookFriend:[[_dataSource.data objectAtIndex:indexPath.row] objectForKey:@"id"]];
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
}

-(void)dataSource:(HWMGenericDataSource *)dataSource error:(NSError *)error
{
    NSLog(@"dataSource error %@", error);
    
    [self.tableView reloadData];
}

-(void)toggleNoDataMessage:(BOOL)show message:(NSString*)message
{
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //
    [_dataSource setFilter:searchText];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

-(void)inviteFacebookFriend: (NSString*) friend
{
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Invite", @"title",
                                   friend, @"to",
                                   nil];
    
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Remember Facebook back in the day? Back when it was .edu exlusive? Now you can keep track of your relationships just like you did back then. How did you meet your friends? Hurray, before you forget!"
     title:nil
     parameters:params
     handler:nil];
    
}

- (void)viewDidUnload {
    [self setHeaderCell:nil];
    [self setHeaderLabel:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
}
@end


//
//  HWMViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/20/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMViewController.h"

@interface HWMViewController ()

@end

@implementation HWMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"How We Met";
//    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
//    [testObject setObject:@"bar" forKey:@"foo"];
//    [testObject save];
    
    self.tableView.delegate=self;
    //self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"patternBg"]];
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    //self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"patternBg"]];
    self.tableView.separatorStyle= UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor=[UIColor clearColor];
    
    // self.navigationController.navigationItem.hidesBackButton = YES;
    
    HWMStoryDataSource* stories = [[HWMStoryDataSource alloc] init];
    
    _dataSources=@[stories];
    [_dataSources makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
    self.tableView.dataSource=[_dataSources objectAtIndex:0];
    [self.tableView reloadData];
    [(HWMGenericDataSource*)self.tableView.dataSource refresh];
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
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
//    if(_searchSource==nil)
//    {
//        _searchSource=[[HMTProfileListDataSource alloc] init];
//        //quick and dirty
//        [_searchSource hideFollowButton:YES];
//        _searchSource.delegate=self;
//    }
//    
//    if(searchBar.text==nil || searchBar.text.length==0)
//    {
//        [self.filterPicker setSelectedSegmentIndex:0];
//        [self filterBarChanged:self.filterPicker];
//        return;
//    }
//    
//    // unpop all the filter buttons so they can switch back
//    // by tapping on one.
//    [self.filterPicker setSelectedSegmentIndex:-1];
//    
//    // search search search
//    [_searchSource setResourceLocation:[NSString stringWithFormat:@"customers_search?query=%@", searchBar.text]];
//    
//    // hide the keyboard.
//    [self.view endEditing:YES];
//    
//    self.tableView.dataSource=_searchSource;
//    [self.tableView reloadData];
//    [_searchSource refresh];
}

-(void)dealloc
{
    self.tableView=nil;
    
    [_dataSources makeObjectsPerformSelector:@selector(setDelegate:) withObject:nil];
    _dataSources=nil;
}

- (IBAction)filterBarChanged:(id)sender {
    [self toggleNoDataMessage:NO message:nil];
    
    self.tableView.dataSource=[_dataSources objectAtIndex:[((UISegmentedControl*)sender) selectedSegmentIndex]];
    [self.tableView reloadData];
    
    //[DejalActivityView activityViewForView:self.view];
    [(HWMGenericDataSource*)self.tableView.dataSource refresh];
    
    //NSNumber* filterIndex=@([((UISegmentedControl*)sender) selectedSegmentIndex]);
    
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

@end

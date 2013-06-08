//
//  HWMLeftViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/20/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMLeftViewController.h"
#import "HWMViewController.h"
#import "HowWeMetAPI.h"
#import "JASidePanelController.h"
#import "UIViewController+JASidePanel.h"
#import <Parse/Parse.h>
#import <UserVoice.h>
#import <UVRootViewController.h>
#import <UVSession.h>
#import <UVNavigationController.h>

@interface HWMLeftViewController ()

@end

@implementation HWMLeftViewController

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
    // Do any additional setup after loading the view from its nib.
    //[self.sidePanelController showCenterPanelAnimated:YES];
    
    self.headerCell.backgroundColor = [[HowWeMetAPI sharedInstance] redColor];
    self.headerLabel.font = [UIFont fontWithName:@"Chalkduster" size:16.0];
    self.headerLabel.text = [[PFUser currentUser] objectForKey:@"Name"];
    self.howWeMetLabel.font = [UIFont fontWithName:@"Chalkduster" size:20.0];
    self.howWeMetLabel.textColor = [[HowWeMetAPI sharedInstance] redColor];
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.backgroundColor=[UIColor darkGrayColor];
    self.tableView.separatorColor=[UIColor clearColor];
    
    _tableData=[NSMutableArray arrayWithArray:@[@"Home",
                @"Post to Facebook",
                @"Feedback & Support",
                @"Logout"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[[[NSBundle mainBundle] loadNibNamed:@"HWMLeftSidebarCell" owner:self options:nil] objectAtIndex:0];
    [cell contentView].backgroundColor = [UIColor whiteColor];
    
    UILabel* textLabel = (UILabel*)[cell viewWithTag:1];
    textLabel.text = [_tableData objectAtIndex:indexPath.row];
    textLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
    
    UISwitch* factbookSwitch = (UISwitch*)[cell viewWithTag:2];
    if (indexPath.row==1) {
        factbookSwitch.hidden = NO;
        factbookSwitch.backgroundColor = [UIColor whiteColor];
        [factbookSwitch setOnTintColor:[[HowWeMetAPI sharedInstance] redColor]];
        if ([[HowWeMetAPI sharedInstance] automaticFacebookPost] ) {
            [factbookSwitch setOn:YES];
        }
        else {
            [factbookSwitch setOn:NO];
        }
        [factbookSwitch addTarget: self action: @selector(facebookSwitchFlip:) forControlEvents:UIControlEventValueChanged];
    }
    else {
        factbookSwitch.hidden = YES;
    }
    
    return cell;
}

- (IBAction) facebookSwitchFlip: (id) sender {
    UISwitch *onoff = (UISwitch *) sender;
    if (onoff.on) {
        [[HowWeMetAPI sharedInstance] setAutomaticFacebookPost:YES];
    }
    else {
        [[HowWeMetAPI sharedInstance] setAutomaticFacebookPost:NO];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            UIViewController* viewControl;
            viewControl = [[HWMViewController alloc] init];
            self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:viewControl];
        }
            break;
        case 2: // feedback & support
        {
            UVConfig *config = [UVConfig configWithSite:@"howwemet.uservoice.com"
                                                 andKey:@"jnZwHDOZXuUyPAkj7w39Q"
                                              andSecret:@"AT6NicsRYAohEsoiVURrib7PowSMCnMWBEr8WzgU8A"];
            
            [UserVoice presentUserVoiceInterfaceForParentViewController:self andConfig:config];
            
            [config setCustomFields:@{@"Type":@"Support Request"}];
            
            [UserVoice presentUserVoiceInterfaceForParentViewController:self.sidePanelController andConfig:config];
            
            break;
        }
        case 3:
        {
            [PFUser logOut];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"appSwitchToWelcome" object:nil];
            break;
        }
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setHeaderCell:nil];
    [self setHeaderLabel:nil];
    [self setHowWeMetLabel:nil];
    [super viewDidUnload];
}
@end

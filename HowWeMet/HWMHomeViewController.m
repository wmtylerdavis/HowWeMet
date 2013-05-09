//
//  HWMHomeViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/20/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMHomeViewController.h"
#import "HowWeMetAPI.h"
#import <Parse/Parse.h>

@interface HWMHomeViewController ()

@end

@implementation HWMHomeViewController

@synthesize howWeMetLabel = _howWeMetLabel;
@synthesize loginButton = _loginButton;

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
    //self.view.backgroundColor=[[HowWeMetAPI sharedInstance] redColor];
    //self.view.backgroundColor=[UIColor colorWithRed:0.14f green:0.55f blue:0.2f alpha:1];
    _howWeMetLabel.font = [UIFont fontWithName:@"Chalkduster" size:21.0];
    _loginButton.tintColor = [UIColor darkGrayColor];
    _loginButton.titleLabel.font=[UIFont fontWithName:@"Chalkduster" size:14.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setHowWeMetLabel:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
}
- (IBAction)loginTapped:(id)sender {
    
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_photos", @"friends_photo_video_tags"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        // add dejal
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew || user) {
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error) {
                if (!error) {
                    // Store the current user's Facebook ID on the user
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"facebookID"];
                    
                    if([[PFUser currentUser] objectForKey:@"Name"]==nil || [[[PFUser currentUser] objectForKey:@"Name"] isEqualToString:@""])
                    {
                        [[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"Name"];
                    }
                    
                    if([[PFUser currentUser] objectForKey:@"AvatarURL"]==nil || [[[PFUser currentUser] objectForKey:@"AvatarURL"] isEqualToString:@""])
                    {
                        [[PFUser currentUser] setObject:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [result objectForKey:@"id"]] forKey:@"AvatarURL"];
                    }
                    [self signupWithParse];
                }
            }];
            NSLog(@"User with facebook signed up and logged in!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"appSwitchToFeeds" object:nil];
        } else {
            NSLog(@"User logged in!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"appSwitchToFeeds" object:nil];
        }
    }];
    
}

-(void)signupWithParse
{
    [[PFUser currentUser] save];
    
    [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"user%@", [[PFUser currentUser] objectId]]];
}
@end

//
//  HWMFacebookDataSource.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/25/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMFacebookDataSource.h"
#import "EGOImageButton.h"
#import "HWMAppDelegate.h"

@implementation HWMFacebookDataSource

@synthesize friendUsers;

-(void)refresh
{
    /* go get the FB friends! */
    HWMAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [[FBRequest requestForGraphPath:@"me/friends?fields=id,name,first_name,last_name,installed"] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if(error!=nil)
        {
            [appDelegate openSessionWithAllowLoginUI:YES];
            [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    [self refresh];
                }
                else
                {
                    [self fireDataSourceUnavailable:@"Couldn't connect to Facebook."];
                }
                
            }];
        }
        else
        {
            _data=[result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:_data.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in _data) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            PFQuery *friendQuery = [PFUser query];
            [friendQuery whereKey:@"facebookID" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are friends
            // with the current user
            [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    // The find succeeded.
                    NSLog(@"Successfully retrieved %d scores.", objects.count);
                    friendUsers = objects;
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            
            // DUBBLE SORT
            _data=[_data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj2 objectForKey:@"name"] localizedCaseInsensitiveCompare:[obj1 objectForKey:@"name"]];
            }];
            
            _data=[_data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                if([[obj1 objectForKey:@"installed"] isEqualToNumber:[NSNumber numberWithBool:YES]])
                    return NSOrderedAscending;
                else
                    return NSOrderedDescending;
            }];
            
            _origData=_data;
            [self fireDataCompletedDelegate];
        }
    }];
}

-(void)setFilter:(NSString *)filter
{
    [super setFilter:filter];
    
    NSPredicate* pred=[NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)", filter];
    
    [self performFilter:pred];
}

-(float)measureCell:(NSIndexPath *)cellPath
{
    return 101.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    if(cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:tableView options:nil] objectAtIndex:0];
    }
    [cell contentView].backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    EGOImageButton* profilePic=(EGOImageButton*)[cell viewWithTag:10];
    UILabel* nameLabel=(UILabel*)[cell viewWithTag:1];
    UILabel* followersLabel=(UILabel*)[cell viewWithTag:2];
    
    NSDictionary* fbFriend=[_data objectAtIndex:indexPath.row];
    
    NSString* fbAvatarURL=[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [fbFriend objectForKey:@"id"]];
    
    [profilePic setImageURL:[NSURL URLWithString:fbAvatarURL]];
    [profilePic removeTarget:nil action:NULL forControlEvents:UIControlEventAllTouchEvents];
    [nameLabel setText:[NSString stringWithFormat:@"%@ %@", [fbFriend objectForKey:@"first_name"], [fbFriend objectForKey:@"last_name"]]];
    [nameLabel setFont:[UIFont fontWithName:@"Chalkduster" size:12.0f]];
    
    if([[fbFriend objectForKey:@"installed"] isEqualToNumber:[NSNumber numberWithBool:YES]])
        [followersLabel setText:@"has HowWeMet"];
    else
        [followersLabel setText:@"Invite and connect!"];
    
    [followersLabel setFont:[UIFont fontWithName:@"Chalkduster" size:10.0f]];
    
    return cell;
}

@end

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
                    NSLog(@"Successfully retrieved %d users.", objects.count);
                    //friendUsers = objects;
                    friendUsers = [[NSMutableDictionary alloc] init];
                    for (NSDictionary* friend in objects)
                    {
                        NSLog(@"%@", friend);
                        [friendUsers setObject:friend forKey:[friend objectForKey:@"facebookID"]];
                    }
                    
                } else {
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
                
                NSMutableArray *discardArray = [[NSMutableArray alloc] init];
                for (NSDictionary *facebookData in _data) {
                    if ( ![friendUsers objectForKey:[facebookData objectForKey:@"id"]]) {
                        [discardArray addObject:facebookData];
                    }
                }
                
                [_data removeObjectsInArray:discardArray];
                // DUBBLE SORT
                [_data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [[obj2 objectForKey:@"name"] localizedCaseInsensitiveCompare:[obj1 objectForKey:@"name"]];
                }];
                
                _origData=_data;
                [self fireDataCompletedDelegate];
                
            }];
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
    [nameLabel setAdjustsFontSizeToFitWidth:YES];
    [nameLabel setMinimumScaleFactor:0.5];
    
    [followersLabel setText:@"has HowWeMet"];
    [followersLabel setFont:[UIFont fontWithName:@"Chalkduster" size:10.0f]];
    
    return cell;
}

@end

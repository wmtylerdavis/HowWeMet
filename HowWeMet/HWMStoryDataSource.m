//
//  HWMStoryDataSource.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/26/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMStoryDataSource.h"
#import "HWMAppDelegate.h"
#import "EGOImageButton.h"
#import <Parse/Parse.h>

@implementation HWMStoryDataSource
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
            _facebookData = [result objectForKey:@"data"];
            
            //something with parse
            PFQuery* storyQuery=[PFQuery queryWithClassName:@"Meet"];
            [storyQuery whereKey:@"Owner" equalTo:[PFUser currentUser]];
            
            [storyQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                _stories=[self indexKeyedDictionaryFromArray:objects];
                
                for (long i = 0; i < _facebookData.count; ++i) {
                    if ([_stories objectForKey:[[_facebookData objectAtIndex:i] objectForKey:@"id"]])
                    {
                        //no way this works
                        [_facebookData setObject:[_stories objectForKey:[_facebookData[i] objectForKey:@"id"]] atIndexedSubscript:i];
                        
                        //[_stories objectForKey:[_facebookData objectAtIndex:i] objectForKey:@"id"];
                    }
                }
                
                _data=_facebookData;
                // DUBBLE SORT
                _data=[_data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return [[obj2 objectForKey:@"name"] localizedCaseInsensitiveCompare:[obj1 objectForKey:@"name"]];
                }];
                _data=[_data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    return NSOrderedDescending;
                }];
                NSLog(@"%@", _data);
                
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
    if ([[_data objectAtIndex:cellPath.row] objectForKey:@"FacebookID"]) {
        return 205.0f;
    }
    return 101.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* fbFriend=[_data objectAtIndex:indexPath.row];
    UITableViewCell* cell;
    
    if ([fbFriend objectForKey:@"FacebookID"]) {
        cell=[tableView dequeueReusableCellWithIdentifier:@"HWMStoryCell"];
        if(cell==nil)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"HWMStoryCell" owner:tableView options:nil] objectAtIndex:0];
        }
        [cell contentView].backgroundColor = [UIColor clearColor];
        
        EGOImageButton* profilePic=(EGOImageButton*)[cell viewWithTag:1];
        UILabel* nameLabel=(UILabel*)[cell viewWithTag:2];
        UILabel* storyLabel=(UILabel*)[cell viewWithTag:3];
        NSString* avatarURL=[fbFriend objectForKey:@"AvatarURL"];
        
        [profilePic setImageURL:[NSURL URLWithString:avatarURL]];
        [profilePic removeTarget:nil action:NULL forControlEvents:UIControlEventAllTouchEvents];
        
        [nameLabel setText:[NSString stringWithFormat:@"%@", [fbFriend objectForKey:@"Name"]]];
        [nameLabel setFont:[UIFont fontWithName:@"Chalkduster" size:14.0f]];
        [storyLabel setFont:[UIFont fontWithName:@"OpenSans" size:10.0f]];
        storyLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
        storyLabel.numberOfLines = 0;
        [storyLabel setText:[fbFriend objectForKey:@"Story"]];
    }
    
    else {
        cell=[tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
        if(cell==nil)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:tableView options:nil] objectAtIndex:0];
        }
        [cell contentView].backgroundColor = [UIColor clearColor];
        
        NSString* fbAvatarURL=[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [fbFriend objectForKey:@"id"]];
        
        EGOImageButton* profilePic=(EGOImageButton*)[cell viewWithTag:10];
        UILabel* nameLabel=(UILabel*)[cell viewWithTag:1];
        UILabel* storyLabel=(UILabel*)[cell viewWithTag:2];
        
        [profilePic setImageURL:[NSURL URLWithString:fbAvatarURL]];
        [profilePic removeTarget:nil action:NULL forControlEvents:UIControlEventAllTouchEvents];
        [nameLabel setText:[NSString stringWithFormat:@"%@ %@", [fbFriend objectForKey:@"first_name"], [fbFriend objectForKey:@"last_name"]]];
        [nameLabel setFont:[UIFont fontWithName:@"Chalkduster" size:14.0f]];
        [storyLabel setFont:[UIFont fontWithName:@"OpenSans" size:10.0f]];
        [storyLabel setText:@"No story yet. Click to add one."];
    }
    
    return cell;
}

- (NSDictionary *) indexKeyedDictionaryFromArray:(NSArray *)array
{
    id objectInstance;
    //NSUInteger indexKey = 0;
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (objectInstance in array)
    {
        [mutableDictionary setObject:objectInstance forKey:[objectInstance valueForKey:@"FacebookID"]];
    }
    
    return (NSDictionary *) mutableDictionary;
}

@end

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
            _data=[result objectForKey:@"data"];
            
            // DUBBLE SORT
            _data=[_data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [[obj2 objectForKey:@"name"] localizedCaseInsensitiveCompare:[obj1 objectForKey:@"name"]];
            }];
            _data=[_data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return NSOrderedDescending;
                }];
            
            //something with parse
            PFQuery* storyQuery=[PFQuery queryWithClassName:@"Meet"];
            [storyQuery whereKey:@"Owner" equalTo:[PFUser currentUser]];
            
            [storyQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                _stories=[self indexKeyedDictionaryFromArray:objects];
//                _stories = [NSArray arrayWithArray:objects];
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
    return 200.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"HWMStoryCell"];
    if(cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"HWMStoryCell" owner:tableView options:nil] objectAtIndex:0];
    }
    [cell contentView].backgroundColor = [UIColor clearColor];
    
    EGOImageButton* profilePic=(EGOImageButton*)[cell viewWithTag:1];
    UILabel* nameLabel=(UILabel*)[cell viewWithTag:2];
    UILabel* storyLabel=(UILabel*)[cell viewWithTag:3];
    
    NSDictionary* fbFriend=[_data objectAtIndex:indexPath.row];
    
    NSString* fbAvatarURL=[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [fbFriend objectForKey:@"id"]];
    
    [profilePic setImageURL:[NSURL URLWithString:fbAvatarURL]];
    [profilePic removeTarget:nil action:NULL forControlEvents:UIControlEventAllTouchEvents];
    [nameLabel setText:[NSString stringWithFormat:@"%@ %@", [fbFriend objectForKey:@"first_name"], [fbFriend objectForKey:@"last_name"]]];
    [nameLabel setFont:[UIFont fontWithName:@"Chalkduster" size:14.0f]];
    [storyLabel setFont:[UIFont fontWithName:@"OpenSans" size:10.0f]];
    
    if ([_stories objectForKey:[fbFriend objectForKey:@"id"]]) {
        [storyLabel setText:@"This worked!"];
    }
    else {
        [storyLabel setText:@"What what!"];
    }
    
    return cell;
}

- (NSDictionary *) indexKeyedDictionaryFromArray:(NSArray *)array
{
    id objectInstance;
    //NSUInteger indexKey = 0;
    
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] init];
    for (objectInstance in array)
        [mutableDictionary setObject:objectInstance forKey:[objectInstance valueForKey:@"facebookID"]];
    
    return (NSDictionary *) mutableDictionary;
}

@end

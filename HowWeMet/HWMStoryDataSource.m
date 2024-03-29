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
            
            //parse
            PFQuery* storyQuery=[PFQuery queryWithClassName:@"Meet"];
            [storyQuery whereKey:@"Owner" equalTo:[PFUser currentUser]];
            
            [storyQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                _stories=[self indexKeyedDictionaryFromArray:objects];
                
                for (long i = 0; i < _facebookData.count; ++i) {
                    if ([_stories objectForKey:[[_facebookData objectAtIndex:i] objectForKey:@"id"]])
                    {
                        //no way this works
                        [_facebookData setObject:[_stories objectForKey:[_facebookData[i] objectForKey:@"id"]] atIndexedSubscript:i];
                    }
                }
                
                _data=_facebookData;
                [_data sortUsingDescriptors:
                 [NSArray arrayWithObjects:
                  [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES],
                  [NSSortDescriptor sortDescriptorWithKey:@"Story" ascending:YES], nil]];
                
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
    
    NSPredicate* pred=[NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@) OR (Name CONTAINS[cd] %@)", filter, filter];
    
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        EGOImageButton* profilePic=(EGOImageButton*)[cell viewWithTag:1];
        UILabel* nameLabel=(UILabel*)[cell viewWithTag:2];
        UILabel* storyLabel=(UILabel*)[cell viewWithTag:3];
        UILabel* dateLabel=(UILabel*)[cell viewWithTag:11];
        NSString* avatarURL=[fbFriend objectForKey:@"FriendAvatarURL"];
        
        [profilePic setImageURL:[NSURL URLWithString:avatarURL]];
        [profilePic removeTarget:nil action:NULL forControlEvents:UIControlEventAllTouchEvents];
        
        [nameLabel setText:[NSString stringWithFormat:@"%@", [fbFriend objectForKey:@"FriendName"]]];
        [nameLabel setFont:[UIFont fontWithName:@"Chalkduster" size:14.0f]];
        [nameLabel setAdjustsFontSizeToFitWidth:YES];
        [nameLabel setMinimumScaleFactor:0.5];
        
        //storyLabel.frame = CGRectMake(storyLabel.frame.origin.x, storyLabel.frame.origin.y, storyLabel.frame.size.width, storyLabel.frame.size.height);
        [storyLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
        storyLabel.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;
        storyLabel.text = [fbFriend objectForKey:@"Story"];
        [storyLabel setNumberOfLines:0];
        if (storyLabel.text.length < 100) {
            [storyLabel sizeToFit];
        }
        [dateLabel setFont:[UIFont fontWithName:@"Chalkduster" size:11.0f]];
        dateLabel.text = [fbFriend objectForKey:@"Date"];
            
//        [storyLabel setFont:[UIFont fontWithName:@"OpenSans" size:10.0f]];
//        storyLabel.lineBreakMode = UILineBreakModeWordWrap | UILineBreakModeTailTruncation;
//        storyLabel.numberOfLines = 0;
        //[storyLabel setText:[fbFriend objectForKey:@"Story"]];
        
        UIImageView* image=(UIImageView*)[cell viewWithTag:9];
        image.hidden = NO;
        NSLog(@"%@", fbFriend);
        if (!IS_NULL_OR_NIL([fbFriend objectForKey:@"Photo"])) {
            PFFile* imgFileData=[fbFriend objectForKey:@"Photo"];
            [imgFileData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImage* feedImage=[UIImage imageWithData:data];
                image.image=feedImage;
            }];
        } else {
            image.hidden = YES;
        }
    
    }
    
    else {
        cell=[tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
        if(cell==nil)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"FriendCell" owner:tableView options:nil] objectAtIndex:0];
        }
        [cell contentView].backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString* fbAvatarURL=[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [fbFriend objectForKey:@"id"]];
        
        EGOImageButton* profilePic=(EGOImageButton*)[cell viewWithTag:10];
        UILabel* nameLabel=(UILabel*)[cell viewWithTag:1];
        UILabel* storyLabel=(UILabel*)[cell viewWithTag:2];
        
        [profilePic setImageURL:[NSURL URLWithString:fbAvatarURL]];
        [profilePic removeTarget:nil action:NULL forControlEvents:UIControlEventAllTouchEvents];
        [nameLabel setText:[NSString stringWithFormat:@"%@ %@", [fbFriend objectForKey:@"first_name"], [fbFriend objectForKey:@"last_name"]]];
        [nameLabel setFont:[UIFont fontWithName:@"Chalkduster" size:14.0f]];
        [nameLabel setAdjustsFontSizeToFitWidth:YES];
        [nameLabel setMinimumScaleFactor:0.5];
        [storyLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
        [storyLabel setText:@"No story yet. Add one!"];
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

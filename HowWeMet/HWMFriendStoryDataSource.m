//
//  HWMFriendStoryDataSource.m
//  HowWeMet
//
//  Created by Tyler Davis on 5/22/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMFriendStoryDataSource.h"
#import "HWMAppDelegate.h"
#import "EGOImageButton.h"
#import <Parse/Parse.h>

@implementation HWMFriendStoryDataSource


-(void)refresh
{
    /* go get the FB friends! */
    PFQuery* storyQuery=[PFQuery queryWithClassName:@"Meet"];
    [storyQuery whereKey:@"Owner" equalTo:self.customer];
    [storyQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _stories=[self indexKeyedDictionaryFromArray:objects];
        NSLog(@"%@", objects);
        NSLog(@"%@", _stories);
//        for (long i = 0; i < _facebookData.count; ++i) {
//            [_facebookData setObject:[_stories objectForKey:[_facebookData[i] objectForKey:@"id"]] atIndexedSubscript:i];
//        }
        NSLog(@"customer %@", _customer);
        NSLog(@"objects %@", objects);
        _data = objects;
                // DUBBLE SORT
        _data=[_data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [[obj2 objectForKey:@"Name"] localizedCaseInsensitiveCompare:[obj1 objectForKey:@"Name"]];
        }];
        _data=[_data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return NSOrderedDescending;
        }];
                
        _origData=_data;
        
        [self fireDataCompletedDelegate];
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
        
        [storyLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0f]];
        storyLabel.lineBreakMode = NSLineBreakByTruncatingTail | NSLineBreakByWordWrapping;
        storyLabel.text = [fbFriend objectForKey:@"Story"];
        [storyLabel setNumberOfLines:0];
        if (storyLabel.text.length < 100) {
            [storyLabel sizeToFit];
        }
        [dateLabel setFont:[UIFont fontWithName:@"Chalkduster" size:11.0f]];
        dateLabel.text = [fbFriend objectForKey:@"Date"];
        
        UIImageView* image=(UIImageView*)[cell viewWithTag:9];
        
        if ([fbFriend objectForKey:@"Photo"] != [NSNull null]) {
            PFFile* imgFileData=[fbFriend objectForKey:@"Photo"];
            [imgFileData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImage* feedImage=[UIImage imageWithData:data];
                image.image=feedImage;
            }];
        }
        
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

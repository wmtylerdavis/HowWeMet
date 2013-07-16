//
//  HWMFacebookPlaceDataSource.m
//  HowWeMet
//
//  Created by Tyler Davis on 5/4/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMFacebookPlaceDataSource.h"
#import "HWMAppDelegate.h"

@implementation HWMFacebookPlaceDataSource

@synthesize place = _place;
-(void)refresh
{
    /* go get the FB friends! */
    HWMAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (_place) {
        //[self.place stringByReplacingOccurrencesOfString:@" " withString:@","];
        _place = [_place stringByReplacingOccurrencesOfString:@" " withString:@","];
        NSLog(@"%@", _place);
    }
    else {
        return;
    }
    NSString* graphText = [NSString stringWithFormat:@"search?q=%@&type=Place", _place];
    [[FBRequest requestForGraphPath:graphText] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
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
    return 80.0f;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:@"HWMPlaceCell"];
    if(cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"HWMPlaceCell" owner:tableView options:nil] objectAtIndex:0];
    }
    [cell contentView].backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel* nameLabel=(UILabel*)[cell viewWithTag:1];
    UILabel* categoryLabel=(UILabel*)[cell viewWithTag:2];
    
    NSDictionary* fbPlace=[_data objectAtIndex:indexPath.row];
    
    [nameLabel setText:[NSString stringWithFormat:@"%@", [fbPlace objectForKey:@"name"]]];
    [nameLabel setFont:[UIFont fontWithName:@"Chalkduster" size:12.0f]];
    [nameLabel setAdjustsFontSizeToFitWidth:YES];
    [nameLabel setMinimumScaleFactor:0.5];
    [categoryLabel setText:[NSString stringWithFormat:@"%@", [fbPlace objectForKey:@"category"]]];
    [categoryLabel setFont:[UIFont fontWithName:@"Chalkduster" size:12.0f]];

    
    return cell;
}

@end

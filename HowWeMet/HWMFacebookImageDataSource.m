//
//  HWMFacebookImageDataSource.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/29/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMFacebookImageDataSource.h"
#import "HWMAppDelegate.h"
#import "EGOImageView.h"

@implementation HWMFacebookImageDataSource

@synthesize fbUserID = _fbUserID;

-(void)refresh
{
    /* go get the FB friends! */
    HWMAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    [[FBRequest requestForGraphPath:@"me/photos?fields=source,tags&limit=1000"] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
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
            NSLog(@"%lu", (unsigned long)_facebookData.count);
            NSMutableArray *discardedItems = [NSMutableArray array];
            
            for (id item in _facebookData) {
                NSArray* facebookSucks = [[item objectForKey:@"tags"] objectForKey:@"data"];
                NSArray* origData = facebookSucks;
                NSLog(@"%@", self.fbUserID);
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"(id == %@)",self.fbUserID];
                facebookSucks = [origData filteredArrayUsingPredicate:pred];
                if (facebookSucks.count == 0) {
                    //NSLog(@"%@", [_facebookData objectAtIndex:i]);
                    [discardedItems addObject:item];
//                    [_facebookData removeObjectAtIndex:i];
                }
            }
            [_facebookData removeObjectsInArray:discardedItems];
            _data=_facebookData;
            NSLog(@"%lu", (unsigned long)_data.count);
            
            _origData=_data;
            [self fireDataCompletedDelegate];
        }
    }];
}

-(void)setFilter:(NSString *)filter
{
    NSPredicate* pred=[NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@)", filter];
    
    [self performFilter:pred];
}

-(void)performFilter:(NSPredicate*)predicate
{
    int startAmt=_data.count;
    BOOL checkStartAmt=YES;
    
    if(_filter==nil || [_filter isEqualToString:@""])
    {
        _data=_origData;
        checkStartAmt=NO;
    }
    else
    {
        _data=[_origData filteredArrayUsingPredicate:predicate];
    }
    
    if(checkStartAmt && (startAmt==_data.count))
        return;
    
    [self fireDataCompletedDelegate];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _data.count;
}

-(float)measureCell:(NSIndexPath *)cellPath
{
    return 101.0f;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"HWMFacebookImage" forIndexPath:indexPath];
    
    if(cell==nil)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"HWMFacebookImage" owner:collectionView options:nil] objectAtIndex:0];
    }
    [cell contentView].backgroundColor = [UIColor clearColor];
    
    EGOImageView* pic=(EGOImageView*)[cell viewWithTag:1];
    
    NSDictionary* fbImage=[_data objectAtIndex:indexPath.row];
    NSLog(@"%@", fbImage);
    [pic setImageURL:[NSURL URLWithString:[fbImage objectForKey:@"source"]]];

    return cell;
}

-(void)fireDataSourceUnavailable:(NSString*)reason
{
    if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(dataSource:dataServiceUnavailable:reason:)])
    {
        [self.delegate dataSource:self dataServiceUnavailable:YES reason:reason];
    }
}

-(void)fireDataCompletedDelegate
{
    if(self.delegate!=nil)
    {
        if([self.delegate respondsToSelector:@selector(dataSource:dataUpdated:)])
            [self.delegate dataSource:self dataUpdated:YES];
    }
}

-(void)fireErrorDelegate:(NSError *)error
{
    if(self.delegate!=nil)
    {
        if([self.delegate respondsToSelector:@selector(dataSource:error:)])
            [self.delegate dataSource:self error:error];
    }
}

@end

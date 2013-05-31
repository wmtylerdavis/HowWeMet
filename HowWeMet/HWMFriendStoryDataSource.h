//
//  HWMFriendStoryDataSource.h
//  HowWeMet
//
//  Created by Tyler Davis on 5/22/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMGenericDataSource.h"
#import <Parse/Parse.h>

@interface HWMFriendStoryDataSource : HWMGenericDataSource
{
    NSDictionary* _stories;
    //NSArray* _stories;
    NSMutableArray* _facebookData;
}

@property (nonatomic, retain) PFUser* customer;

@end

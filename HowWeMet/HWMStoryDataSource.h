//
//  HWMStoryDataSource.h
//  HowWeMet
//
//  Created by Tyler Davis on 4/26/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMGenericDataSource.h"
#import <FacebookSDK.h>

@interface HWMStoryDataSource : HWMGenericDataSource
{
    NSDictionary* _stories;
    //NSArray* _stories;
    NSMutableArray* _facebookData;
}

@end

//
//  HWMFBOpenGraphAction.h
//  HowWeMet
//
//  Created by Tyler Davis on 5/9/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol HWMFBOpenGraphObject <FBGraphObject>

@property (retain, nonatomic) NSString        *id;
@property (retain, nonatomic) NSString        *url;

@end

// FBSample logic
// Wraps an Open Graph object (of type "scrumps:eat") with a relationship to a meal,
// as well as properties inherited from FBOpenGraphAction such as "place" and "tags".
@protocol HWMMeetAction<FBOpenGraphAction>

@property (retain, nonatomic) id<HWMFBOpenGraphObject>    meet;

@end
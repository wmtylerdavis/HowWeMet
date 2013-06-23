//
//  HWMFacebookImageDataSource.h
//  HowWeMet
//
//  Created by Tyler Davis on 4/29/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "EGOImageButton.h"

@class HWMFacebookImageDataSource;

@protocol HWMImageDataSourceDelegate <NSObject>

-(void)dataSource:(HWMFacebookImageDataSource*)dataSource dataUpdated:(BOOL)updated;
@optional
-(void)dataSource:(HWMFacebookImageDataSource*)dataSource error:(NSError*)error;
-(void)dataSource:(HWMFacebookImageDataSource*)dataSource dataServiceUnavailable:(BOOL)unavailable reason:(NSString*)reason;

@end

@interface HWMFacebookImageDataSource : NSObject <UICollectionViewDataSource>
{
    NSArray* _data;
    NSArray* _origData;
    NSMutableArray* _facebookData;
}

@property (nonatomic, assign) id<HWMImageDataSourceDelegate> delegate;
@property (nonatomic, retain) NSArray* data;
@property (nonatomic, copy) NSString* resourceLocation;
@property (nonatomic, assign) int tag;
@property (nonatomic, copy) NSString* filter;
@property (nonatomic, retain) NSString* fbUserID;
@property (nonatomic, assign) BOOL waiting;

-(void)fireDataCompletedDelegate;
-(void)fireErrorDelegate:(NSError*)error;
-(void)fireDataSourceUnavailable:(NSString*)reason;

-(void)refresh;
-(void)performFilter:(NSPredicate*)predicate;
-(float)measureCell:(NSIndexPath*)cellPath;

@end

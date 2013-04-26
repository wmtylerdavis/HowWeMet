//
//  HWMGenericDataSource.h
//  
//
//  Created by Tyler Davis on 4/25/13.
//
//

#import <Foundation/Foundation.h>
#import "HowWeMetAPI.h"
#import "EGOImageButton.h"

@class HWMGenericDataSource;

@protocol HWMDataSourceDelegate <NSObject>

-(void)dataSource:(HWMGenericDataSource*)dataSource dataUpdated:(BOOL)updated;
@optional
-(void)dataSource:(HWMGenericDataSource*)dataSource error:(NSError*)error;
//-(void)dataSource:(HWMGenericDataSource*)dataSource profileTapped:(HMTProfile*)profile;
-(void)dataSource:(HWMGenericDataSource *)dataSource dataServiceUnavailable:(BOOL)unavailable reason:(NSString*)reason;
-(void)dataSource:(HWMGenericDataSource *)dataSource profilePictureTapped:(EGOImageButton*)sender;

@end

@interface HWMGenericDataSource : NSObject <UITableViewDataSource>
{
    NSString* _resourceLocation;
    NSArray* _data;
    NSArray* _origData;
    NSArray* _filterSet;
    NSString* _filter;
    
    BOOL _waiting;
}

@property (nonatomic, assign) id<HWMDataSourceDelegate> delegate;
@property (nonatomic, retain) NSArray* data;
@property (nonatomic, copy) NSString* resourceLocation;
@property (nonatomic, assign) int tag;
@property (nonatomic, copy) NSString* filter;
@property (nonatomic, assign) BOOL waiting;

-(void)fireDataCompletedDelegate;
-(void)fireErrorDelegate:(NSError*)error;
-(void)fireDataSourceUnavailable:(NSString*)reason;

-(void)refresh;
-(void)performFilter:(NSPredicate*)predicate;

-(float)measureCell:(NSIndexPath*)cellPath;

@end

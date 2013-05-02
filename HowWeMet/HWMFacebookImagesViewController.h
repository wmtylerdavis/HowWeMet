//
//  HWMFacebookImagesViewController.h
//  HowWeMet
//
//  Created by Tyler Davis on 4/29/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "HWMGenericDataSource.h"
#import "HWMFacebookImageDataSource.h"
#import "HWMMappableObject.h"

@class HWMFacebookImagesViewController;

@interface HWMFacebookPhotoPickerTarget : NSObject
@property (nonatomic, retain) id<HWMMappableObject> target;
@property (nonatomic, retain) NSString* imageURL;

@end

@protocol HWMFacebookPhotoPickerDelegate <NSObject>

-(void)targetPicker:(HWMFacebookImagesViewController*)targetPicker targetSelected:(HWMFacebookPhotoPickerTarget*)target;

@end

@interface HWMFacebookImagesViewController : UIViewController<UICollectionViewDelegate, HWMImageDataSourceDelegate>
{
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) HWMFacebookImageDataSource* dataSource;
@property (nonatomic, retain) NSString* facebookID;
@property (nonatomic, assign) id<HWMFacebookPhotoPickerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *noDataLabel;

@end

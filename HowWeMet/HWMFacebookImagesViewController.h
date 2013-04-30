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

@interface HWMFacebookImagesViewController : UIViewController<UICollectionViewDelegate, HWMImageDataSourceDelegate>
{
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, retain) HWMFacebookImageDataSource* dataSource;
@property (nonatomic, retain) NSString* facebookID;

@end

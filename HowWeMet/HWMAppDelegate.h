//
//  HWMAppDelegate.h
//  HowWeMet
//
//  Created by Tyler Davis on 4/20/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreData/CoreData.h>
#import "HWMViewController.h"
#import "JASidePanelController.h"

extern NSString *const HWMSessionStateChangedNotification;

@class HWMViewController;

@interface HWMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) JASidePanelController *viewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

// FB logic
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code;
-(void)registerForPush;

@end
//
//  HWMAppDelegate.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/20/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMAppDelegate.h"
#import "HWMViewController.h"
#import "HWMHomeViewController.h"
#import "HWMLeftViewController.h"
#import "HWMRightViewController.h"
#import <Parse/Parse.h>

NSString *const FBSessionStateChangedNotification = @"HowWeMet.HowWeMet:FBSessionStateChangedNotification";

@interface HWMAppDelegate ()

@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) HWMHomeViewController *homeViewController;
@property (strong, nonatomic) UIViewController *viewWelcomeController;

@end

@implementation HWMAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

@synthesize navController = _navController;
@synthesize homeViewController = _homeViewController;
@synthesize viewController=_viewController;

-(void)ensureLeftPanelIsReady:(id)notif
{
    if(![[((JASidePanelController*)self.viewController) leftPanel] isViewLoaded])
        [((JASidePanelController*)self.viewController) showLeftPanelAnimated:YES];
}

-(void)ensureRightPanelIsReady:(id)notif
{
    if(![[((JASidePanelController*)self.viewController) rightPanel] isViewLoaded])
        [((JASidePanelController*)self.viewController) showRightPanelAnimated:YES];
}

-(void)addRightButtonToCenterPanel:(id)notif
{
    UIViewController* centerViewCtl;
    
    if([[self.viewController.centerPanel class] isSubclassOfClass:[UINavigationController class]])
    {
        UINavigationController* navCtl=(UINavigationController*)self.viewController.centerPanel;
        centerViewCtl=[navCtl topViewController];
    }
    else
        centerViewCtl=self.viewController.centerPanel;
    
    if([[centerViewCtl navigationItem] rightBarButtonItem]!=nil) return;
    
    UIBarButtonItem* rightButton=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Social"] style:UIBarButtonItemStylePlain target:self.viewController action:@selector(showRightPanel:)];
    [[centerViewCtl navigationItem] setRightBarButtonItem:rightButton];
}

-(BOOL)isHomeViewController
{
    if ([self.window.rootViewController isEqual:self.viewWelcomeController]) {
        return YES;
    }
    return NO;
}

-(void)switchToFeeds
{
    //    self.viewController=[[HMTMainViewController alloc] init];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addRightButtonToCenterPanel:) name:@"addRightButtonToCenterPanel" object:nil];
    
    JASidePanelController* panelController=[[JASidePanelController alloc] init];
    self.viewController = panelController;
    self.viewController.panningLimitedToTopViewController = NO;
    
    self.viewController.leftPanel = [[HWMLeftViewController alloc] init];
    
    UIViewController* centerViewCtl=[[HWMViewController alloc] init];
    
    self.viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:centerViewCtl];
    HWMRightViewController * rightView = [[HWMRightViewController alloc] init];
    
    self.viewController.rightPanel = rightView;
    
    [self addRightButtonToCenterPanel:nil];
    
    self.window.rootViewController = self.viewController;
    [self.window setRootViewController:self.viewController];
    
    [panelController setAllowLeftSwipe:YES];
    [panelController setMaximumAnimationDuration:0.1f];
    [panelController setBounceDuration:0.1f];
    
    [self.window makeKeyAndVisible];
}

-(void)switchToWelcome
{
    UINavigationController* welcomeNav=[[UINavigationController alloc] initWithRootViewController:[[HWMHomeViewController alloc] init]];
    [welcomeNav setNavigationBarHidden:YES];
    self.viewWelcomeController=welcomeNav;
    [self.window setRootViewController:self.viewWelcomeController];
}

#pragma mark - Facebook SDK
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState)state
                      error:(NSError *)error
{
    // FBSample logic
    // Any time the session is closed, we want to display the login controller (the user
    // cannot use the application unless they are logged in to Facebook). When the session
    // is opened successfully, hide the login controller and show the main UI.
    switch (state) {
        case FBSessionStateOpen: {
            if (self.homeViewController != nil) {
                UIViewController *topViewController = [self.navController topViewController];
                [topViewController dismissModalViewControllerAnimated:YES];
                self.homeViewController = nil;
            }
            
            // FBSample logic
            // Pre-fetch and cache the friends for the friend picker as soon as possible to improve
            // responsiveness when the user tags their friends.
            FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
            [cacheDescriptor prefetchAndCacheForSession:session];
        }
            break;
        case FBSessionStateClosed: {
            // FBSample logic
            // Once the user has logged out, we want them to be looking at the root view.
            UIViewController *topViewController = [self.navController topViewController];
            UIViewController *modalViewController = [topViewController modalViewController];
            if (modalViewController != nil) {
                [topViewController dismissModalViewControllerAnimated:NO];
            }
            [self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self performSelector:@selector(showLoginView)
                       withObject:nil
                       afterDelay:0.5f];
        }
            break;
        case FBSessionStateClosedLoginFailed: {
            // if the token goes invalid we want to switch right back to
            // the login view, however we do it with a slight delay in order to
            // account for a race between this and the login view dissappearing
            // a moment before
            [self performSelector:@selector(showLoginView)
                       withObject:nil
                       afterDelay:0.5f];
        }
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification
                                                        object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Error: %@",
                                                                     [HWMAppDelegate FBErrorCodeDescription:error.code]]
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    return [FBSession openActiveSessionWithReadPermissions:nil
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                             [self sessionStateChanged:session state:state error:error];
                                             [FBSession setActiveSession:session];
                                         }];
}

//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    // FBSample logic
//    // We need to handle URLs by passing them to FBSession in order for SSO authentication
//    // to work.
//    return [FBSession.activeSession handleOpenURL:url];
//}

//Parse Version
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

-(void)registerForPush
{
//    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

-(void)setupAppearance
{
    // nav bars
    //[[UINavigationBar appearance] setBackgroundColor:[UIColor lightGrayColor]];
    // navy [UIColor colorWithRed:0.22f green:0.33f blue:0.53f alpha:1.0f]
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navHeader"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"navHeader"]]];
//    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.36f green:0.04f blue:0.13f alpha:1.0f]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{UITextAttributeTextColor : [UIColor whiteColor],
                         UITextAttributeTextShadowColor : [UIColor blackColor],
                        UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                    UITextAttributeFont : [UIFont fontWithName:@"Chalkduster" size:20.0]}
     ];
    
    // nav bar buttons fo all
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor colorWithRed:0.36f green:0.04f blue:0.13f alpha:1.0f]];
//    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor colorWithRed:0.36f green:0.04f blue:0.13f alpha:1.0f]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:
     @{UITextAttributeTextColor : [UIColor whiteColor],
                                                                     UITextAttributeTextShadowColor : [UIColor grayColor],
                                                                    UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
                                                                               }
                                                                                            forState:UIControlStateNormal];
    
}

#pragma mark - Standard AppDelegate stuff
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBProfilePictureView class];
    
    [FBSettings setLoggingBehavior:[NSSet setWithObjects:FBLoggingBehaviorFBRequests, FBLoggingBehaviorFBURLConnections, FBLoggingBehaviorAccessTokens, FBLoggingBehaviorSessionStateTransitions, nil]];
    
    [Parse setApplicationId:@"VCqVVgdlh4jAVf5lXh7y6fTwUS1IBogmQG5NX5XV"
                  clientKey:@"EAc5fdh970PXGnoj52Ix23CW9T2mkW8QfG7VQTZ4"];
    [PFFacebookUtils initializeFacebook];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:NO];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Register for remote notfications with the UA Library. This call is required.
    [self registerForPush];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    // init the window
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    // set up all the appearance proxies
    [self setupAppearance];
    
    // catch the view present notification to ensure the panel is ready
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ensureLeftPanelIsReady:) name:kViewPresentNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ensureRightPanelIsReady:) name:kViewPresentNotification object:nil];
    //
    
    // determine what our main view controller should be.
    if([PFUser currentUser]==nil)
    {
        [self switchToWelcome];
    }
    else {
        [self switchToFeeds];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToFeeds) name:@"appSwitchToFeeds" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToWelcome) name:@"appSwitchToWelcome" object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSession.activeSession handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // close FB sesh
    [FBSession.activeSession close];
    
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    [PFPush storeDeviceToken:deviceToken];
    [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];
    
    if([PFUser currentUser]!=nil)
    {
        [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"user%@", [[PFUser currentUser] objectId]]];
    }
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

-(void)handleRemoteNotification:(NSDictionary*)notification
{
    //
}

-(void)handleLocalNotification:(UILocalNotification*)notification
{
    //
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateInactive) {
        [self handleLocalNotification:notification];
    } else {
        
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HowMuchTo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (NSString *)FBErrorCodeDescription:(FBErrorCode) code {
    switch(code){
        case FBErrorInvalid :{
            return @"FBErrorInvalid";
        }
        case FBErrorOperationCancelled:{
            return @"FBErrorOperationCancelled";
        }
        case FBErrorLoginFailedOrCancelled:{
            return @"FBErrorLoginFailedOrCancelled";
        }
        case FBErrorRequestConnectionApi:{
            return @"FBErrorRequestConnectionApi";
        }case FBErrorProtocolMismatch:{
            return @"FBErrorProtocolMismatch";
        }
        case FBErrorHTTPError:{
            return @"FBErrorHTTPError";
        }
        case FBErrorNonTextMimeTypeReturned:{
            return @"FBErrorNonTextMimeTypeReturned";
        }
        case FBErrorNativeDialog:{
            return @"FBErrorNativeDialog";
        }
        default:
            return @"[Unknown]";
    }
}

@end

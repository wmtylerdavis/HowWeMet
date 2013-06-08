//
//  HowWeMetAPI.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/24/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HowWeMetAPI.h"

@implementation HowWeMetAPI

@synthesize redColor = _redColor;
@synthesize automaticFacebookPost = _automaticFacebookPost;

+(HowWeMetAPI*)sharedInstance
{
    static dispatch_once_t _singletonPredicate;
    static HowWeMetAPI* _singleton = nil;
    
    dispatch_once(&_singletonPredicate, ^{
        _singleton = [[super allocWithZone:nil] init];
    });
    
    return _singleton;
}

-(UIColor*)redColor
{
    if (!_redColor) {
        _redColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navHeader"]];
    }
    return _redColor;
}

-(void) setAutomaticFacebookPost: (BOOL) autoFacebookPost
{
    _automaticFacebookPost = autoFacebookPost;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:autoFacebookPost forKey:@"AutomaticFacebookPost"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(BOOL)automaticFacebookPost
{
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"AutomaticFacebookPost"])
    {
        _automaticFacebookPost=[[NSUserDefaults standardUserDefaults] boolForKey:@"AutomaticFacebookPost"];
    }
    else {
        [self setAutomaticFacebookPost:YES];
    }
    return _automaticFacebookPost;
}

@end

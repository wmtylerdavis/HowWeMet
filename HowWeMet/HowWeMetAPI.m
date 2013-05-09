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
        //_redColor= [UIColor colorWithRed:0.36f green:0.04f blue:0.2f alpha:1.0f];
        _redColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navHeader"]];
    }
    return _redColor;
}

@end

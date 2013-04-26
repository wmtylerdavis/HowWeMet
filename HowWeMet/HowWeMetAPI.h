//
//  HowWeMetAPI.h
//  HowWeMet
//
//  Created by Tyler Davis on 4/24/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface HowWeMetAPI : NSObject
{

}

@property (strong,nonatomic) UIColor* redColor;

-(UIColor*)redColor;

+(HowWeMetAPI*)sharedInstance;
@end

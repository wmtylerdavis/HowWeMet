//
//  HWMMappableObject.h
//  HowWeMet
//
//  Created by Tyler Davis on 4/30/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HWMMappableObject <NSObject>

-(NSDictionary*)asDictionary;
+(id<HWMMappableObject>)fromDictionary:(id)dict;
+(NSString*)className;

@end

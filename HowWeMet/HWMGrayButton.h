//
//  HWMGrayButton.h
//  HowWeMet
//
//  Created by Tyler Davis on 4/24/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HWMGrayButton : UIButton
{
    const NSString* _style;
    float _textSize;
}

@property (nonatomic, copy) const NSString* style;
@property (nonatomic, retain) NSNumber* objectID;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, assign) float textSize;

@end

//
//  HWMGrayButton.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/24/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMGrayButton.h"

@implementation HWMGrayButton

@synthesize style;

-(float)textSize
{
    return _textSize;
}

-(void)setTextSize:(float)textSize
{
    _textSize=textSize;
    [self setupAppearance];
}

-(const NSString*)style
{
    return _style;
}

-(void)setStyle:(const NSString *)newStyle
{
    _style=newStyle;
    [self setupAppearance];
}

-(void)setupAppearance
{
    if(self.style==nil)
        self.style=@"bigGrayButton";
    
    if(self.textSize==0)
        self.textSize=18.0f;
    
    UIImage* buttonImage=[[UIImage imageNamed:(NSString*)self.style] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 6, 25, 6)];
    [self setBackgroundImage:buttonImage forState:UIControlStateNormal];
    self.titleLabel.font=[UIFont fontWithName:@"PTSans-Bold" size:self.textSize];
    self.titleLabel.shadowColor=[UIColor blackColor];
    self.titleLabel.shadowOffset=CGSizeMake(0.0, 1.0);
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

-(id)init{
    self=[super init];
    if(self) {
        [self setupAppearance];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setupAppearance];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self setupAppearance];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end



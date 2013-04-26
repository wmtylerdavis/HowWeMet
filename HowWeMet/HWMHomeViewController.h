//
//  HWMHomeViewController.h
//  HowWeMet
//
//  Created by Tyler Davis on 4/20/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWMGrayButton.h"

@interface HWMHomeViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *howWeMetLabel;
@property (strong, nonatomic) IBOutlet HWMGrayButton *loginButton;
- (IBAction)loginTapped:(id)sender;

@end

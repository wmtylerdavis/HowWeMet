//
//  HWMReportViewController.h
//  HowWeMet
//
//  Created by Tyler Davis on 6/18/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface HWMReportViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *reportTextView;
@property (nonatomic, retain) PFObject* meet;

@end

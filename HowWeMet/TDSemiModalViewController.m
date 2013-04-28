//
//  TDSemiModalViewController.m
//  TDSemiModal
//
//  Created by Nathan  Reed on 18/10/10.
//  Copyright 2010 Nathan Reed. All rights reserved.
//

#import "TDSemiModalViewController.h"

@implementation TDSemiModalViewController
@synthesize coverView;

-(void)viewDidLoad {
    [super viewDidLoad];
	self.coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    //self.coverView.frame=CGRectMake(0, 20, self.coverView.frame.size.width, self.coverView.frame.size.height);
	//self.coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	coverView.backgroundColor = UIColor.blackColor;

	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.coverView = nil;
}

- (void)dealloc {
	self.coverView = nil;
    [super dealloc];
}

@end

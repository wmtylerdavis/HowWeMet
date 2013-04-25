//
//  HWMViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/20/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMViewController.h"

@interface HWMViewController ()

@end

@implementation HWMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"How We Met";
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    [testObject setObject:@"bar" forKey:@"foo"];
    [testObject save];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

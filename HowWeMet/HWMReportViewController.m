//
//  HWMReportViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 6/18/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMReportViewController.h"
#import "HWMMeetViewController.h"

@interface HWMReportViewController ()

@end

@implementation HWMReportViewController

@synthesize reportTextView = _reportTextView;
@synthesize meet = _meet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _reportTextView.delegate = self;
    self.title = @"Report";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEdit:)];
}

-(void) viewDidAppear:(BOOL)animated
{
    //[_reportTextView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) textViewDidBeginEditing:(UITextView *) textView {
    [_reportTextView setText:@""];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    PFObject* report = [PFObject objectWithClassName:@"Report"];
    [report setObject:_reportTextView.text forKey:@"Reason"];
    [report setObject:[_meet objectForKey:@"FacebookID"] forKey:@"TargetFacebookID"];
    [report setObject:[_meet objectForKey:@"Owner"] forKey:@"Owner"];
    [report saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded)
        {
            NSLog(@"Holy crap");
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void) cancelEdit: (id) sender {
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2] animated:YES];
}
@end

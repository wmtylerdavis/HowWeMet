//
//  HWMAddStoryViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/26/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMAddStoryViewController.h"

@interface HWMAddStoryViewController ()

@end

@implementation HWMAddStoryViewController

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setFriendAvatar:nil];
    [self setFriendName:nil];
    [self setFriendRelationship:nil];
    [self setTimeLabel:nil];
    [self setHowWeMetStory:nil];
    [self setHowWeMetImage:nil];
    [super viewDidUnload];
}

-(void)setMeet:(PFObject *)meet
{
    _meet = meet;
    
}

-(PFObject*)meet
{
    return _meet;
}

-(void)refresh
{
    if(self.meet==nil) return;
    
    PFFile* imgFileData=[self.meet objectForKey:@"Photo"];
    [imgFileData getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//        UIImage* meetImage=[UIImage imageWithData:data];
//        self.howWeMetImage.imageView = meetImage;
    }];
    
    self.friendName.text=[self.meet objectForKey:@"Name"];
    [self.friendAvatar setImageURL:[self.meet objectForKey:@"AvatarURL"]];
    
}

- (IBAction)addImageTapped:(id)sender {
}
@end

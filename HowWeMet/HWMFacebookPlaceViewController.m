//
//  HWMFacebookPlaceViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 5/4/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMFacebookPlaceViewController.h"

@implementation HWMFacebookPlacePickerTarget
@synthesize target;
@end

@interface HWMFacebookPlaceViewController ()

@end

@implementation HWMFacebookPlaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"Find Place";
    [self registerForKeyboardNotifications];
    [[[self navigationController] navigationBar] setTintColor:[[HowWeMetAPI sharedInstance] redColor]];
    
    self.tableView.delegate=self;
    self.tableView.backgroundColor = [UIColor darkGrayColor];
    self.searchBar.tintColor = [[HowWeMetAPI sharedInstance] redColor];
    self.tableView.separatorColor=[UIColor clearColor];
    
    _dataSource =[[HWMFacebookPlaceDataSource alloc] init];
    _dataSource.delegate=self;
    
    self.tableView.dataSource=_dataSource;
    [self.tableView reloadData];
    
    self.searchBar.delegate = self;
    
    tap = [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector(keyboardWillHide:)];
    tap.enabled = NO;
    
    [self.view addGestureRecognizer:tap];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    tap.enabled = YES;
    //    NSDictionary* info = [notification userInfo];
    //    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //    [UIView animateWithDuration:0.3f animations:^{
    //        self.view.frame=CGRectMake(self.view.frame.origin.x, -kbSize.height, self.view.frame.size.width, self.view.frame.size.height);
    //    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    tap.enabled = NO;
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame=CGRectMake(self.view.frame.origin.x, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
    [self.view endEditing:YES];
}


-(void)viewDidAppear:(BOOL)animated
{
//    [_dataSource refresh];
    
    if([self.tableView indexPathForSelectedRow])
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HWMGenericDataSource* dataSource=self.tableView.dataSource;
    return [dataSource measureCell:indexPath];
}

-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //hmmm
    if(self.delegate!=nil)
    {
        if([self.delegate respondsToSelector:@selector(targetPicker:placeSelected:)])
        {
            HWMFacebookPlacePickerTarget* target=[[HWMFacebookPlacePickerTarget alloc] init];
            
            target=[_dataSource.data objectAtIndex:indexPath.row];
            
            //target.imageURL = [fbImage objectForKey:@"source"];
            
            [self.delegate targetPicker:self placeSelected:target];
        }
    }

}

-(void)dataSource:(HWMGenericDataSource *)dataSource dataServiceUnavailable:(BOOL)unavailable reason:(NSString *)reason
{
    [self.tableView reloadData];
    [self toggleNoDataMessage:YES message:reason];
}

-(void)dataSource:(HWMGenericDataSource *)dataSource dataUpdated:(BOOL)updated
{
    [self.tableView reloadData];
    
    if(dataSource.data.count>0)
        [self toggleNoDataMessage:NO message:nil];
}

-(void)dataSource:(HWMGenericDataSource *)dataSource error:(NSError *)error
{
    NSLog(@"dataSource error %@", error);
    
    [self.tableView reloadData];
}

-(void)toggleNoDataMessage:(BOOL)show message:(NSString*)message
{
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // [_dataSource setFilter:searchText];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
    placeSearch = searchBar.text;
    _dataSource.place = placeSearch;
    [_dataSource refresh];
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [super viewDidUnload];
}
@end


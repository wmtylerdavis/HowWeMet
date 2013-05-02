//
//  HWMFacebookImagesViewController.m
//  HowWeMet
//
//  Created by Tyler Davis on 4/29/13.
//  Copyright (c) 2013 Tyler Davis. All rights reserved.
//

#import "HWMFacebookImagesViewController.h"

@interface HWMFacebookImagesViewController ()

@end

@implementation HWMFacebookPhotoPickerTarget
@synthesize target;
@synthesize imageURL;
@end

@implementation HWMFacebookImagesViewController

@synthesize dataSource = _dataSource;
@synthesize facebookID = _facebookID;
@synthesize delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"Facebook Photos";
    
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor darkGrayColor];
    UINib *cellNib = [UINib nibWithNibName:@"HWMFacebookImage" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"HWMFacebookImage"];
    [self.noDataLabel setFont:[UIFont fontWithName:@"Helvetica" size:14.0]];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    [self.collectionView setCollectionViewLayout:flowLayout];

    
    _dataSource =[[HWMFacebookImageDataSource alloc] init];
    _dataSource.fbUserID = _facebookID;
    _dataSource.delegate=self;
    
    self.collectionView.dataSource=_dataSource;
    [self.collectionView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [_dataSource refresh];
    
//    if([self.collectionView indexPathForSelectedRow])
//        [self.collectionView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    if(self.delegate!=nil)
    {
        if([self.delegate respondsToSelector:@selector(targetPicker:targetSelected:)])
        {
            HWMFacebookPhotoPickerTarget* target=[[HWMFacebookPhotoPickerTarget alloc] init];
            
            NSDictionary* fbImage=[_dataSource.data objectAtIndex:indexPath.row];
            
            target.imageURL = [fbImage objectForKey:@"source"];
            
            [self.delegate targetPicker:self targetSelected:target];
        }
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
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

-(void)goToFriendProfile:(NSNumber*)customerID
{
    //    if(IS_NULL_OR_NIL(customerID)) return;
    //
    //    HMTProfileViewController* profileView=[[HMTProfileViewController alloc] init];
    //    profileView.customerID=customerID;
    //    [self.navigationController pushViewController:profileView animated:YES];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _dataSource.data.count;
}

-(void)dataSource:(HWMGenericDataSource *)dataSource dataServiceUnavailable:(BOOL)unavailable reason:(NSString *)reason
{
    [self.collectionView reloadData];
    [self toggleNoDataMessage:YES message:reason];
}

-(void)dataSource:(HWMGenericDataSource *)dataSource dataUpdated:(BOOL)updated
{
    [self.collectionView reloadData];
    
    if(dataSource.data.count>0)
        [self toggleNoDataMessage:NO message:nil];
    else
    {
        [self emptyFeedMessageForCurrentSegment];
    }
}

-(void)emptyFeedMessageForCurrentSegment
{
    [self toggleNoDataMessage:YES message:@"We couldn't find any images on Facebook for the two of you together, but we're still working on this feature so we could be wrong..."];
}

-(void)dataSource:(HWMGenericDataSource *)dataSource error:(NSError *)error
{
    NSLog(@"dataSource error %@", error);
    
    [self.collectionView reloadData];
}

-(void)toggleNoDataMessage:(BOOL)show message:(NSString*)message
{
    self.noDataLabel.text=message;
    self.noDataLabel.hidden=!show;
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    //
    [_dataSource setFilter:searchText];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void)viewDidUnload {
    [self setCollectionView:nil];
    [self setNoDataLabel:nil];
    [super viewDidUnload];
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 2
    CGSize retval = CGSizeMake(100, 100);
    //CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
    retval.height += 35; retval.width += 35;
    return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}


@end
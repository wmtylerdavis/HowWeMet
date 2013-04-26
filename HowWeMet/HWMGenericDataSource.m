//
//  HWMGenericDataSource.m
//  
//
//  Created by Tyler Davis on 4/25/13.
//
//

#import "HWMGenericDataSource.h"

@implementation HWMGenericDataSource

@synthesize tag;

-(NSString*)filter
{
    return _filter;
}

-(void)setFilter:(NSString *)filter
{
    _filter=filter;
}

-(void)performFilter:(NSPredicate*)predicate
{
    int startAmt=_data.count;
    BOOL checkStartAmt=YES;
    
    if(_filter==nil || [_filter isEqualToString:@""])
    {
        _data=_origData;
        checkStartAmt=NO;
    }
    else
    {
        _data=[_origData filteredArrayUsingPredicate:predicate];
    }
    
    if(checkStartAmt && (startAmt==_data.count))
        return;
    
    [self fireDataCompletedDelegate];
}

-(float)measureCell:(NSIndexPath *)cellPath
{
    return 0;
}

-(NSArray*)data
{
    return _data;
}

-(void)setData:(NSArray *)data
{
    _data=data;
}

-(NSString*)resourceLocation
{
    return _resourceLocation;
}

-(void)setResourceLocation:(NSString *)resourceLocation
{
    _resourceLocation=resourceLocation;
}

-(void)refresh
{
    if(_resourceLocation==nil)
    {
        [self fireDataCompletedDelegate];
        return;
    }
    //parse code
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_data==nil) return 0;
    return _data.count;
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(void)fireDataCompletedDelegate
{
    if(self.delegate!=nil)
    {
        if([self.delegate respondsToSelector:@selector(dataSource:dataUpdated:)])
            [self.delegate dataSource:self dataUpdated:YES];
    }
}

-(void)fireErrorDelegate:(NSError *)error
{
    if(self.delegate!=nil)
    {
        if([self.delegate respondsToSelector:@selector(dataSource:error:)])
            [self.delegate dataSource:self error:error];
    }
}

-(void)fireDataSourceUnavailable:(NSString*)reason
{
    if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(dataSource:dataServiceUnavailable:reason:)])
    {
        [self.delegate dataSource:self dataServiceUnavailable:YES reason:reason];
    }
}

@end

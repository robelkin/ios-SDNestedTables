//
//  SDNestedTableViewController.m
//  SDNestedTablesExample
//
//  Created by Daniele De Matteis on 21/05/2012.
//  Copyright (c) 2012 Daniele De Matteis. All rights reserved.
//

#import "SDNestedTableViewController.h"

@interface SDNestedTableViewController ()

@end

@implementation SDNestedTableViewController

@synthesize mainItemsAmt, subItemsAmt, groupCell;
@synthesize delegate;

- (id) init
{
    if (self = [self initWithNibName:@"SDNestedTableView" bundle:nil])
    {
    }
    return self;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        self.delegate = self;
    }
    
    return self;
}

#pragma mark - To be implemented in sublclasses

- (NSInteger)mainTable:(UITableView *)mainTable numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"\n Oops! You didn't specify the amount of Items in the Main tableview \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
    return 0;
}

- (NSInteger)mainTable:(UITableView *)mainTable numberOfSubItemsforItem:(SDGroupCell *)item atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"\n Oops! You didn't specify the amount of Sub Items for this Main Item \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
    return 0; 
}

- (SDGroupCell *)mainTable:(UITableView *)mainTable setItem:(SDGroupCell *)item forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.row == 0)
    {
        NSLog(@"\n Oops! Item cells in the Main tableview are not configured \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
    }
    return item;
}

- (SDSubCell *)item:(SDGroupCell *)item setSubItem:(SDSubCell *)subItem forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        NSLog(@"\n Oops! Sub Items for this Item are not configured \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
    }
    return subItem;
}

- (void)expandingItem:(SDGroupCell *)item withIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collapsingItem:(SDGroupCell *)item withIndexPath:(NSIndexPath *)indexPath 
{

}
    
// Optional method to implement. Will be called when creating a new main cell to return the nib name you want to use

- (NSString *) nibNameForMainCell
{
    return @"SDGroupCell";
}

#pragma mark - Delegate methods

- (void) mainTable:(UITableView *)mainTable itemDidChange:(SDGroupCell *)item
{
    NSLog(@"\n Oops! You didn't specify a behavior for this Item \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
}

- (void) item:(SDGroupCell *)item subItemDidChange:(SDSelectableCell *)subItem
{
    NSLog(@"\n Oops! You didn't specify a behavior for this Sub Item \n Please implement \"%@\" in your SDNestedTables subclass.", NSStringFromSelector(_cmd));
}

- (void) mainItemDidChange: (SDGroupCell *)item forTap:(BOOL)tapped
{
    if(delegate != nil && [delegate respondsToSelector:@selector(mainTable:itemDidChange:)] )
    {
        [delegate performSelector:@selector(mainTable:itemDidChange:) withObject:self.tableView withObject:item];
    }
}

- (void) mainItem:(SDGroupCell *)item subItemDidChange: (SDSelectableCell *)subItem forTap:(BOOL)tapped
{
    if(delegate != nil && [delegate respondsToSelector:@selector(item:subItemDidChange:)] )
    {
        [delegate performSelector:@selector(item:subItemDidChange:) withObject:item withObject:subItem];
    }
}

#pragma mark - Class lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    subItemsAmt = [[NSMutableDictionary alloc] initWithDictionary:nil];
	expandedIndexes = [[NSMutableDictionary alloc] init];
	selectableCellsState = [[NSMutableDictionary alloc] init];
	selectableSubCellsState = [[NSMutableDictionary alloc] init];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - TableView delegation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    mainItemsAmt = [self mainTable:tableView numberOfItemsInSection:section];
    return mainItemsAmt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SDGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:[self nibNameForMainCell] owner:self options:nil];
        cell = groupCell;
        self.groupCell = nil;
    }
    
    [cell setParentTable: self];
    
    cell = [self mainTable:tableView setItem:cell forRowAtIndexPath:indexPath];
    
    NSNumber *amt = [NSNumber numberWithInt:[self mainTable:tableView numberOfSubItemsforItem:cell atIndexPath:indexPath]];
    [subItemsAmt setObject:amt forKey:indexPath];
    
    [cell setSubCellsAmt: [[subItemsAmt objectForKey:indexPath] intValue]];
    
    NSMutableDictionary *subCellsState = [selectableSubCellsState objectForKey:indexPath];
    int selectedSubCellsAmt = 0;
    for (NSString *key in subCellsState)
    {
        SelectableCellState cellState = [[subCellsState objectForKey:key] intValue];
        if (cellState == Checked) {
            selectedSubCellsAmt++;
        }
    }
    [cell setSelectedSubCellsAmt: selectedSubCellsAmt];
    [cell setSelectableSubCellsState: [selectableSubCellsState objectForKey:indexPath]];
    
    SelectableCellState cellState = [[selectableCellsState objectForKey:indexPath] intValue];
    switch (cellState)
    {
        case Checked:       [cell check];       break;
        case Unchecked:     [cell uncheck];     break;
        case Halfchecked:   [cell halfCheck];   break;
        default:                                break;
    }
    
    BOOL isExpanded = [[expandedIndexes objectForKey:indexPath] boolValue];
    cell.isExpanded = isExpanded;
    if(cell.isExpanded)
    {
        [cell rotateExpandBtnToExpanded];
    }
    else
    {
        [cell rotateExpandBtnToCollapsed];
    }
    
    [cell.subTable reloadData];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int amt = [[subItemsAmt objectForKey:indexPath] intValue];
    BOOL isExpanded = [[expandedIndexes objectForKey:indexPath] boolValue];
    if(isExpanded)
    {
        return [SDGroupCell getHeight] + [SDGroupCell getsubCellHeight]*amt;
    }
    return [SDGroupCell getHeight];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SDGroupCell *cell = (SDGroupCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell tapTransition];
    SelectableCellState cellState = [cell toggleCheck];
    NSNumber *cellStateNumber = [NSNumber numberWithInt:cellState];
    [selectableCellsState setObject:cellStateNumber forKey:indexPath];
    
    [cell subCellsToggleCheck];
    
    [self mainItemDidChange:cell forTap:YES];
}

#pragma mark - Nested Tables events

- (void) groupCell:(SDGroupCell *)cell didSelectSubCell:(SDSelectableCell *)subCell withIndexPath:(NSIndexPath *)indexPath andWithTap:(BOOL)tapped
{
    NSIndexPath *groupCellIndexPath = [self.tableView indexPathForCell:cell];
    NSNumber *cellStateNumber = [NSNumber numberWithInt:cell.selectableCellState];
    [selectableCellsState setObject:cellStateNumber forKey:groupCellIndexPath];
    
    //NSIndexPath *subCellIndexPath = [cell.subTable indexPathForCell:subCell];
    NSNumber *subCellStateNumber = [NSNumber numberWithInt:subCell.selectableCellState];
    if (![selectableSubCellsState objectForKey:groupCellIndexPath])
    {
        NSMutableDictionary *subCellState = [[NSMutableDictionary alloc] initWithObjectsAndKeys: subCellStateNumber, indexPath, nil];
        [selectableSubCellsState setObject:subCellState forKey:groupCellIndexPath];
    }
    else
    {
        [[selectableSubCellsState objectForKey:groupCellIndexPath] setObject:subCellStateNumber forKey:indexPath];
    }
    
    [cell setSelectableSubCellsState: [selectableSubCellsState objectForKey:groupCellIndexPath]];
    
    [self mainItem:cell subItemDidChange:subCell forTap:tapped];
}

- (void) collapsableButtonTapped: (UIControl *) button withEvent: (UIEvent *) event
{
    UITableView *tableView = self.tableView;
    NSIndexPath * indexPath = [tableView indexPathForRowAtPoint: [[[event touchesForView: button] anyObject] locationInView: tableView]];
    if ( indexPath == nil )
        return;
    
    if ([[expandedIndexes objectForKey:indexPath] boolValue]) {
        [self collapsingItem:(SDGroupCell *)[tableView cellForRowAtIndexPath:indexPath] withIndexPath:indexPath];
    } else {
        [self expandingItem:(SDGroupCell *)[tableView cellForRowAtIndexPath:indexPath] withIndexPath:indexPath];
    }
    
    // reset cell expanded state in array
	BOOL isExpanded = ![[expandedIndexes objectForKey:indexPath] boolValue];
	NSNumber *expandedIndex = [NSNumber numberWithBool:isExpanded];
	[expandedIndexes setObject:expandedIndex forKey:indexPath];

    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

@end

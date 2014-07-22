//
//  CHLFilterViewControllerTableViewController.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import "CHLFilterViewController.h"
#import "CHLLocationViewController.h"
#import "CHLSearchStore.h"

@interface CHLFilterViewController ()

@end

@implementation CHLFilterViewController

#pragma mark - VC Lifecycle
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
        if (self) {
            
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Filter data
    
    NSDictionary *cell1 = @{@"image":@"All",
                            @"title":@"All campsites",
                            @"description":@"Show all campsites",
                            };
    NSDictionary *cell2 = @{@"image":@"Rustic",
                            @"title":@"Rustic campsites",
                            @"description":@"With ample privacy & nature.",
                            };
    NSDictionary *cell3 = @{@"image":@"RV",
                            @"title":@"RV-friendly campsites",
                            @"description":@"With amenities for RVs.",
                            };
    NSDictionary *cell4 = @{@"image":@"Backcountry",
                            @"title":@"Backcountry",
                            @"description":@"Deep backcountry. For backpackers.",
                            };
    /*NSDictionary *cell5 = @{@"image":@"Civilized",
     @"title":@"With conveniences",
     @"description":@"Camp without roughing it.",
     };*/
    /*NSDictionary *cell6 = @{@"image":@"Budget",
     @"title":@"Budget campsites",
     @"description":@"Find cheap places to camp.",
     };*/
    /*NSDictionary *cell7 = @{@"image":@"Horse",
     @"title":@"Horse camping",
     @"description":@"Camp with your lovely horse.",
     };*/
    self.filters = @[cell1, cell2, cell3, cell4];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Custom initialization
    // Set the navbar title
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"Search controls";
    [self resetFilterTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

// Set number of rows in each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: {
            return 1; // Location section
        } break;
        default: {
            return self.filters.count; // campsite style cells
        } break;
    }
}

// Set section titles
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return NSLocalizedString(@"Location", @"Location");
        } break;
        case 1: {
            return NSLocalizedString(@"Camping style (pick one)", @"Camping style (pick one)");
        } break;
        default: {
            return NSLocalizedString(@"", @"");
        } break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            // Configure the location cell
            static NSString *CellIdentifier = @"LocationCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == Nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            }
            
            // Configure the cell...
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            NSString *locationCellTitle = [NSString stringWithFormat:@"Near %@", self.locationName];
            cell.textLabel.text = locationCellTitle;
            cell.detailTextLabel.text = @"Change to a different location?";
            cell.imageView.image = [UIImage imageNamed:@"PlaceIcon"];
            
            return cell;
        } break;
        default: {
            static NSString *CellIdentifier = @"StyleCell";
            //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == Nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                //cell.textLabel.highlightedTextColor = [[UIColor alloc] initWithRed:1.0 green:.45 blue:0.0 alpha:1.0];
                cell.textLabel.highlightedTextColor = [[UIColor alloc] initWithRed:0.0 green:0.5664 blue:0.6602 alpha:1.0];
                cell.detailTextLabel.highlightedTextColor = [[UIColor alloc] initWithRed:0.0 green:0.5664 blue:0.6602 alpha:1.0];
            }
            if (indexPath.row == [[CHLSearchStore sharedStore] tribeFilter]) {
                cell.selected = YES;
            }
            
            // Configure the cell...
            cell.textLabel.text = self.filters[indexPath.row][@"title"];
            cell.detailTextLabel.text = self.filters[indexPath.row][@"description"];
            cell.imageView.image = [UIImage imageNamed:self.filters[indexPath.row][@"image"]];
            
            return cell;
            
        } break;
    }
}

# pragma mark - Delegation
// When a row is selected, do something
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // If user taps the "near X" button, go to screen to let them pick the location
        CHLLocationViewController *locationView = [[CHLLocationViewController alloc] init];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.selected = NO;
        [self.navigationController pushViewController:locationView animated:YES];
    } else {
        // If user taps a campsite type filter, highlight and apply the filter.
        // FIRST UNHIGHLIGHT the other cells in this section
        //UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        //cell.highlighted = YES;
        //cell.backgroundColor = [[UIColor alloc] initWithRed:0.1 green:0.9 blue:0.1 alpha:1.0];
        
        //apply the filter
        int tribeId = (int)indexPath.row;
        [[CHLSearchStore sharedStore] saveActiveTribeFilter:tribeId];
        [[CHLSearchStore sharedStore] applyTribeFilter];
        
    }
    
}

#pragma mark - Data handlers
// Reset the table data, most importantly the location cell
- (void)resetFilterTable
{
    if ([[[CHLSearchStore sharedStore] locationName] isEqualToString:@""]) {
        self.locationName = @"You";
    } else {
        self.locationName = [[CHLSearchStore sharedStore] locationName];
    }
    [self.tableView reloadData];
    NSIndexPath *selectionIndex = [NSIndexPath indexPathForRow:[[CHLSearchStore sharedStore] tribeFilter] inSection:1];
    [self.tableView selectRowAtIndexPath:selectionIndex animated:YES scrollPosition:UITableViewScrollPositionTop];
}
/*-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
 {
 UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
 cell.backgroundColor = [[UIColor alloc] initWithRed:0.1 green:0.9 blue:0.1 alpha:1.0];
 }
 
 -(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
 {
 UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
 cell.backgroundColor = [UIColor whiteColor];
 }*/

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 
 */

@end
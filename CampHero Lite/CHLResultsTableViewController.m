//
//  CHLResultsTableViewController.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import "CHLResultsTableViewController.h"
#import "CHLCampsiteViewController.h"
#import "CHLSearchStore.h"
//#import "CHLReserveOnlineViewController.h"
//#import "CHLCampsiteMapViewController.h"


@interface CHLResultsTableViewController ()

@end

@implementation CHLResultsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @""; // Hide the navbar back button's title
    self.restorationIdentifier = @"Results";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Get current filtered campsites
    //NSArray *results = [[CHLSearchStore sharedStore] campsites];
    NSArray *results = [[CHLSearchStore sharedStore] filteredCampsites];
    if (results.count > 0) {
        self.campsites = nil;
        self.campsites = [[NSMutableArray alloc] initWithArray:results];
    } else {
        self.campsites = nil;
        self.campsites = [[NSMutableArray alloc] init];
    }
    
    // Reload table data
    [self.tableView reloadData];
    // Set nav bar
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"Matching results";
    //navItem.title = [NSString stringWithFormat:@"Near %@", [[CHLSearchStore sharedStore] locationName] ];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
// Set number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

// Set number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.campsites.count > 0) {
        return self.campsites.count;
    } else {
        return 1;
    }
    
}

// Set section titles
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *titleString = [[NSString alloc] initWithFormat:@"Found %lu campsites", (unsigned long)self.campsites.count];
    return NSLocalizedString(titleString, titleString);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.campsites.count > 0) {
        // Configure the cell...
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == Nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier ];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        //add data to the cells
        cell.textLabel.text = self.campsites[indexPath.row][@"name"];
        if (![self.campsites[indexPath.row][@"phone"] isKindOfClass:[NSNull class]])
        {
            NSString *rawPhoneNumber = [NSString stringWithFormat:@"%@", self.campsites[indexPath.row][@"phone"]];
            cell.detailTextLabel.text = [[CHLSearchStore sharedStore] formatPhoneNumber:rawPhoneNumber];
        } else {
            cell.detailTextLabel.text = @"No phone";
        }
        // Use the appropriate image for campsite type
        if ( [self.campsites[indexPath.row][@"properties"][@"tribes"][0] isEqualToNumber:@1] ) {
            cell.imageView.image = [UIImage imageNamed:@"Rustic"];
        } else if ( [self.campsites[indexPath.row][@"properties"][@"tribes"][0] isEqualToNumber:@2] ) {
            cell.imageView.image = [UIImage imageNamed:@"RV"];
        } else if ([self.campsites[indexPath.row][@"properties"][@"tribes"][0] isEqualToNumber:@3]) {
            cell.imageView.image = [UIImage imageNamed:@"Backcountry"];
        } else if ([self.campsites[indexPath.row][@"properties"][@"tribes"][0] isEqualToNumber:@5]) {
            cell.imageView.image = [UIImage imageNamed:@"Horse"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"All"];
        }
        
        return cell;
        
    } else {
        // Configure the cell...
        static NSString *CellIdentifier = @"NoCampsitesCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == Nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier ];
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.text = @"No campsites found";
        cell.detailTextLabel.text = @"Bummer. Try another search.";
        cell.imageView.image = [UIImage imageNamed:@"Sadness"];
        
        return cell;
    }
}

// When a row is selected, push the corresponding campsite's detail view to the top of the view stack
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.cvc = [[CHLCampsiteViewController alloc] init];
    self.cvc.campsite = self.campsites[indexPath.row];
    //self.cvc.rovc = [[CHLReserveOnlineViewController alloc] init];
    //self.cvc.cmvc = [[CHLCampsiteMapViewController alloc] init];
    [self.navigationController pushViewController:self.cvc animated:YES];
}

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
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 
 */

@end


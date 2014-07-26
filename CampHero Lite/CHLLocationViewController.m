//
//  CHLLocationViewController.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import "CHLLocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "CHLSearchStore.h"
#import "AFHTTPRequestOperationManager.h"

@interface CHLLocationViewController () <UISearchBarDelegate>

// Search bar for location search
@property (nonatomic, weak) IBOutlet UISearchBar *locationSearchBar;

@end

@implementation CHLLocationViewController

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
    
    // Customize navbar
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"Find campsites near...";
    
    //Add searchbar delegation
    self.locationSearchBar.delegate = self;
    
    // Create a location manager instance to determine if location services are enabled. This manager instance will be
    // immediately destroyed afterwards.
    /*CLLocationManager *manager = [[CLLocationManager alloc] init];
     if (manager.locationServicesEnabled == NO) {*/
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"You are invisible to me" message:@"Your device has denied CampHero permission to access your current location. If you want to search for campsites near your current location, you'll first need to enable this in your Privacy Settings. The decision is yours!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

// When the user taps "Search" on the keyboard...
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *input = searchBar.text; // Grab the user input from the field
    // Execute the search
    [[CHLSearchStore sharedStore] runTextSearch:input searchIsAroundUserLocation:NO];
    
    searchBar.text = @""; // Clear the text the user entered
    [searchBar resignFirstResponder]; // Close the keyboard
    [self.navigationController popViewControllerAnimated:YES]; // Pop this VC off the NVC stack
    
}

// When the user taps the "Current location" button...
- (IBAction)tappedUseCurrentLocButton:(id)sender
{
    [[CHLSearchStore sharedStore] searchNearUser]; // Run the search
    [self.navigationController popViewControllerAnimated:YES]; // Pop this VC off the NVC stack
}

@end

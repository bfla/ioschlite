//
//  CHLCampsiteViewController.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import "CHLCampsiteViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "CHLMapMarker.h"
#import "CHLDirectionsViewController.h"
#import "CHLSearchStore.h"
//#import "CHLReserveOnlineViewController.h"

@interface CHLCampsiteViewController ()

@property (nonatomic, strong) IBOutlet UIView *contentView;
// header area
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIcon;
@property (nonatomic, strong) IBOutlet UIImageView *headerImage;
@property (nonatomic, strong) IBOutlet UIImageView *vibeIcon;
@property (nonatomic, weak) IBOutlet UILabel *vibeLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitle;
@property (nonatomic, weak) IBOutlet UILabel *rankLabel;
@property (nonatomic, weak) IBOutlet UILabel *ratingLabel;
@property (nonatomic, weak) IBOutlet UILabel *campPhoneLabel;
@property (nonatomic, weak) IBOutlet UIButton *callCampgroundButton;
// Map & location section
@property (nonatomic, weak) IBOutlet UILabel *coordinateLabel;
@property (nonatomic, weak) IBOutlet UIButton *directionsButton;
// Bookings section
@property (nonatomic, weak) IBOutlet UILabel *reservableLabel;
@property (nonatomic, weak) IBOutlet UILabel *walkinLabel;
@property (nonatomic, weak) IBOutlet UILabel *resPhoneLabel;
@property (nonatomic, weak) IBOutlet UIButton *callToReserveButton;
@property (nonatomic, weak) IBOutlet UIButton *resOnlineButton;
// Highlights and tags section
@property (nonatomic, weak) IBOutlet UILabel *highlightsHeader;
@property (nonatomic, weak) IBOutlet UITextView *highlightsTextView;

@end

@implementation CHLCampsiteViewController

#pragma mark - VC Lifecycle

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
    
    // Do any additional setup after loading the view from its nib. ==================================
    [self.view addSubview:self.contentView]; // Add content to the Scrollview
    ((UIScrollView *)self.view).contentSize = self.contentView.frame.size; // Size scrollview
    self.navigationController.navigationBar.topItem.title = @""; // Hide the navbar back button's title
    self.restorationIdentifier = @"CampsiteDetail";
}

- (void)viewDidUnload
{
    self.contentView = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self generateMap];
    [self setDefaults]; // Set IBOutlets to their blank states
    
    
    // Request additional data from web API
    NSString *campsiteURLString = [NSString stringWithFormat:@"http://gentle-ocean-6036.herokuapp.com/%@.json", self.campsite[@"properties"][@"url"] ];
    NSLog(@"Attempging to fetch JSON from this URL: %@", campsiteURLString);
    [self fetchData:campsiteURLString];
    
    // Set nav bar
    self.navigationController.navigationBarHidden = NO;
    //UINavigationItem *navItem = self.navigationItem;
    //navItem.title = self.campsite[@"properties"][@"title"];
    
    // Add content
    self.headerImage.image = [UIImage imageNamed:@"Header"];
    //= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Header"]];
    //[self.view addSubview:self.headerOverlay];
    
    // This data gets passed from the search page's JSON
    self.nameLabel.text = self.campsite[@"properties"][@"title"];
    NSString *latText = [NSString stringWithFormat:@"%.5f N", [self.campsite[@"geometry"][@"coordinates"][1] doubleValue]];
    NSString *lngText = [NSString stringWithFormat:@"%.5f W", -[self.campsite[@"geometry"][@"coordinates"][0] doubleValue]];
    self.coordinateLabel.text = [ NSString stringWithFormat:@"%@, %@", latText, lngText ];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - View preparation & customization

// Sets default/blank states for IBOutlets
-(void)setDefaults {
    [self.loadingIcon startAnimating];
    self.callCampgroundButton.hidden = YES;
    self.callToReserveButton.hidden = YES;
    self.vibeLabel.hidden = YES;
    self.subtitle.hidden = YES;
    self.rankLabel.hidden = YES;
    self.ratingLabel.hidden = YES;
    self.campPhoneLabel.hidden = YES;
    self.resPhoneLabel.hidden = YES;
    self.resOnlineButton.hidden = YES;
    self.highlightsHeader.hidden = YES;
    self.highlightsTextView.hidden = YES;
    //self.directionsButton.hidden = YES;
}

// This function runs if the AFNetworking request returned the campsite successfully
-(void)requestSuccessful
{
    [self.loadingIcon stopAnimating]; // Hide the loading icon
    
    // Add the photo
    /*NSURL *photoUrl = [NSURL URLWithString:self.campsiteJSON[@"photos"][0][@"url"]];
     [self.headerImage setImageWithUrl:photoUrl placeholderImage:[UIImage imageNamed:@"Header"]];
     NSString *photoLicense = self.campsiteJSON[@"photos"][0][@"license_text"];*/
    
    // Add the organization
    NSString *org = self.campsiteJSON[@"org"];
    self.subtitle.text = [[NSString alloc] initWithFormat:@"%@ campground", org];
    self.subtitle.hidden = NO;
    
    
    // Add the ranking
    // This isn't ready yet
    if (![self.campsiteJSON[@"city_rank"] isKindOfClass:[NSNull class]]) {
        NSLog(@"City rank exists.  Type is... %@", NSStringFromClass([self.campsiteJSON[@"city_rank"] class]));
        NSString *rankAsString = [self.campsiteJSON[@"city_rank"] stringValue];
        //NSLog(@"rankAsString is... %@", rankAsString);
        NSString *cityCount = self.campsiteJSON[@"city_count"];
        NSString *cityName = self.campsiteJSON[@"city"][@"name"];
        NSString *stateName = self.campsiteJSON[@"state"][@"abbreviation"];
        self.rankLabel.text = [[NSString alloc] initWithFormat:@"Ranked %@ of %@ campsites in %@, %@", rankAsString, cityCount, cityName, stateName];
        self.rankLabel.hidden = NO;
    }
    
    // Add the campsite vibe/style
    if (![self.campsiteJSON[@"tribes"] isKindOfClass:[NSNull class]]) { // If the campsiteJSON has a tribe attached...
        NSLog(@"Tribe exists.  Type is... %@", NSStringFromClass([self.campsiteJSON[@"tribes"][0][@"id"] class]));
        // Set the label for the vibe
        self.vibeLabel.text = self.campsiteJSON[@"tribes"][0][@"vibe"];
        self.vibeLabel.hidden = NO;
        
        // Use the appropriate image
        if ( [self.campsiteJSON[@"tribes"][0][@"id"] isEqualToNumber:@1] ) {
            self.vibeIcon.image = [UIImage imageNamed:@"Rustic"];
            //NSLog(@"This tribe's icon should be... %@", self.campsiteJSON[@"tribes"][0][@"vibe"]);
        } else if ( [self.campsiteJSON[@"tribes"][0][@"id"] isEqualToNumber:@2] ) {
            self.vibeIcon.image = [UIImage imageNamed:@"RV"];
        } else if ([self.campsiteJSON[@"tribes"][0][@"id"] isEqualToNumber:@3]) {
            self.vibeIcon.image = [UIImage imageNamed:@"Backcountry"];
        } else if ([self.campsiteJSON[@"tribes"][0][@"id"] isEqualToNumber:@5]) {
            self.vibeIcon.image = [UIImage imageNamed:@"Horse"];
        } else {
            self.vibeIcon.image = [UIImage imageNamed:@"All"];
        }
        
    } else { // If no tribe was fetched, use default icon and text
        NSLog(@"!Tribe was not found...");
        self.vibeIcon = [ [UIImageView alloc] initWithImage:[UIImage imageNamed:@"All"] ];
    }
    
    // Add the rating if it is available
    /*if (![self.campsiteJSON[@"avg_rating"] isKindOfClass:[NSNull class]]) {
     NSLog(@"Adding rating label...");
     self.ratingLabel.text = [NSString stringWithFormat:@"Rated %@ out of 5", self.campsiteJSON[@"avg_rating"] ];
     self.ratingLabel.hidden = NO;
     }*/
    
    // Add the manager's phone # if it is available
    if (![self.campsiteJSON[@"camp_phone"] isKindOfClass:[NSNull class]]) {
        NSLog(@"Adding camp phone number...");
        if ([self.campsiteJSON[@"camp_phone"] isKindOfClass:[NSString class]]) {
            self.campPhoneLabel.text = [[CHLSearchStore sharedStore]
                                        formatPhoneNumber:[NSString stringWithFormat:@"%@", self.campsiteJSON[@"camp_phone"] ]];
            self.campPhoneLabel.hidden = NO;
            self.callCampgroundButton.hidden = NO;
        }
        
    }
    
    // Add booking information
    // Takes reservations or not?
    //NSLog(@"Reservable is of type %@", NSStringFromClass([self.campsiteJSON[@"reservable"] class]));
    if ([self.campsiteJSON[@"reservable"] isEqual:@(YES)]) { // is failing to test properly
        NSLog(@"Adding reservable (true) label...");
        self.reservableLabel.text = @"Takes reservations";
    } else {
        NSLog(@"Adding reservable (false) label...");
        self.reservableLabel.text = @"Doesn't take reservations";
    }
    // First-come first-serve camping: Allowed or not?
    if ([self.campsiteJSON[@"walkin"] isEqual:@(YES)]) { // !Is failing to test properly
        NSLog(@"Adding walkin (true) label...");
        self.walkinLabel.text = @"No reservation is required";
    } else {
        self.walkinLabel.text = @"Reservation is required";
        NSLog(@"Adding walkin (false) label...");
    }
    // Reservation phone number if it is available
    if (![self.campsiteJSON[@"res_phone"] isKindOfClass:[NSNull class]]) {
        NSLog(@"Adding res_phone... Type is... %@", NSStringFromClass([self.campsiteJSON[@"res_phone"]class]));
        if ([self.campsiteJSON[@"res_phone"] isKindOfClass:[NSString class]]) {
            self.resPhoneLabel.text = [[CHLSearchStore sharedStore]
                                       formatPhoneNumber:[NSString stringWithFormat:@"%@", self.campsiteJSON[@"res_phone"] ]];
            self.resPhoneLabel.hidden = NO;
            self.callToReserveButton.hidden = NO;
        }
    }
    
    // Add highlights and tags, if there are any
    if (self.campsiteJSON[@"tags"] && [self.campsiteJSON[@"tags"] count] ) {
        self.highlightsHeader.hidden = NO;
        self.highlightsTextView.hidden = NO;
        [self addTags:self.campsiteJSON[@"tags"]];
    }
    
    // NOT READY YET
    // Reserve online button appears only if res_url is available
    /*if (![self.campsiteJSON[@"res_url"] isKindOfClass:[NSNull class]]) {
     self.resOnlineButton.hidden = NO;
     }*/
    
    // Add reviews - NOT READY YET
    /*if ([self.campsiteJSON[@"reviews"] count] > 0) {
     self.reviewBody.text = self.campsiteJSON[@"reviews"][0][@"body"];
     }*/
    
}

// Handles failed JSON requests
-(void)requestUnsuccessful {
    // Add local notification here
}

// Creates the mapview
-(void)generateMap {
    
    // Initialize the map and set properties ========================================
    //self.mapView = [[MKMapView alloc] init];
    self.mapView.delegate = self;
    //self.mapView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.showsUserLocation = NO;
    self.mapView.pitchEnabled = NO;
    self.mapView.rotateEnabled = NO;
    
    // Set the map as a subview ======================================================***
    //[self.view addSubview:self.mapView];
    
    // Set the map region defaults============================================================***
    // Create the center coordinate:
    double centerLat = [self.campsite[@"geometry"][@"coordinates"][1] doubleValue];
    double centerLng = [self.campsite[@"geometry"][@"coordinates"][0] doubleValue];
    //NSLog(@"Campsite detail map center is %f, %f", centerLat, centerLng);
    CLLocationCoordinate2D startCenter = CLLocationCoordinate2DMake(centerLat, centerLng);
    
    // Build a region around the center coordinate
    CLLocationDistance startRegionWidth = 3000; // in meters
    CLLocationDistance startRegionHeight = 3000; // in meters
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(startCenter, startRegionWidth, startRegionHeight);
    // Set the mapView around the region
    [self.mapView setRegion:startRegion animated:YES];
}

// Add tags for the campground
-(void)addTags:(NSArray *)tags
{
    NSMutableArray *facilityTags = [[NSMutableArray alloc] init];
    NSMutableArray *ruleTags = [[NSMutableArray alloc] init];
    NSMutableArray *otherTags = [[NSMutableArray alloc] init];
    NSString *highlightsText = @"";
    NSString *spacer = @" \u2022";
    
    NSLog(@"Processing tags...");
    for (NSDictionary *tag in tags) {
        //NSLog(@"Tag category is... %@", tag[@"type"]);
        if ([tag[@"type"] isEqualToString:@"Facilities"]) {
            //NSLog(@"Categorizing facility tags...");
            [facilityTags addObject:tag];
        } else if ([tag[@"type"] isEqualToString:@"Rules"]) {
            [ruleTags addObject:tag];
        } else {
            [otherTags addObject:tag];
        }
    }
    
    // Add tags of type "Facilities"
    //NSLog(@"Adding facility tags...");
    if (facilityTags && facilityTags.count) {
        //NSLog(@"Creating facilityText...");
        NSString *facilityText = @"Facilities: ";
        for (NSDictionary *tag in facilityTags) {
            facilityText = [facilityText stringByAppendingString:spacer];
            facilityText = [facilityText stringByAppendingString:tag[@"name"]];
            //NSLog(@"facilityText says... %@", facilityText);
        }
        highlightsText = [highlightsText stringByAppendingString:facilityText];
        highlightsText = [highlightsText stringByAppendingString:@"\n \n"];
    }
    // Add tags of type "rules"
    if (ruleTags && ruleTags.count) {
        //NSLog(@"Creating facilityText...");
        NSString *ruleText = @"Rules: ";
        for (NSDictionary *tag in ruleTags) {
            ruleText = [ruleText stringByAppendingString:spacer];
            ruleText = [ruleText stringByAppendingString:tag[@"name"]];
            //NSLog(@"facilityText says... %@", rulesText);
        }
        highlightsText = [highlightsText stringByAppendingString:ruleText];
        highlightsText = [highlightsText stringByAppendingString:@"\n \n"];
    }
    // Add Tags of type "other"
    if (otherTags && otherTags.count) {
        //NSLog(@"Creating facilityText...");
        NSString *otherText = @"Tags: ";
        for (NSDictionary *tag in otherTags) {
            otherText = [otherText stringByAppendingString:spacer];
            otherText = [otherText stringByAppendingString:tag[@"name"]];
            //NSLog(@"facilityText says... %@", rulesText);
        }
        highlightsText = [highlightsText stringByAppendingString:otherText];
    }
    
    self.highlightsTextView.text = highlightsText; // Add the final text
    self.highlightsTextView.editable = NO; // Don't let user edit the text
    
}

#pragma mark - Actions

-(IBAction)getDirections:(id)sender {
    // Ask if user is ready to go to Apple Maps
    //UIAlertView *appleMapsAlert = [[UIAlertView alloc] initWithTitle:@"Open Apple Maps" message:@"Directions are not one of CampHero's superpowers. Open detailed directions in Apple Maps?" delegate:self cancelButtonTitle:@"No way" otherButtonTitles:@"Heck yeah", nil];
    //[appleMapsAlert show];
    
    if (![CLLocationManager locationServicesEnabled] ) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"You're invisible" message:@"You have disabled location services for this device. For CampHero to find you directions to the campsite, it needs your current location. The decision is yours!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else {
        // Present the CHLDirectionsVC as a modal and pass it the campsite
        CHLDirectionsViewController *dvc = [[CHLDirectionsViewController alloc] init];
        dvc.campsite = self.campsite;
        UINavigationController *dnc = [[UINavigationController alloc] initWithRootViewController:dvc];
        [self.navigationController presentViewController:dnc animated:YES completion:nil];
    }
    
}

// Opens a web view to visit the campsite's reservation webpage
-(IBAction)visitReservationWebsite:(id)sender {
    // This feature doesn't work yet
    /*if (![self.campsiteJSON[@"res_url"] isKindOfClass:[NSNull class]]) {
     NSLog(@"Attempting to open reservation website with URL: %@", self.campsiteJSON[@"res_url"]);
     NSURL *resURL = [NSURL URLWithString:self.campsiteJSON[@"res_url"]];
     self.rovc = [[CHLReserveOnlineViewController alloc] init];
     self.rovc.URL = resURL;
     self.rovc.title = @"Reserve Online";
     [self.navigationController pushViewController:self.rovc animated:YES];
     }*/
}

// Requests permission to call the campground
-(IBAction)callCampground:(id)sender {
    // Do it only if a phone number is available
    
    if (![self.campsiteJSON[@"camp_phone"] isKindOfClass:[NSNull class]]) {
        // Check if the device can make phone calls and respond appropriately
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
            NSLog(@"Calling campground phone number...");
            NSString *campgroundPhoneNumber = [@"telprompt://" stringByAppendingString:self.campsiteJSON[@"camp_phone"] ];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:campgroundPhoneNumber]];
        } else {
            [self showNoPhoneAlert];
        }
    }
}

// Requests permission to call the reservation hotline
-(IBAction)callToReserve:(id)sender {
    // Do it only if a phone number is available
    if (![self.campsiteJSON[@"res_phone"] isKindOfClass:[NSNull class]]) {
        // Check if the device can make phone calls and respond appropriately
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
            NSLog(@"Calling reservation phone number");
            NSString *reservePhoneNumber = [@"telprompt://" stringByAppendingString:self.campsiteJSON[@"res_phone"] ];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reservePhoneNumber]];
        } else {
            [self showNoPhoneAlert];
        }
    }
}

-(void)showNoPhoneAlert
{
    UIAlertView *noPhoneAlert = [[UIAlertView alloc] initWithTitle:@"No phone services found" message:@"Sorry, this device doesn't appear to have phone abilities." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [noPhoneAlert show];
}

# pragma mark - Delegation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If user taps the OK or yes button, send them to Apple Maps with the directions
    if (buttonIndex == 0) {
    } else {
        NSString *directionsString = [[NSString alloc]
                                      initWithFormat:@"http://maps.apple.com/?daddr=%f,%f&saddr=%@", [self.campsite[@"geometry"][@"coordinates"][1] doubleValue], [self.campsite[@"geometry"][@"coordinates"][0] doubleValue], @"Current Location"];
        NSLog(@"Sending query to apple maps from NSString: %@", directionsString);
        NSURL* directionsURL = [[NSURL alloc] initWithString:[directionsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:directionsURL];
    }
}

# pragma mark - Data handlers

- (void)fetchData:(NSString *)campsiteUrl
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:campsiteUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseJSON) {
        NSLog(@"campsiteJSON: %@", responseJSON);
        self.campsiteJSON = responseJSON;
        [self requestSuccessful];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.fetchFailedError = YES;
        NSLog(@"Error with JSON Request: %@", error);
        UIAlertView *fetchFailedAlert = [[UIAlertView alloc] initWithTitle:@"Dastardly bugs!" message:@"Bummer.  I was unable to fetch this campsite for you. Maybe you lost your internet connection or maybe my servers were exposed to some Camptonite.  If this problem persists, please contact my trusted sidekick: brian@getcamphero.com." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [fetchFailedAlert show];
        [self requestUnsuccessful];
    }];
    
}
@end
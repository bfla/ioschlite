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
//#import "CHLDirectionsViewController.h"
#import "CHLSearchStore.h"
#import "CHLCampsite.h"
#import "CHLUtilities.h"
//#import "CHLReserveOnlineViewController.h"

@interface CHLCampsiteViewController ()

@property (nonatomic, strong) IBOutlet UIView *contentView;
// header area
//@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIcon;
@property (nonatomic, strong) IBOutlet UIImageView *headerImage;
@property (nonatomic, strong) IBOutlet UIImageView *vibeIcon;
@property (nonatomic, strong) IBOutlet UIImageView *footerImage;
@property (nonatomic, weak) IBOutlet UILabel *vibeLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *subtitle;
@property (nonatomic, weak) IBOutlet UILabel *campPhoneLabel;
@property (nonatomic, weak) IBOutlet UIButton *callCampgroundButton;
// Map & location section
@property (nonatomic, weak) IBOutlet UILabel *coordinateLabel;
@property (nonatomic, weak) IBOutlet UIButton *directionsButton;
@property (nonatomic, weak) IBOutlet UILabel *elevationLabel;
// Facilities
@property (nonatomic, strong) IBOutlet UIImageView *outhouseImage;
@property (nonatomic, strong) IBOutlet UIImageView *showerImage;
@property (nonatomic, strong) IBOutlet UIImageView *electricImage;
@property (nonatomic, strong) IBOutlet UIImageView *dumpImage;
@property (nonatomic, strong) IBOutlet UIImageView *waterImage;
@property (nonatomic, weak) IBOutlet UILabel *outhouseLabel;
@property (nonatomic, weak) IBOutlet UILabel *showerLabel;
@property (nonatomic, weak) IBOutlet UILabel *electricLabel;
@property (nonatomic, weak) IBOutlet UILabel *waterLabel;
@property (nonatomic, weak) IBOutlet UILabel *dumpLabel;
// Campground URL
@property (nonatomic, weak) IBOutlet UILabel *urlLabel;
@property (nonatomic, weak) IBOutlet UIButton *visitWebsiteButton;
// Campground warnings
@property (nonatomic, weak) IBOutlet UILabel *warningHeader;
@property (nonatomic, weak) IBOutlet UITextView *warningTextView;

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
    //NSString *campsiteURLString = [NSString stringWithFormat:@"http://gentle-ocean-6036.herokuapp.com/%@.json", self.campsite[@"properties"][@"url"] ];
    //NSLog(@"Attempging to fetch JSON from this URL: %@", campsiteURLString);
    //[self fetchData:campsiteURLString];
    
    // Set nav bar
    self.navigationController.navigationBarHidden = NO;
    //UINavigationItem *navItem = self.navigationItem;
    //navItem.title = self.campsite[@"properties"][@"title"];
    
    // Add content
    self.headerImage.image = [UIImage imageNamed:@"Header"];
    self.footerImage.image = [UIImage imageNamed:@"Footer"];
    //= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Header"]];
    //[self.view addSubview:self.headerOverlay];
    [self fillBlanks];
    
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
    //[self.loadingIcon startAnimating];
    self.callCampgroundButton.hidden = YES;
    //self.vibeLabel.hidden = YES;
    //self.subtitle.text = @"Unknown";
    //self.campPhoneLabel.hidden = YES;
    self.elevationLabel.hidden = YES;
    self.urlLabel.hidden = YES;
    self.visitWebsiteButton.hidden = YES;
    self.warningHeader.hidden = YES;
    self.warningTextView.hidden = YES;
    
    self.showerLabel.text = @"no showers";
    self.outhouseLabel.text = @"no toilets";
    self.electricLabel.text = @"no electric";
    self.waterLabel.text = @"no water hookup";
    self.dumpLabel.text = @"no dump stn";
}

-(void)fillBlanks {
    self.nameLabel.text = self.campsite.name;
    self.vibeIcon.image = [UIImage imageNamed:self.campsite.imageName];
    self.vibeLabel.text = self.campsite.vibeString;
    if (self.campsite.owner) {
        self.subtitle.text = self.campsite.owner;
    }
    if (self.campsite.elevation) {
        self.elevationLabel.text = [NSString stringWithFormat:@"%d", self.campsite.elevation];
    }

    NSString *latText = [NSString stringWithFormat:@"%.5f N", self.campsite.latitude];
    NSString *lngText = [NSString stringWithFormat:@"%.5f W", -self.campsite.longitude];
    self.coordinateLabel.text = [ NSString stringWithFormat:@"%@, %@", latText, lngText ];
    
    // Add phone number and call button if phone number is available...
    if (![self.campsite.phone isKindOfClass:[NSNull class]]) {
        //self.campPhoneLabel.text = [[CHLSearchStore sharedStore] formatPhoneNumber:self.campsite.phone];
        NSString *formattedPhoneNumber = [self.campsite formattedPhoneNumber];
        self.campPhoneLabel.text = formattedPhoneNumber;
        if (![formattedPhoneNumber isEqualToString:@"No phone"]) {
            self.callCampgroundButton.hidden = NO;
        }
    } else {
        self.campPhoneLabel.text = @"No phone";
    }
    
    self.showerImage.image = [UIImage imageNamed:[self.campsite showerImageName]];
    self.outhouseImage.image = [UIImage imageNamed:[self.campsite outhouseImageName]];
    self.electricImage.image = [UIImage imageNamed: [self.campsite electricImageName]];
    self.dumpImage.image = [UIImage imageNamed:[self.campsite dumpImageName]];
    self.waterImage.image = [UIImage imageNamed:[self.campsite waterImageName]];
    
    if (self.campsite.showers) {
        self.showerLabel.text = @"showers";
    }
    
    if (self.campsite.no_toilets) {
        self.outhouseLabel.text = @"no toilets";
    } else if (self.campsite.likely_toilets) {
        self.outhouseLabel.text = @"toilets";
    } else {
        self.outhouseLabel.text = @"maybe toilets";
    }
    
    if (self.campsite.electric) {
        self.electricLabel.text = @"electricity";
    }
    if (self.campsite.water) {
        self.waterLabel.text = @"water hookups";
    }
    if (self.campsite.dump) {
        self.dumpLabel.text = @"dump station";
    }

    if (self.campsite.url) {
        self.urlLabel.text = self.campsite.url;
        self.urlLabel.hidden = NO;
        self.visitWebsiteButton.hidden = NO;
    }
    
    if (self.campsite.warning) {
        self.warningTextView.text = self.campsite.warning;
        self.warningHeader.hidden = NO;
        self.warningTextView.hidden = NO;
    }
}



// Creates the mapview
-(void)generateMap {
    
    // Initialize the map and set properties ========================================
    //self.mapView = [[MKMapView alloc] init];
    self.mapView.delegate = self;
    //self.mapView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
    self.mapView.showsUserLocation = YES;
    self.mapView.pitchEnabled = NO;
    self.mapView.rotateEnabled = NO;
    
    // Set the map as a subview ======================================================***
    //[self.view addSubview:self.mapView];
    
    // Set the map region defaults============================================================***
    // Create the center coordinate:
    double centerLat = self.campsite.latitude;
    double centerLng = self.campsite.longitude;
    //NSLog(@"Campsite detail map center is %f, %f", centerLat, centerLng);
    CLLocationCoordinate2D startCenter = CLLocationCoordinate2DMake(centerLat, centerLng);
    
    // Build a region around the center coordinate
    CLLocationDistance startRegionWidth = 3000; // in meters
    CLLocationDistance startRegionHeight = 3000; // in meters
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(startCenter, startRegionWidth, startRegionHeight);
    // Set the mapView around the region
    [self.mapView setRegion:startRegion animated:YES];
}

#pragma mark - Actions

-(IBAction)getDirections:(id)sender {
    if (![CLLocationManager locationServicesEnabled] ) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"You're invisible" message:@"You have disabled location services for this device. For CampHero to find you directions to the campsite, it needs your current location. The decision is yours!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else if (!self.mapView.userLocation.coordinate.latitude) {
        UIAlertView *locationUnknownAlert = [[UIAlertView alloc] initWithTitle:@"I can't find you" message:@"For some reason, your device cannot identify your current location. Maybe try copying the latitude and longitude and pasting it into a map app like Apple Maps or Google Maps?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [locationUnknownAlert show];
    } else {
        UIAlertView *openMapAlert = [[UIAlertView alloc] initWithTitle:@"Open Apple Maps" message:@"Directions are not one of CampHero's superpowers. Open detailed directions in Apple Maps?" delegate:self cancelButtonTitle:@"No way" otherButtonTitles:@"Heck yeah", nil];
        [openMapAlert show];
    }
    // Present the CHLDirectionsVC as a modal and pass it the campsite
    //CHLDirectionsViewController *dvc = [[CHLDirectionsViewController alloc] init];
    //dvc.campsite = self.campsite;
    //UINavigationController *dnc = [[UINavigationController alloc] initWithRootViewController:dvc];
    //[self.navigationController presentViewController:dnc animated:YES completion:nil];
    
}


// Requests permission to call the campground
-(IBAction)callCampground:(id)sender {
    // Do it only if a phone number is available
    
    if (![self.campsite.phone isKindOfClass:[NSNull class]]) {
        // Check if the device can make phone calls and respond appropriately
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
            NSLog(@"Calling campground phone number...");
            NSString *campgroundPhoneNumber = [@"telprompt://" stringByAppendingString:self.campsite.phone ];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:campgroundPhoneNumber]];
        } else {
            [self showNoPhoneAlert];
        }
    }
}

-(IBAction)visitWebsite:(id)sender {
    if ([[CHLUtilities sharedUtilities] verifyWebConnection]) {
        
        if (self.campsite.url) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithString:self.campsite.url] ];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            } else {
                UIAlertView *noBrowserAlert = [[UIAlertView alloc] initWithTitle:@"Denied browser access" message:@"Sorry, this device won't allow me to open this website for you.  Maybe try visiting the url in your device's browser?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [noBrowserAlert show];
            }
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
                                      initWithFormat:@"http://maps.apple.com/?daddr=%f,%f&saddr=%f,%f", self.campsite.latitude, self.campsite.longitude, self.mapView.userLocation.coordinate.latitude, self.mapView.userLocation.coordinate.longitude];
        NSURL* directionsURL = [[NSURL alloc] initWithString:[directionsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:directionsURL];
    }
}

@end
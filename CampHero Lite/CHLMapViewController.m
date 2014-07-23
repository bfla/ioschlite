//
//  CHLMapViewController.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import "CHLMapViewController.h"
#import "CHLSearchStore.h"
#import "CHLCampsite.h"
#import "CHLMapMarker.h"
#import "CHLCampsiteViewController.h"

@interface CHLMapViewController ()

@property (nonatomic, weak) IBOutlet UILabel *noticeLabel;
@property (nonatomic, weak) IBOutlet UIButton *resetLocationButton;
@property BOOL didUpdateUserLocation;

@end

@implementation CHLMapViewController

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
    // Do any additional setup after loading the view from its nib.
    
    // Initialize the map and set properties ========================================
    self.mapView = [[MKMapView alloc] init];
    self.mapView.delegate = self;
    self.mapView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.mapView.scrollEnabled = YES;
    self.mapView.zoomEnabled = YES;
    self.mapView.showsUserLocation = YES;
    self.mapView.pitchEnabled = NO;
    self.mapView.rotateEnabled = NO;
    
    // Set the map as a subview ======================================================***
    [self.view addSubview:self.mapView];
    
    // Set the map region defaults============================================================***
    // Create the center coordinate:
    double centerLat = [@45.126311 doubleValue];
    double centerLng = [@-85.989304 doubleValue];
    CLLocationCoordinate2D startCenter = CLLocationCoordinate2DMake(centerLat, centerLng);
    
    // Build a region around the center coordinate
    CLLocationDistance startRegionWidth = 500000; // in meters
    CLLocationDistance startRegionHeight = 500000; // in meters
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(startCenter, startRegionWidth, startRegionHeight);
    // Set the mapView around the region
    [self.mapView setRegion:startRegion animated:YES];
    
    // Add subviews ========================================================
    [self.view addSubview:self.resetLocationButton];
    [self.view addSubview:self.noticeLabel];
    // Hide the reset button until another method tells it to become visible
    self.resetLocationButton.hidden = YES;
    
}

// When the view is about to appear, set the current campsites and add markers for them
- (void)viewWillAppear:(BOOL)animated
{
    // Hide the nav bar
    self.navigationController.navigationBarHidden = YES;
    self.noticeLabel.hidden = YES;
    
    // Get current filtered campsites =============================================
    //NSArray *results = [[CHLSearchStore sharedStore] campsites];
    NSArray *results = [[CHLSearchStore sharedStore] filteredCampsites];
    self.campsites = [[NSMutableArray alloc] initWithArray:results];
    results = nil;
    
    // reset notices
    [self addNotices];
    
    // Create markers from the initial data
    [self createMarkers:self.campsites];
    
    // Recenter the map if appropriate
    if ( [[CHLSearchStore sharedStore] shouldResetMap]) {
        
        if ( [[CHLSearchStore sharedStore] locationIsUser]) {
            // Location is current user. Reframe accordingly.
            [self reframeMapViewAroundUser:self.mapView];
            // Hide the search reset button again
            self.resetLocationButton.hidden = YES;
            [[CHLSearchStore sharedStore] mapWasReset];
            
        } else if ([[CHLSearchStore sharedStore] lastSearchWasTextSearch]) {
            // Location is from a text search.  Reframe accordingly.
            [self reframeMapView:self.mapView aroundCampsites:self.campsites];
            // Hide the search reset button again
            self.resetLocationButton.hidden = YES;
            // set shouldResetMap to false
            [[CHLSearchStore sharedStore] mapWasReset];
        } else {
            // leave it as the user left it
        }
    }
}

// When the view disappears, remove markers so they can refresh from scratch when it loads again
- (void)viewWillDisappear:(BOOL)animated
{
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Map Customization
// When user taps a button, search this area!
- (IBAction)searchThisArea:(id)sender
{
    // Hide the reset button (until another method tells it to become visible)
    self.resetLocationButton.hidden = YES;
    
    // Hide the notice label (until another method tells it to become visible)
    self.noticeLabel.hidden = YES;
    
    // Calculate which area we should search around
    CLLocationCoordinate2D mapCenter = self.mapView.centerCoordinate;
    
    // Prepare the search query's keywords
    NSString *keywords = [NSString stringWithFormat:@"%f, %f", mapCenter.latitude, mapCenter.longitude];
    
    // Add distance parameter for search query
    // First get the map center
    CLLocation *mapCenterLoc = [[CLLocation alloc]
                                initWithLatitude:self.mapView.centerCoordinate.latitude
                                longitude:self.mapView.centerCoordinate.longitude];
    // Now measure the distance to the top right corner. This is a double.
    CLLocationDegrees mapWidthInDegrees = self.mapView.region.span.latitudeDelta;
    CLLocationDegrees mapHeightInDegrees = self.mapView.region.span.longitudeDelta;
    CLLocation *measuringLoc = [[CLLocation alloc]
                                initWithLatitude:(self.mapView.centerCoordinate.latitude + mapWidthInDegrees/2)
                                longitude:(self.mapView.centerCoordinate.longitude + mapHeightInDegrees/2)];
    
    // Calculate the distance & save it
    CLLocationDistance distanceDoubleInMeters = [mapCenterLoc distanceFromLocation:measuringLoc];
    double distanceInMiles = (distanceDoubleInMeters / 1000) * .621371;
    NSString *distanceString = [[NSString alloc] initWithFormat:@"%f", distanceInMiles ];
    NSLog(@"Distance: %@", distanceString);
    
    // Send the search to CHLSearchStore using the areaSearch method
    [[CHLSearchStore sharedStore] mapAreaSearch:self keywords:keywords distance:distanceString];
    
}

// Resets markers on the map.  This gets called from searchArea method in CHLSearchStore
- (void)resetMarkers {
    
    //NSArray *results = [[CHLSearchStore sharedStore] campsites];
    NSArray *results = [[CHLSearchStore sharedStore] filteredCampsites];
    NSLog(@"Received results...");
    self.campsites = nil;
    self.campsites = [[NSMutableArray alloc] initWithArray:results];
    NSLog(@"Stored marker campsites...");
    results = nil;
    
    // First remove all annotations
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    if (self.campsites.count > 0) {
        // Create new markers from the campsites
        [self createMarkers:self.campsites];
    }
    
    // reset notices
    [self addNotices];
}

// Creates markers from a mutable array of campsites
- (void)createMarkers:(NSMutableArray *)campsites
{
    // Now add new annotations
    for(NSDictionary *campsite in campsites) {
        CHLMapMarker *marker = [[CHLMapMarker alloc] init];
        double markerLat = [campsite[@"latitude"] doubleValue];
        double markerLng = [campsite[@"longitude"] doubleValue];
        marker.campsite = campsite;
        marker.coordinate = CLLocationCoordinate2DMake(markerLat, markerLng);
        marker.title = campsite[@"name"];
        NSString *rawPhoneNumber = campsite[@"phone"];
        if (![rawPhoneNumber isKindOfClass:[NSNull class]]) {
            NSString *phoneString = [campsite[@"phone"] stringValue];
            marker.subtitle = [[CHLSearchStore sharedStore] formatPhoneNumber:phoneString];
        }
        [self.mapView addAnnotation:marker];
    }
    
}

- (void)reframeMapView:(MKMapView *)mapView aroundCampsites:(NSMutableArray *)campsites
{
    // Build arrays for campsite lats and lngs
    NSMutableArray *lats = [[NSMutableArray alloc] init];
    NSMutableArray *lngs = [[NSMutableArray alloc] init];
    for (NSDictionary *campsite in campsites) {
        [lats addObject:[NSNumber
                         numberWithDouble:[campsite[@"latitude"] doubleValue]]];
        [lngs addObject:[NSNumber
                         numberWithDouble:[campsite[@"longitude"] doubleValue]]];
    }
    
    // Calcualte the smallest and largest lats and lngs
    [lats sortUsingSelector:@selector(compare:)];
    [lngs sortUsingSelector:@selector(compare:)];
    double smallestLat = [ lats[0] doubleValue];
    double biggestLat = [ [lats lastObject] doubleValue];
    double smallestLng = [ lngs[0] doubleValue];
    double biggestLng = [ [lngs lastObject] doubleValue];
    
    // Calculate the center of the region
    CLLocationCoordinate2D campsitesCenter = CLLocationCoordinate2DMake(
                                                                        (biggestLat + smallestLat)/2,
                                                                        (biggestLng + smallestLng)/2);
    // Calculate the span of the region
    MKCoordinateSpan campsitesSpan = MKCoordinateSpanMake(
                                                          1.1*(biggestLat - smallestLat),
                                                          1.25*(biggestLng - smallestLng));
    // Build the region and reframe the map around it
    MKCoordinateRegion region = MKCoordinateRegionMake(campsitesCenter, campsitesSpan);
    [mapView setRegion:region];
}

- (void)reframeMapViewAroundUser:(MKMapView *)mapView
{
    // Get the center
    CLLocation *userInitLocation = [[CHLSearchStore sharedStore] userLocation];
    CLLocationCoordinate2D mapCenter = userInitLocation.coordinate;
    // Build the region to display
    CLLocationDistance regionWidth = 100000; // in meters so roughly 50 miles
    CLLocationDistance regionHeight = 100000; // in meters so roughly 50 miles
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapCenter, regionWidth, regionHeight);
    // Set the mapView around the region
    [mapView setRegion:region animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)marker
{
	MKPinAnnotationView *markerView = nil;
	if ([marker isKindOfClass:[CHLMapMarker class]])
	{
		markerView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
		if (markerView == nil)
		{
			markerView = [[MKPinAnnotationView alloc] initWithAnnotation:marker reuseIdentifier:@"Pin"];
			markerView.image = [UIImage imageNamed:@"MapMarker"];
            markerView.canShowCallout = YES;
            // Make disclosure button that navigates to detail page
            UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [infoButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
            // We can respond to this using the calloutAccessoryControlTapped delegate method
            markerView.rightCalloutAccessoryView = infoButton;
			//markerView.animatesDrop = YES;
		}
	} else if ([marker isKindOfClass:[MKUserLocation class]]) {
        // If the marker is the user location marker, use the default view for user locations
        return nil;
    }
	return markerView;
}

#pragma mark - Actions
// When the user reframes the map...
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    // Show the reset button, which resets the campsites based on the current view
    self.resetLocationButton.hidden = NO;
}

// user tapped the disclosure button in the callout
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    // first figure out which marker number we're accessing
    CHLMapMarker *marker = [view annotation];
    
    //int index = (int)[self.mapView.annotations indexOfObjectIdenticalTo:marker];
    
    // Since campsites should have the same index as markers...
    // Navigate to the campsite that has the same index as the marker
    CHLCampsiteViewController *detailVC = [[CHLCampsiteViewController alloc] init];
    detailVC.campsite = [[CHLCampsite alloc] initWithJSON:marker.campsite];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - Notifications
- (void)addNotices
{
    if (self.campsites.count == 0) {
        // No campsites returned.  Display "no results" notice.
        //self.noticeLabel.text = @"Bummer. No campsites here";
        //self.noticeLabel.hidden = NO;
        UIAlertView *noCampsitesAlert = [[UIAlertView alloc] initWithTitle:@"No campsites here!" message:@"No public campgrounds can hide from CampHero!  There probably just aren't any public campgrounds here that fit your criteria. (Private campgrounds coming soon!)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noCampsitesAlert show];
        self.resetLocationButton.hidden = NO;
    } else if (self.campsites.count < 100) {
        // This is the normal case.  No notices.
        self.noticeLabel.hidden = YES;
    } else {
        // Maximum number of campsites was reached. Display notice.
        //self.noticeLabel.text = @"Zoom in farther to see more campsites";
        //self.noticeLabel.hidden = NO;
        UIAlertView *maxReachedAlert = [[UIAlertView alloc] initWithTitle:@"Wowza, too many campsites!" message:@"I found so many campsites that I can't show them all.  Zoom in further and search the area to find more campsites." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [maxReachedAlert show];
    }
    // Display search errors
    if ([[CHLSearchStore sharedStore] noWifiError]) {
        self.noticeLabel.text = @"Ruh roh! You must connect to the web.";
        self.noticeLabel.hidden = NO;
    } else if ([[CHLSearchStore sharedStore] noPermissionError]) {
        self.noticeLabel.text = @"Your device won't let me access your current location.";
        self.noticeLabel.hidden = NO;
    } else if ([[CHLSearchStore sharedStore] searchFailedError]) {
        self.noticeLabel.text = @"Something went wrong. Check your Wifi connection and try another search.";
        self.noticeLabel.hidden = NO;
    }
    
}

@end

//
//  CHLDirectionsViewController.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import "CHLDirectionsViewController.h"
#import "CHLCampsiteViewController.h"
#import "CHLMapMarker.h"
#import "CHLSearchStore.h"
#import "CHLCampsite.h"

@interface CHLDirectionsViewController ()

@property (nonatomic, strong) MKRoute *route;
@property (nonatomic) CLLocationCoordinate2D campsiteCoordinate;
//@property (nonatomic, weak) IBOutlet UITableView *stepByStepTable;

@end

@implementation CHLDirectionsViewController

# pragma mark - VC Lifecycle
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
    self.navigationItem.title = @"Directions";
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                 target:self
                                 action:@selector(dismissDirections:)];
    self.navigationItem.leftBarButtonItem = doneItem;
    UIBarButtonItem *dirDetailsItem = [[UIBarButtonItem alloc]
                                       initWithTitle:@"See Route" style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(tappedDetailsButton:)];
    self.navigationItem.rightBarButtonItem = dirDetailsItem; // Toggles between map and step-by-step directions
    
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
    double centerLat = [@45.126311 doubleValue];
    double centerLng = [@-85.989304 doubleValue];
    CLLocationCoordinate2D startCenter = CLLocationCoordinate2DMake(centerLat, centerLng);
    
    // Build a region around the center coordinate
    CLLocationDistance startRegionWidth = 500000; // in meters
    CLLocationDistance startRegionHeight = 500000; // in meters
    MKCoordinateRegion startRegion = MKCoordinateRegionMakeWithDistance(startCenter, startRegionWidth, startRegionHeight);
    // Set the mapView around the region
    [self.mapView setRegion:startRegion animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self saveCoordinate];
    [self resetMapArea]; // Reset the map area
    [self addMarker]; // Add campsite marker
    [self addDirections]; // Add directions to the map
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Actions
-(void)dismissDirections:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    //[self dismissViewControllerAnimated:NO completion:nil];
}

-(void)tappedDetailsButton:(id)sender
{
    UIAlertView *noCampsitesAlert = [[UIAlertView alloc] initWithTitle:@"Open Apple Maps" message:@"Directions are not one of CampHero's superpowers. Open detailed directions in Apple Maps?" delegate:self cancelButtonTitle:@"No way" otherButtonTitles:@"Heck yeah", nil];
    [noCampsitesAlert show];
}

# pragma mark - Map Customization
- (void)saveCoordinate // Saves the campsite's coordinate
{
    double campsiteLat = self.campsite.latitude;
    double campsiteLng = self.campsite.longitude;
    self.campsiteCoordinate = CLLocationCoordinate2DMake(campsiteLat, campsiteLng);
}

- (void)resetMapArea
{
    // Center the map around the user
    CLLocationCoordinate2D newCenter = self.mapView.userLocation.coordinate;
    
    // Build a region around the center
    CLLocationDistance newRegionWidth = 500000; // in meters
    CLLocationDistance newRegionHeight = 500000; // in meters
    MKCoordinateRegion newRegion = MKCoordinateRegionMakeWithDistance(newCenter, newRegionWidth, newRegionHeight);
    
    // Set the map region to this region
    [self.mapView setRegion:newRegion];
    
}

- (void)addMarker
{
    CHLMapMarker *marker = [[CHLMapMarker alloc] init];
    marker.campsite = self.campsite;
    marker.coordinate = self.campsiteCoordinate;
    marker.title = self.campsite.name;
    marker.subtitle = [self.campsite formattedPhoneNumber];
    [self.mapView addAnnotation:marker];
    
}

- (void)addDirections
{
    //Create Start and endpoints
    MKMapItem *startPoint = [MKMapItem mapItemForCurrentLocation];
    MKPlacemark *campsitePlacemark = [[MKPlacemark alloc] initWithCoordinate:self.campsiteCoordinate addressDictionary:nil];
    MKMapItem *endPoint = [[MKMapItem alloc] initWithPlacemark:campsitePlacemark];
    
    // Create the request
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    //request.transportType = MKDirectionsTransportTypeAutomobile;
    [request setSource:startPoint]; // sets start point to a MKMapItem
    [request setDestination:endPoint]; // sets end point as MKMapItem
    // Get directions with MKDirections
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * response, NSError *error) {
        if (error) {
            // Handle the error
            NSLog(@"There was an error getting your directions");
        } else {
            // The code doesn't request alternate routes, so add the single calculated route to
            // a previously declared MKRoute property called drivingRoute.
            NSLog(@"Driving route received");
            //self.route = response.routes[0];
            self.route = [response.routes firstObject];
            [self.mapView addOverlay:self.route.polyline level:MKOverlayLevelAboveRoads];
        }
    }];
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
		}
	} else if ([marker isKindOfClass:[MKUserLocation class]]) {
        // If the marker is the user location marker, use the default view for user locations
        return nil;
    }
	return markerView;
}

# pragma mark - Delegate methods
// This function tells the MapView how to draw the route on the map
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    //renderer.strokeColor = [UIColor redColor];
    renderer.strokeColor = [[UIColor alloc] initWithRed:0.0 green:0.5664 blue:0.6602 alpha:1.0];
    renderer.lineWidth = 4.0;
    return  renderer;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // If user taps the OK or yes button, send them to Apple Maps with the directions
    if (buttonIndex == 0) {
    } else {
        NSString *directionsString = [[NSString alloc]
                                      initWithFormat:@"http://maps.apple.com/?daddr=%f,%f&saddr=%@", self.campsiteCoordinate.latitude, self.campsiteCoordinate.longitude, @"Current Location"];
        NSURL* directionsURL = [[NSURL alloc] initWithString:[directionsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:directionsURL];
    }
}


@end

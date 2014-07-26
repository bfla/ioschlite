//
//  CHLCampsiteViewController.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CHLCampsite.h"

@interface CHLCampsiteViewController : UIViewController <MKMapViewDelegate>

@property(nonatomic, copy) NSString *restorationIdentifier;

//@property (nonatomic, copy) NSDictionary *campsite;
@property (nonatomic, strong) CHLCampsite *campsite;
@property (nonatomic, copy) NSDictionary *campsiteJSON;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property BOOL fetchFailedError;

//@property (nonatomic) CHReserveOnlineViewController *rovc;
//@property (nonatomic) CHCampsiteMapViewController *cmvc;

-(IBAction)callCampground:(id)sender;
//-(IBAction)callToReserve:(id)sender;
-(IBAction)getDirections:(id)sender;
-(IBAction)visitWebsite:(id)sender;

@end

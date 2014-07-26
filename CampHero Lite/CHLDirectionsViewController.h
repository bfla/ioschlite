//
//  CHLDirectionsViewController.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CHLCampsite.h"

@interface CHLDirectionsViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView; // create property to hold the MapView
@property (nonatomic, strong) CHLCampsite *campsite; // store the campsite

//-(void)dismissDirections:(id)sender;
- (void)resetMapArea;

@end

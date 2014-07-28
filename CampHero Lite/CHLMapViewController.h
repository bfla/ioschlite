//
//  CHLMapViewController.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CHLMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView; // create property to hold the MapView
// Add property to hold campsites for the map markers etc***
@property (nonatomic, copy) NSMutableArray *campsites;
@property (nonatomic) BOOL showedRateMeAlert;

-(void)resetMarkers;

@end

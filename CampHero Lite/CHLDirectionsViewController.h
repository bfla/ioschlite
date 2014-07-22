//
//  CHLDirectionsViewController.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CHLDirectionsViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView; // create property to hold the MapView
@property (nonatomic, copy) NSDictionary *campsite; // store the campsite

//-(void)dismissDirections:(id)sender;
- (void)resetMapArea;

@end

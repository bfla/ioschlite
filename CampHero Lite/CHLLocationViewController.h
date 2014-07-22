//
//  CHLLocationViewController.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface CHLLocationViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, strong) NSString *keywords;
@property (nonatomic, strong) NSArray *campsites;
@property (nonatomic, retain) CLLocationManager *locationManager;

- (IBAction)tappedUseCurrentLocButton:(id)sender;

@end

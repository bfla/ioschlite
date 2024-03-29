//
//  CHLMapMarker.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CHLCampsite.h"

@interface CHLMapMarker : NSObject <MKAnnotation> // Adopt MKAnnotation protocol for map markers

@property (nonatomic) CLLocationCoordinate2D coordinate; // add coordinate property
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CHLCampsite *campsite;

@end

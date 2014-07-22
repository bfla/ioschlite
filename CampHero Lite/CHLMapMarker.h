//
//  CHLMapMarker.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CHLMapMarker : NSObject <MKAnnotation> // Adopt MKAnnotation protocol for map markers

@property (nonatomic) CLLocationCoordinate2D coordinate; // add coordinate property
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) NSDictionary *campsite;

@end

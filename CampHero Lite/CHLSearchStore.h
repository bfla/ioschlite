//
//  CHLSearchStore.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class CHLMapViewController;

@interface CHLSearchStore : NSObject <CLLocationManagerDelegate>

@property BOOL locationIsUser;
@property BOOL lastSearchWasTextSearch;
@property BOOL shouldResetMap;
@property (nonatomic, readonly) NSString *locationName;
@property BOOL noWifiError;
@property BOOL noPermissionError;
@property BOOL searchFailedError;

@property double defaultLatitude;
@property double defaultLongitude;
// Search parameters
@property (nonatomic, readonly) CLLocation *userLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, readonly) NSString *keywords;
@property (nonatomic, readonly) int tribeFilter;
// Search results
@property (nonatomic, readonly) NSArray *campsites;
@property (nonatomic, readonly) NSArray *filteredCampsites;

// Getters and setters accessible to external classes
+ (instancetype)sharedStore;
- (void)mapWasReset;
// Search functions available to external classes
//- (void)runTextSearch:(NSString *)input searchIsAroundUserLocation:(BOOL)isAroundUserLocation;
- (void)searchNearLatitude:(double)latitude longitude:(double)longitude keywords:(NSString *)input searchIsAroundUserLocation:(BOOL)isAroundUserBool;
- (void)mapAreaSearch:(CHLMapViewController *)mapView latitude:(double)latitude longitude:(double)longitude distance:(NSString *)distance;
- (void)searchNearUser;
- (void)saveActiveTribeFilter:(int)activeTribeId;
- (void)applyTribeFilter;

@end

//
//  CHLSearchStore.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import "CHLSearchStore.h"
#import "CHLUtilities.h"
#import "CHLCampsite.h"
#import <CoreLocation/CoreLocation.h>
#import "AFHTTPRequestOperationManager.h"
#import "CHLMapViewController.h"

@interface CHLSearchStore ()

// Make mutable properties private
//@property BOOL privateLocationIsUser;
@property (nonatomic, copy) NSString *privateKeywords;
@property (nonatomic, copy) NSString *privateLocationName;
@property (nonatomic) int privateTribeFilter;
@property (nonatomic, copy) NSMutableArray *privateCampsites;
@property (nonatomic, copy) NSMutableArray *privateFilteredCampsites;
@property (nonatomic, strong) CLLocation *privateUserLocation;
@property (nonatomic, strong) NSString *apiKey;

@end

@implementation CHLSearchStore

# pragma mark - Initializers, getters, & setters
// Class method for shared data ================================================================
// check if the single instance of BNRItemStore has been created
+ (instancetype)sharedStore
{
    static CHLSearchStore *sharedStore = nil;
    
    // If sharedStore doesn't exist, then make it
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

// Configure initializers =============================================================
// If the programmer calls regular old 'init' on BNRItemStore, let them know their mistake
#pragma init
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[CHLSearchStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

#pragma initPrivate
// Here is the real (secret) initializer
- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        //_privateLocationIsUser = NO;
        _locationIsUser = NO;
        _noWifiError = NO;
        _noPermissionError = NO;
        _searchFailedError = NO;
        _privateKeywords = @"";
        _privateLocationName = @"";
        _privateTribeFilter = 0;
        _privateCampsites = [[NSMutableArray alloc] init];
        _privateFilteredCampsites = [[NSMutableArray alloc] init];
        _privateUserLocation = [[CLLocation alloc] init];
        _apiKey = @"1af20713-4a94-4c86-b1f4-219fb22e7b1a";
        _defaultLatitude = [@42.3314 doubleValue];
        _defaultLongitude = [@-83.0458 doubleValue];
    }
    return self;
}

// Getters ==================================================================================

/*- (BOOL)locationIsUser
 {
 return self.privateLocationIsUser;
 }*/

- (NSString *)keywords
{
    return self.privateKeywords;
}

- (NSString *)locationName
{
    return self.privateLocationName;
}

- (NSArray *)campsites
{
    return self.privateCampsites;
}

- (NSArray *)filteredCampsites
{
    return self.privateFilteredCampsites;
}

- (int)tribeFilter
{
    return self.privateTribeFilter;
}

- (CLLocation *)userLocation
{
    return self.privateUserLocation;
}

- (void)mapWasReset
{
    self.shouldResetMap = NO;
}

#pragma mark - runTextSearch
// Run a campsite search on Camposaurus's web API using text keywords ============================
- (void)searchNearLatitude:(double)latitude longitude:(double)longitude keywords:(NSString *)input searchIsAroundUserLocation:(BOOL)isAroundUserBool
{
    
    NSString *searchUrl = @"http://lite.getcamphero.com/api/v1/searches"; // Store URL
    self.searchFailedError = NO;
    
    self.privateKeywords = input; // Store input from the user
    // Store the query's parameters so AFNetworking can serialize them
    NSString *latitudeStr = [NSString stringWithFormat:@"%f", latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%f", longitude];
    NSDictionary *searchParams = @{@"utf8":@"√", @"latitude": latitudeStr, @"longitude":longitudeStr, @"api_key":self.apiKey};
    //NSDictionary *searchParams = @{@"utf8":@"√", @"keywords": self.privateKeywords, @"api_key": self.apiKey};
    
    if (isAroundUserBool) {
        self.privateLocationName = @"You"; // Name the current location "You"
    } else {
        self.privateLocationName = input; // Save a name for the current location
    }
    
    // Make the request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:searchUrl parameters:searchParams success:^(AFHTTPRequestOperation *operation, id responseJSON) {
        NSLog(@"JSON: %@", responseJSON);
        NSMutableArray *resultsAsCampsiteObjects = [[NSMutableArray alloc] init];
        for (NSDictionary *d in responseJSON) {
            [resultsAsCampsiteObjects addObject:[[CHLCampsite alloc] initWithJSON:d] ];
        }
        self.privateCampsites = resultsAsCampsiteObjects;

        [self applyTribeFilter];
        
        if (isAroundUserBool) {
            // Let app views know what type of search this was
            self.locationIsUser = YES;
            self.lastSearchWasTextSearch = NO;
        } else {
            // Let app views know what type of search this was
            self.locationIsUser = NO; // Let VCs know that the search is not around the user
            self.lastSearchWasTextSearch = YES;
        }
        self.shouldResetMap = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.searchFailedError = YES;
        if ([[CHLUtilities sharedUtilities] hasWebConnection]) {
            UIAlertView *fetchFailedAlert = [[UIAlertView alloc] initWithTitle:@"Request thwarted!" message:@"I was unable to complete your request. Maybe your Wifi is malfunctioning or my servers were exposed to some Camptonite.  If this problem persists, please contact my trusty sidekick: brian@getcamphero.com." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [fetchFailedAlert show];
            NSLog(@"Error: %@", error);
        } /*else {
            UIAlertView *noWifiAlert = [[UIAlertView alloc] initWithTitle:@"Holy interwebs!" message:@"CampHero's superpowers flow from the internet. It appears you don't have an internet connection so CampHero is powerless right now." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [noWifiAlert show];
        }*/
    }];
    
}

#pragma mark - mapAreaSearch
// Run a campsite search of the current map view =================================================
- (void)mapAreaSearch:(CHLMapViewController *)mapView latitude:(double)latitude longitude:(double)longitude distance:(NSString *)distance;
{
    
    NSString *searchUrl = @"http://lite.getcamphero.com/api/v1/searches"; // Store URL
    self.searchFailedError = NO;
    
    self.privateKeywords = [NSString stringWithFormat:@"%f, %f", latitude, longitude]; // Store input from the user
    self.privateLocationName = self.privateKeywords; // Save a name for the current location
    // Store the query's parameters so AFNetworking can serialize them
    NSString *latitudeStr = [NSString stringWithFormat:@"%f", latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%f", longitude];
    NSDictionary *searchParams = @{@"utf8":@"√", @"latitude": latitudeStr, @"longitude":longitudeStr, @"distance":distance, @"api_key":self.apiKey};
    
    // Make the request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:searchUrl parameters:searchParams success:^(AFHTTPRequestOperation *operation, id responseJSON) {
        NSLog(@"JSON: %@", responseJSON);
        NSMutableArray *resultsAsCampsiteObjects = [[NSMutableArray alloc] init];
        for (NSDictionary *d in responseJSON) {
            [resultsAsCampsiteObjects addObject:[[CHLCampsite alloc] initWithJSON:d] ];
        }
        self.privateCampsites = resultsAsCampsiteObjects;

        //[self applyTribeFilter:self.privateTribeFilter];
        self.locationIsUser = NO; // Let the app know that the current search is not around the user
        self.lastSearchWasTextSearch = NO;
        self.shouldResetMap = NO;
        [self applyTribeFilter];
        
        [mapView resetMarkers];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.searchFailedError = YES;
        NSLog(@"Error in mapAreaSearch: %@", error);
    }];
    
}

#pragma mark - Search Near User
// Search for campsites near the user ===========================================================
- (void)searchNearUser
{
    // Create the manager object
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    // Hand the query off to the delegate method startUpdatingLocation (defined below)
    [self.locationManager startUpdatingLocation];
    // If user refused to allow use of their current location, then set a default location
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || ![CLLocationManager locationServicesEnabled] ) {
        [[CHLSearchStore sharedStore] searchNearLatitude:self.defaultLatitude longitude:self.defaultLongitude keywords:@"Detroit MI" searchIsAroundUserLocation:NO];
        //[[CHLSearchStore sharedStore] runTextSearch:defaultLocation searchIsAroundUserLocation:NO];
    }
}

// When a new user location is received use it to run a campsite search
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.privateUserLocation = [locations lastObject];
    if ([self.privateUserLocation isKindOfClass:[NSNull class]]) {
        // If location is unknown, use a default location
        [[CHLSearchStore sharedStore] searchNearLatitude:self.defaultLatitude longitude:self.defaultLongitude keywords:@"Detroit MI" searchIsAroundUserLocation:NO];
    } else {
        // Stop streaming the user's location
        [self.locationManager stopUpdatingLocation];
        //self.locationManager.delegate = nil;
    
        // Run a text search using the retrieved user location
        //NSString *input = [NSString stringWithFormat:@"%f, %f", self.privateUserLocation.coordinate.latitude, self.privateUserLocation.coordinate.longitude];
        [[CHLSearchStore sharedStore] searchNearLatitude:self.privateUserLocation.coordinate.latitude longitude:self.privateUserLocation.coordinate.longitude keywords:@"You" searchIsAroundUserLocation:YES];
        //[[CHLSearchStore sharedStore] runTextSearch:input searchIsAroundUserLocation:YES ];
    }
    
    
}

#pragma mark - Filtering functions
-(void)saveActiveTribeFilter:(int)activeTribeId
{
    self.privateTribeFilter = activeTribeId;
    //UIAlertView *filterAlert = [[UIAlertView alloc] initWithTitle:@"Bam!" message:@"You've applied a super filter!  Next time you run a search, I will show you only campsites that match this filter." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[filterAlert show];
    
}

// This function applies tribe filters =============================================================
- (void)applyTribeFilter
{
    [self.privateFilteredCampsites removeAllObjects];
    
    if (self.privateCampsites.count > 0) { // If campsites were found, then it is okay to apply filters
        
        if (self.privateTribeFilter == 0) {
            // If tribeId is 0, then the filter is 'all' so include all campsites
            [self.privateFilteredCampsites addObjectsFromArray:self.campsites];
        } else {
            // if tribeId > 0, then filter out irrelevant campsites by tribe
            for (CHLCampsite *campsite in self.privateCampsites) {
                if (self.privateTribeFilter == 1 && campsite.rustic) {
                    [self.privateFilteredCampsites addObject:campsite];
                } else if (self.privateTribeFilter == 2 && campsite.rv) {
                    [self.privateFilteredCampsites addObject:campsite];
                } else if (self.privateTribeFilter == 3 && campsite.backcountry) {
                    [self.privateFilteredCampsites addObject:campsite];
                }
            }
        }
    }
    self.shouldResetMap = YES;
}

@end
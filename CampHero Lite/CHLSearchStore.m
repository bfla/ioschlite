//
//  CHLSearchStore.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import "CHLSearchStore.h"

@implementation CHLSearchStore

#import "CHLSearchStore.h"
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
- (void)runTextSearch:(NSString *)input searchIsAroundUserLocation:(BOOL)isAroundUserBool
{
    
    NSString *searchUrl = @"http://gentle-ocean-6036.herokuapp.com/campsites/search.json"; // Store URL
    
    self.privateKeywords = input; // Store input from the user
    // Store the query's parameters so AFNetworking can serialize them
    NSDictionary *searchParams = @{@"utf8":@"√", @"keywords": self.privateKeywords};
    
    if (isAroundUserBool) {
        self.privateLocationName = @"You"; // Name the current location "You"
    } else {
        self.privateLocationName = input; // Save a name for the current location
    }
    
    // Make the request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:searchUrl parameters:searchParams success:^(AFHTTPRequestOperation *operation, id responseJSON) {
        NSLog(@"JSON: %@", responseJSON);
        self.privateCampsites = responseJSON;
#pragma mark - warning must fix filter
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
        UIAlertView *fetchFailedAlert = [[UIAlertView alloc] initWithTitle:@"Dastardly bugs!" message:@"Bummer.  I was unable to fetch this campsite for you. Maybe you lost your internet connection or maybe my servers were exposed to some Camptonite.  If this problem persists, please contact my trusted sidekick: brian@getcamphero.com." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [fetchFailedAlert show];
        NSLog(@"Error: %@", error);
    }];
    
}

#pragma mark - mapAreaSearch
// Run a campsite search of the current map view =================================================
- (void)mapAreaSearch:(CHMapViewController *)mapView keywords:(NSString *)input distance:(NSString *)distance;
{
    
    NSString *searchUrl = @"http://gentle-ocean-6036.herokuapp.com/campsites/search.json"; // Store URL
    
    self.privateKeywords = input; // Store input from the user
    self.privateLocationName = input; // Save a name for the current location
    // Store the query's parameters so AFNetworking can serialize them
    NSDictionary *searchParams = @{@"utf8":@"√", @"keywords": self.privateKeywords, @"distance":distance};
    
    // Make the request
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:searchUrl parameters:searchParams success:^(AFHTTPRequestOperation *operation, id responseJSON) {
        NSLog(@"JSON: %@", responseJSON);
        
        self.privateCampsites = responseJSON;
#pragma mark - warning must fix filter
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
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || ![CLLocationManager locationServicesEnabled]) {
        NSString *defaultLocation = @"44.77794, -85.93906";
        [[CHLSearchStore sharedStore] runTextSearch:defaultLocation searchIsAroundUserLocation:NO];
    }
}

// When a new user location is received use it to run a campsite search
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Save the user's location and run a search using the Camposaurus web API
    self.privateUserLocation = [locations lastObject];
    
    // Stop streaming the user's location
    [self.locationManager stopUpdatingLocation];
    //self.locationManager.delegate = nil;
    
    // Run a text search using the retrieved user location
    NSString *input = [NSString stringWithFormat:@"%f, %f", self.privateUserLocation.coordinate.latitude, self.privateUserLocation.coordinate.longitude];
    [[CHLSearchStore sharedStore] runTextSearch:input searchIsAroundUserLocation:YES ];
    
    
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
    
    if (self.privateCampsites.count > 0) {
        // If campsites were found, then it is okay to apply filters
        if (self.privateTribeFilter == 0) {
            // If tribeId is 0, then the filter is 'all' so include all campsites
            [self.privateFilteredCampsites addObjectsFromArray:self.campsites];
        } else {
            // if tribeId > 0, then filter out irrelevant campsites by tribe
            for (NSDictionary *campsite in self.privateCampsites) {
                // For the time being, only use the primary tribe when filtering
                //NSLog(@"Campsite tribe is of type... %@", NSStringFromClass([campsite[@"properties"][@"tribes"][0] class]));
                if (![campsite[@"properties"][@"tribes"][0] isKindOfClass:[NSNull class]]) {
                    NSNumber *campsiteTribe = campsite[@"properties"][@"tribes"][0]; // Should return an NSNumber
                    if ([campsiteTribe isEqual:[NSNumber numberWithInt:self.tribeFilter]]) {
                        [self.privateFilteredCampsites addObject:campsite];
                    }
                }
                //NSArray *campsiteTribes = campsite[@"properties"][@"tribes"];
                /*for (int i=0; i < campsiteTribes.count; i++) {
                 if ([campsiteTribes[i] integerValue] == tribeId) {
                 [self.privateFilteredCampsites addObject:campsite];
                 }
                 }*/
            }
        }
    }
    self.shouldResetMap = YES;
}

#pragma mark - Formatters
- (NSMutableString *)formatPhoneNumber:(NSString *)phoneNumber
{
    NSMutableString *phoneS = [NSMutableString stringWithString:phoneNumber];
    if (phoneS.length == 10) {
        [phoneS insertString:@"-" atIndex:3];
        [phoneS insertString:@"-" atIndex:7];
        return phoneS;
    } else if (phoneS.length == 11) {
        [phoneS insertString:@"-" atIndex:1];
        [phoneS insertString:@"-" atIndex:5];
        [phoneS insertString:@"-" atIndex:9];
        return phoneS;
    } else {
        // Do nothing
        return phoneS;
    }
}

@end



@end

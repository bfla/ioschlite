//
//  CHLUtilities.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import "CHLUtilities.h"
#import "AFNetworkReachabilityManager.h"

@implementation CHLUtilities

+ (instancetype)sharedUtilities // This method instantiates the class so its methods can be used
{
    static CHLUtilities *sharedUtilities = nil;
    
    // If sharedStore doesn't exist, then make it
    if (!sharedUtilities) {
        sharedUtilities = [[self alloc] initPrivate];
    }
    
    return sharedUtilities;
}

- (instancetype)initPrivate
{
    self = [super init];
    if (self) {
        // Add properties here like "_myProperty"
    }
    return self;
}


// Monitors web connection and creates proper notifications
-(void)monitorWebConnection {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager]
     setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
         // Do something
         //BOOL showConnectedMessage = NO;
         switch (status) {
             case AFNetworkReachabilityStatusNotReachable:
                 NSLog(@"Wifi disconnected...");
                 // Display proper notification
                 [ [[UIAlertView alloc] initWithTitle:@"Holy interwebs!" message:@"CampHero's superpowers are fueled by the web.  CampHero detects that you have lost your internet connection so it is powerless to help you." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                 //showConnectedMessage = YES;
                 break;
             case AFNetworkReachabilityStatusReachableViaWiFi:
                 NSLog(@"WIFI reconnected...");
                 /*if (showConnectedMessage == YES) {
                  [ [[UIAlertView alloc] initWithTitle:@"Holy interwebs!" message:@"CampHero is now connected to the internet!  CampHero's superpowers are charged and at your disposal." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                  showConnectedMessage = NO;
                  }*/
                 break;
             case AFNetworkReachabilityStatusReachableViaWWAN:
                 //NSLog(@"3G");
                 /*if (showConnectedMessage == YES) {
                  [ [[UIAlertView alloc] initWithTitle:@"Holy interwebs!" message:@"CampHero is now connected to the internet!  CampHero's superpowers are charged and at your disposal." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                  //showConnectedMessage = NO;
                  }*/
                 // Do nothing. No notification necessary.
                 break;
             default:
                 //NSLog(@"Unkown network status");
                 // Display proper notification
                 [ [[UIAlertView alloc] initWithTitle:@"Holy interwebs!" message:@"CampHero's superpowers are fueled by the web.  I detect that you might not have an internet connection and if that is true, then I am powerless to help you. Sorry, friend." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                 //showConnectedMessage = YES;
                 break;
         }
     }];
}

-(void)stopMonitoringWebConnection {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

// Checks current web connection
-(BOOL)verifyWebConnection
{
    BOOL connectionBool = [AFNetworkReachabilityManager sharedManager].reachable;
    if (connectionBool == NO) {
        UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:@"Holy interwebs!" message:@"CampHero's superpowers are fueled by the web.  It appears your device has no internet connection, so CampHero is powerless." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [connectionAlert show];
    }
    return connectionBool;
}

// Checks current web connection
-(BOOL)hasWebConnection
{
    BOOL connectionBool = [AFNetworkReachabilityManager sharedManager].reachable;
    return connectionBool;
}

@end


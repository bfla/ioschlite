//
//  CHLUtilities.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHLUtilities : NSObject

-(void)monitorWebConnection;
-(void)stopMonitoringWebConnection;
-(BOOL)verifyWebConnection;
-(BOOL)hasWebConnection;
-(void)showNoWifiAlert;

+ (instancetype)sharedUtilities;

@end

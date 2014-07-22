//
//  CHLCampsite.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHLCampsite : NSObject

@property int api_id;
@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *state;
@property (nonatomic, copy)NSString *owner;

@property double latitude;
@property double longitude;
@property int elevation;
@property int phone;

@property BOOL electricSites;
@property BOOL outhouse;
@property BOOL showers;
@property BOOL dump;
@property BOOL water;
@property BOOL boatin;
@property BOOL hikein;

@property BOOL rustic;
@property BOOL rv;
@property BOOL backcountry;
@property BOOL horse;

- initWithJSON:(NSDictionary *)JSON;

@end

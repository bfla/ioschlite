//
//  CHLCampsite.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHLCampsite : NSObject

@property int api_id;
@property int elevation;

@property (nonatomic, copy)NSString *name;
@property (nonatomic, copy)NSString *state;
@property (nonatomic, copy)NSString *owner;
@property (nonatomic, copy)NSString *phone;
@property (nonatomic, copy)NSString *url;
@property (nonatomic, copy)NSString *warning;

@property double latitude;
@property double longitude;

@property BOOL electric;
@property BOOL outhouse;
@property BOOL likely_toilets;
@property BOOL no_toilets;
@property BOOL showers;
@property BOOL dump;
@property BOOL water;
@property BOOL boatin;
@property BOOL hikein;

@property BOOL rustic;
@property BOOL rv;
@property BOOL backcountry;
@property BOOL horse;

@property (nonatomic, copy)NSString *vibeString;
@property (nonatomic, copy)NSString *imageName;

-(instancetype)initWithJSON:(NSDictionary *)JSON;

-(NSString *)showerImageName;
-(NSString *)outhouseImageName;
-(NSString *)electricImageName;
-(NSString *)dumpImageName;
-(NSString *)waterImageName;

- (NSString *)formattedPhoneNumber;

@end

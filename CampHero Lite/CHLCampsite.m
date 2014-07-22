//
//  CHLCampsite.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import "CHLCampsite.h"

@implementation CHLCampsite

- (instancetype)initWithJSON:(NSDictionary *)JSON {
    
    //self.api_id = [JSON[@"id"]];
    self.name = JSON[@"name"];
    self.state = JSON[@"state"];
    
    return self;
    
    //self.rustic = JSON[@"rustic"];
    //self.rv = JSON[@"rv"];
    //self.backcountry = JSON[@"backcountry"];
    //self.horse = JSON[@"horse"];
    
    //if ([[JSON[@"owner"] isKindOfClass:[NSString class]]) {
        //self.owner = JSON[@"owner"];
    //}

    //self.latitude = JSON[@"latitude"];
    //self.longitude = JSON[@"longitude"];
         
    // The rest of these are optional so we must verify their presence first
         
    //if ([JSON[@"owner"] isKindOfClass:[NSString class]]) {
        //self.owner = JSON[@"owner"];
    //}
}
         
    //if ([JSON[@"elevation"] isKindOfClass:[int]]) {
             
    //}
         
    //if ([JSON[@"phone"] isKindOfClass:[int ]]) {
             
   //}
         
    //@property BOOL electricSites;
    //@property BOOL outhouse;
    //@property BOOL showers;
    //@property BOOL dump;
    //@property BOOL water;
    //@property BOOL boatin;
    //@property BOOL hikein;


@end

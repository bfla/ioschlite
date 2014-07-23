//
//  CHLCampsite.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import "CHLCampsite.h"

@implementation CHLCampsite

# pragma mark - Initializers

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Requires JSON"
                                   reason:@"Use +[CHLCampsite initWithJSON]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initWithJSON:(NSDictionary *)JSON {
    
    self.api_id = [JSON[@"id"] intValue];
    self.name = JSON[@"name"];
    self.state = JSON[@"state"];
    self.owner = JSON[@"owner"];

    // Save phone as a string only if it exists
    if (![JSON[@"phone"] isKindOfClass:[NSNull class]]) {
        self.phone = [NSString stringWithFormat:@"%d", [ JSON[@"phone"] intValue]];
    }
    
    // Save lat and lng as doubles
    self.latitude = [JSON[@"latitude"] doubleValue];
    self.longitude = [JSON[@"longitude"] doubleValue];
    
    // Save elevation as a integer only if it exists
    if (![JSON[@"elevation"] isKindOfClass:[NSNull class]]) {
        self.elevation = [ JSON[@"elevation"] intValue];
    }
    
    // Set vibes to NO by default and YES only if they exist and are true
    self.rustic = NO;
    if (![JSON[@"rustic"] isKindOfClass:[NSNull class] ]) {
        self.rustic = [JSON[@"rustic"] boolValue];
    }
    self.rv = NO;
    if (![JSON[@"rv"] isKindOfClass:[NSNull class] ]) {
        self.rustic = [JSON[@"rv"] boolValue];
    }
    self.backcountry = NO;
    if (![JSON[@"backcountry"] isKindOfClass:[NSNull class] ]) {
        self.backcountry = [JSON[@"backcountry"] boolValue];
    }
    self.horse = NO;
    if (![JSON[@"horse"] isKindOfClass:[NSNull class] ]) {
        self.backcountry = [JSON[@"horse"] boolValue];
    }
    
    // Set appropriate vibe name and image based on tribe info
    if (self.horse) {
        self.vibeString = @"Horse friendly";
        self.imageName = @"Horse";
    } else if (self.backcountry) {
        self.vibeString = @"Backcountry";
        self.imageName = @"Backcountry";
    } else if (self.rv) {
        self.vibeString = @"RV friendly";
        self.imageName = @"RV friendly";
    } else if (self.rustic) {
        self.vibeString = @"Rustic";
        self.imageName = @"Rustic";
    } else {
        self.vibeString = @"Vibe is unknown";
        self.imageName = @"All";
    }
    
    //NSLog(@"Showers is set to type %@", NSStringFromClass([JSON[@"showers"] class]));
    //NSLog(@"Outhouse is set to type %@", NSStringFromClass([JSON[@"outhouse"] class]));
    // Set amenities to true only if they exist and are true
    self.showers = NO;
    if (![JSON[@"showers"] isKindOfClass:[NSNull class] ]) {
        self.showers = [JSON[@"showers"] boolValue];
    }
    self.dump = NO;
    if (![JSON[@"dump"] isKindOfClass:[NSNull class] ]) {
        self.dump = [JSON[@"dump"] boolValue];
    }
    self.water = NO;
    if (![JSON[@"water"] isKindOfClass:[NSNull class] ]) {
        self.water = [JSON[@"water"] boolValue];
    }
    self.electric = NO;
    # warning must add proper electricity info once Rails API is updated
    
    return self;
}

#pragma mark - Facility images
-(NSString *)showerImageName {
    if (self.showers) {
        return @"Showers";
    } else {
        return @"NoShowers";
    }
}
-(NSString *)outhouseImageName {
    if (self.outhouse) {
        return @"Outhouse";
    } else {
        return @"NoOuthouse";
    }
}

-(NSString *)electricImageName {
    if (self.electric) {
        return @"Electric";
    } else {
        return @"NoElectric";
    }
    
}
-(NSString *)dumpImageName {
    if (self.dump) {
        return @"Dump";
    } else {
        return @"NoDump";
    }
    
}

-(NSString *)waterImageName {
    if (self.water) {
        return @"Water";
    } else {
        return @"NoWater";
    }
    
}


@end

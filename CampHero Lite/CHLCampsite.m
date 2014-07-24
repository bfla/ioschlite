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
    // API should return NSStrings for these and they are all required fields
    // So these ones are easy...
    self.api_id = [JSON[@"id"] intValue];
    self.name = JSON[@"name"];
    self.state = JSON[@"state"];
    self.owner = JSON[@"owner"];
    
    // Save lat and lng as doubles
    // API should return an NSNumber
    self.latitude = [JSON[@"latitude"] doubleValue];
    self.longitude = [JSON[@"longitude"] doubleValue];

    // Save phone as a string only if it exists
    // API should return an NSNumber only if the field is filled
    if (![JSON[@"phone"] isKindOfClass:[NSNull class]]) {
        self.phone = [NSString stringWithString:[JSON[@"phone"] stringValue] ];
    }
    
    // Save url as string only if it exists
    // API should return an NSNumber only if the field is filled
    if (![JSON[@"url"] isKindOfClass:[NSNull class]] && [JSON[@"url"] isKindOfClass:[NSString class]]) {
        self.url = [NSString stringWithString:JSON[@"url"] ];
    }
    
    // Save elevation as a integer only if it exists
    if (![JSON[@"elevation"] isKindOfClass:[NSNull class]]) {
        self.elevation = [ JSON[@"elevation"] intValue];
    }
    
    // Set vibes to NO by default and YES only if they exist and are true
    self.rustic = NO;
    if (![JSON[@"rustic"] isKindOfClass:[NSNull class] ] && [JSON[@"rustic"] isEqual:@1]) {
        //self.rustic = [JSON[@"rustic"] boolValue];
        self.rustic = YES;
    }
    self.rv = NO;
    if (![JSON[@"rv"] isKindOfClass:[NSNull class]] && [JSON[@"rv"] isEqual:@1]) {
        self.rv = YES;
    }
    self.backcountry = NO;
    if (![JSON[@"backcountry"] isKindOfClass:[NSNull class]] && [JSON[@"backcountry"] isEqual:@1]) {
        //self.backcountry = [JSON[@"backcountry"] boolValue];
        self.backcountry = YES;
    }
    self.horse = NO;
    if (![JSON[@"horse"] isKindOfClass:[NSNull class]] && [JSON[@"horse"] isEqual:@1]) {
        //self.horse = [JSON[@"horse"] boolValue];
        self.horse = YES;
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
        self.imageName = @"RV";
    } else if (self.rustic) {
        self.vibeString = @"Rustic";
        self.imageName = @"Rustic";
    } else {
        self.vibeString = @"Unknown type";
        self.imageName = @"All";
    }
    
    self.likely_toilets = NO;
    if (![JSON[@"likely_toilets"] isKindOfClass:[NSNull class] ]) {
        self.likely_toilets = [JSON[@"likely_toilets"] boolValue];
    }
    self.no_toilets = NO;
    if (![JSON[@"no_toilets"] isKindOfClass:[NSNull class] ]) {
        self.no_toilets = [JSON[@"no_toilets"] boolValue];
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
    if (self.no_toilets) {
        return @"NoOuthouse";
    } else if (self.likely_toilets) {
        return @"Outhouse";
    } else {
        return @"MaybeOuthouse";
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

#pragma mark - Formatters
- (NSString *)formattedPhoneNumber {
    if (self.phone) {
        NSMutableString *phoneS = [NSMutableString stringWithString:self.phone];
        NSLog(@"formatted phone number: %@ & formatted version %@", self.phone, phoneS);
        if (phoneS.length == 10) {
            [phoneS insertString:@"-" atIndex:3];
            [phoneS insertString:@"-" atIndex:7];
            NSString *fp = [NSString stringWithString:phoneS];
            return fp;
        } else if (phoneS.length == 11) {
            [phoneS insertString:@"-" atIndex:1];
            [phoneS insertString:@"-" atIndex:5];
            [phoneS insertString:@"-" atIndex:9];
            NSString *fp = [NSString stringWithString:phoneS];
            return fp;
        } else {
            return self.phone;
        }
    } else {
        NSString *fp = @"No phone";
        return fp;
    }
}


@end

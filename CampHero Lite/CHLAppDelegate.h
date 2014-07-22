//
//  CHLAppDelegate.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, copy) NSArray *campsites;
@property (nonatomic, copy) NSString *current_loc;
@property(nonatomic, copy) NSString *restorationIdentifier;

@end

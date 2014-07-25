//
//  CHLAppDelegate.m
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import "CHLAppDelegate.h"
#import "CHLSearchStore.h"

#import "CHLFilterViewControllerTableViewController.h"
#import "CHLMapViewController.h"
#import "CHLResultsTableViewController.h"
#import "CHLUtilities.h"

NSString * const CHLShouldShowRateMePrefsKey = @"ShouldShowRateMe";

@implementation CHLAppDelegate

+ (void)initialize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *factorySettings = @{CHLShouldShowRateMePrefsKey:@0};
    [defaults registerDefaults:factorySettings];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"Launched successfully...");
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    // Ask user permission to use current location & attempt it
    [[CHLSearchStore sharedStore] searchNearUser];
    
    // Tab item views
    // Filters screen
    CHLFilterViewControllerTableViewController *filtersVC = [[CHLFilterViewControllerTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *filtersNVC = [[UINavigationController alloc] initWithRootViewController:filtersVC];
    filtersNVC.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:1];
    filtersNVC.tabBarItem.title = @"Controls";
    filtersNVC.navigationBar.tintColor = [[UIColor alloc] initWithRed:1.0 green:0.45 blue:0.0 alpha:1.0];
    
    // Map screen
    CHLMapViewController *mapVC = [[CHLMapViewController alloc] init];
    mapVC.campsites = [[NSMutableArray alloc] initWithArray:self.campsites];
    mapVC.showedRateMeAlert = NO;
    UINavigationController *mapNVC = [[UINavigationController alloc] initWithRootViewController:mapVC];
    mapNVC.tabBarItem.title = @"Map";
    mapNVC.tabBarItem.image = [UIImage imageNamed:@"mapTab"];
    mapNVC.navigationBar.tintColor = [[UIColor alloc] initWithRed:1.0 green:0.45 blue:0.0 alpha:1.0];
    
    // Results screen
    CHLResultsTableViewController *resultsVC = [[CHLResultsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    resultsVC.campsites = [[NSMutableArray alloc] initWithArray:self.campsites];
    UINavigationController *resultsNVC = [[UINavigationController alloc] initWithRootViewController:resultsVC];
    resultsNVC.tabBarItem.title = @"Results";
    resultsNVC.tabBarItem.image = [UIImage imageNamed:@"resultsTab"];
    resultsNVC.navigationBar.tintColor = [[UIColor alloc] initWithRed:1.0 green:0.45 blue:0.0 alpha:1.0];
    
    // Now add the tab items to a tab bar
    UITabBarController *tabBarVC = [[UITabBarController alloc] init];
    tabBarVC.tabBar.tintColor = [[UIColor alloc] initWithRed:1.0 green:0.45 blue:0.0 alpha:1.0];
    tabBarVC.viewControllers = @[filtersNVC, mapNVC, resultsNVC];
    
    // Set the root VC
    self.window.rootViewController = tabBarVC;
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[CHLUtilities sharedUtilities] stopMonitoringWebConnection];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[CHLUtilities sharedUtilities] monitorWebConnection];
    //[[CHLUtilities sharedUtilities] verifyWebConnection];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
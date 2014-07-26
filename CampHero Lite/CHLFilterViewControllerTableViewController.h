//
//  CHLFilterViewControllerTableViewController.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 CampHero LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHLFilterViewControllerTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, copy) NSString *locationName;

@end

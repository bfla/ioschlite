//
//  CHLResultsTableViewController.h
//  CampHero Lite
//
//  Created by Brian Flaherty on 7/22/14.
//  Copyright (c) 2014 Restless LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHLCampsiteViewController.h"

@interface CHLResultsTableViewController : UITableViewController

@property (nonatomic, copy) NSMutableArray *campsites;
@property(nonatomic, copy) NSString *restorationIdentifier;
@property(nonatomic) CHLCampsiteViewController *cvc;

@end

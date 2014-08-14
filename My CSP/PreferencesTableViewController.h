//
//  PreferencesTableViewController.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/31/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToggleTableViewCell.h"
#import "ButtonTableViewCell.h"
#import "ListingTableNavigationController.h"
#import "ListingFilter.h"

@interface PreferencesTableViewController : UITableViewController <
    UIAlertViewDelegate
>

-(IBAction)clearSearch:(id)sender;
-(IBAction)clearFavorites:(id)sender;
-(IBAction)toggleBeacons:(id)sender;
-(IBAction)close:(id)sender;
@end

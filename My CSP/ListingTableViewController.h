//
//  ListingTableViewController.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/8/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListingTableNavigationController.h"
#import "ListingTableViewCell.h"
#import "ListingDetailViewController.h"

@interface ListingTableViewController : UITableViewController

// Initial array of Listing objects
@property (strong, nonatomic) NSArray *listings;

// Array of listings which passed through the filter and will be displayed
@property (strong, nonatomic) NSArray *filteredListings;

// Filter passed form the previous view, either the main menu or the searchPreferences view
@property (strong, nonatomic) ListingFilter *filter;


// closes the containing navigation controller
- (IBAction)pressMenu:(id)sender;

@end

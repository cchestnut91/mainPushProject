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

@property (strong, nonatomic) NSArray *listings;
@property (strong, nonatomic) Listing *selected;
@property (strong, nonatomic) NSArray *filteredListings;
@property (strong, nonatomic) ListingFilter *filter;

-(void)filterListings;
-(void)closeParent;
- (IBAction)pressMenu:(id)sender;

@end

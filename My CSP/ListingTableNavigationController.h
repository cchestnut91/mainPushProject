//
//  ListingTableNavigationController.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/8/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListingFilter.h"
#import "ListingDetailViewController.h"
#import "ViewController.h"

// Navigation controllers hold and pass values between modal views and their presenting views
// Rename this class to CSPNavigationController when Xcode gets the stick out of it's ass
@interface ListingTableNavigationController : UINavigationController


// Array holding all listings before filtering
@property (strong, nonatomic) NSArray *listings;

// The current filter being used
@property (strong, nonatomic) ListingFilter *filter;

// Used to determine where the modal view was presented from
@property (strong, nonatomic) NSString *source;

@end

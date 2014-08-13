//
//  ViewController.h
//  My CSP
//
//  Created by Calvin Chestnut on 6/10/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MainMenuTableViewCell.h"
#import "ListingPull.h"
#import "ListingTableNavigationController.h"
#import "ListingDetailViewController.h"
#import "AppDelegate.h"

// Delegates for TableView, SearchBar, AlertView, and LocationManager
// DataSource for TableView
@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

// Outlets for UI Elements
@property (weak, nonatomic) IBOutlet UILabel *cspLabel;
@property (weak, nonatomic) IBOutlet UILabel *managmentLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

// Default location manager
@property (strong, nonatomic) CLLocationManager *manager;

// User's current location
@property (strong, nonatomic) CLLocation *location;

// Array of all listings before filter
@property (strong, nonatomic) NSArray *listings;

// Filter to be passed to SearchPreferences view or SearchResults view
@property (strong, nonatomic) ListingFilter *filter;

// String to pass data about what triggered a search
@property (strong, nonatomic) NSString *source;

// Array of images to fade through in the background imageView
@property (strong, nonatomic) NSMutableArray *backgroundArray;

// Returns true if User has elected to allow location services
-(BOOL)locationEnabled;

// Receives notification and creates necessary ViewControllers to display Listings
-(void)openURLListings:(NSNotification *)notification;

// Gets the favorites from local saved data
-(void)forceRemoveFavorites:(NSNotification *)notification;

// Goes through each listing and makes sure it has the correct "favorite" value after the favorites have been updated
-(void)checkFavorites:(NSArray *)favorites;

// Fades to the next image in the backgroundArray
-(void)fadeImage:(NSTimer *)sender;


@end
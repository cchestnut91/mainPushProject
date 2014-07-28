//
//  ViewController.h
//  My CSP
//
//  Created by Calvin Chestnut on 6/10/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainMenuTableViewCell.h"
#import "ListingPull.h"
#import "ListingTableNavigationController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIAlertViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *cspLabel;
@property (weak, nonatomic) IBOutlet UILabel *managmentLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSArray *listings;
@property (strong, nonatomic) NSMutableArray *backgroundArray;
@property (strong, nonatomic) ListingFilter *filter;
@property (strong, nonatomic) ListingFilter *emptyFilter;
@property (strong, nonatomic) NSString *source;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property int pos;

-(BOOL)locationEnabled;

@end
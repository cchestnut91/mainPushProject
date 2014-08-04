//
//  FilterSettingsTableViewController.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/11/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListingTableViewController.h"

@interface FilterSettingsTableViewController : UITableViewController 

@property (strong, nonatomic) ListingFilter *filter;
@property (weak, nonatomic) IBOutlet UITextField *minRentField;
@property (weak, nonatomic) IBOutlet UITextField *maxRentField;
@property (weak, nonatomic) IBOutlet UISwitch *favoriteSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *nearSwitch;
@property (weak, nonatomic) IBOutlet UISlider *rangeSlider;
@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;
@property (strong, nonatomic) NSArray *optionsArray;

@property (strong, nonatomic) NSMutableArray *toggles;


- (IBAction)donePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)sliderUpdated:(id)sender;

@end

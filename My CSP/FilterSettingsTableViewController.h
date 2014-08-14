//
//  FilterSettingsTableViewController.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/11/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListingTableViewController.h"
#import "RentTableViewCell.h"
#import "SelectorTableViewCell.h"
#import "ToggleTableViewCell.h"
#import "SliderTableViewCell.h"
#import "MonthSelectTableViewCell.h"
#import "PickerTableViewCell.h"

@interface FilterSettingsTableViewController : UITableViewController <
    UIPickerViewDataSource,
    UIPickerViewDelegate
>

// Filter being used and modified
@property (strong, nonatomic) ListingFilter *filter;

// Field outlets to handle entering desired Rent values
// Require outlets to resign first responder on viewWillDisappear
@property (weak, nonatomic) IBOutlet UITextField *minRentField;
@property (weak, nonatomic) IBOutlet UITextField *maxRentField;

// Range adjustment properties. Not being used in current build
@property (weak, nonatomic) IBOutlet UISlider *rangeSlider;
@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;

// Array that holds labels for cell toggles
@property (strong, nonatomic) NSArray *toggleLabels;

// Picker to select desired available month/year
@property (strong, nonatomic) UIPickerView *picker;

// Used to hold month values in Picker
@property (strong, nonatomic) NSMutableArray *pickerLabels;

// Used to hold Picker date values
@property (strong, nonatomic) NSMutableArray *pickerDates;

// Used to hold amenity values for UISwitches in ToggleCells
@property (strong, nonatomic) NSMutableArray *toggles;


// Handle completion
- (IBAction)donePressed:(id)sender;

// Handle Cancel
- (IBAction)cancelPressed:(id)sender;

// Handle update of the Range Slider
// Not currently used
- (IBAction)sliderUpdated:(id)sender;

@end

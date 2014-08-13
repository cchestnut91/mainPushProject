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

@interface FilterSettingsTableViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) ListingFilter *filter;
@property (weak, nonatomic) IBOutlet UITextField *minRentField;
@property (weak, nonatomic) IBOutlet UITextField *maxRentField;
@property (weak, nonatomic) IBOutlet UISwitch *favoriteSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *nearSwitch;
@property (weak, nonatomic) IBOutlet UISlider *rangeSlider;
@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;
@property (strong, nonatomic) NSArray *optionsArray;
@property (strong, nonatomic) UIPickerView *picker;
@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSMutableArray *keys;
@property (strong, nonatomic) NSMutableArray *months;

@property (strong, nonatomic) NSMutableArray *toggles;


- (IBAction)donePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)sliderUpdated:(id)sender;

@end

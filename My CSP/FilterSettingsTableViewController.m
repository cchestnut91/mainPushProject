//
//  FilterSettingsTableViewController.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/11/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "FilterSettingsTableViewController.h"

@interface FilterSettingsTableViewController ()

@end

@implementation FilterSettingsTableViewController{
    
    // Bool to determine if Picker should be displayed or not
    BOOL showPicker;
    
    // Date formatter for use throughout class
    NSDateFormatter *formatter;
}

#pragma mark - View Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Grab filter from containing Navigation Controller
    self.filter = [(ListingTableNavigationController *)self.parentViewController filter];
    
    // Initialize showPicker to NO until user clicks monthCell
    showPicker = NO;
    
    // Set default row height
    [self.tableView setRowHeight:44];
    
    // Disable the back button
    // Will be replaced with 'close' button
    [self.navigationController.navigationItem setHidesBackButton:YES];
    
    // Initialize toggleLabels
    self.toggleLabels = [[NSArray alloc] initWithObjects:@"Near Me", @"Favorite", @"Includes Images", @"Cable", @"Hardwood Floors", @"Refrigerator", @"Laundry On Site", @"Oven", @"Air Conditioning", @"Balcony / Patio", @"Carport", @"Dishwasher", @"Fenced Yard", @"Fireplace", @"Garage", @"High Speed Internet", @"Microwave", @"Walk-In Closet", nil];
    
    // Initialize toggles with current value of filter amenities bools
    self.toggles = [self.filter getAmenities];
    
    
    // Initialize dateFormatter
    formatter = [[NSDateFormatter alloc] init];
    
    // Initialize Picker data arrays
    self.pickerLabels = [[NSMutableArray alloc] init];
    self.pickerDates = [[NSMutableArray alloc] init];
    
    // Add initial object to Picker data arrays
    [self.pickerLabels addObject:@"Any"];
    [self.pickerDates addObject:@"Any"];
    
    // Get current month and year as ints
    [formatter setDateFormat:@"MM"];
    int curMonth = [formatter stringFromDate:[[NSDate alloc] init]].intValue;
    [formatter setDateFormat:@"yyyy"];
    int curYear = [formatter stringFromDate:[[NSDate alloc] init]].intValue;
    
    // Initialize first label value with current month and year
    // Replaces the int with the String value of the month
    NSString *label = [NSString stringWithFormat:@"%@ %d", [self stringForMonth:curMonth], curYear];
    [self.pickerLabels addObject:label];
    
    // Initialzie first date value with current month and year
    [formatter setDateFormat:@"M yyyy"];
    NSString *date = [NSString stringWithFormat:@"%d %d", curMonth, curYear];
    [self.pickerDates addObject:[formatter dateFromString:date]];
    
    // Step through the next eleven months after currMonth
    for (int i = curMonth + 1; i < curMonth + 12; i++){
        
        // If new month is January
        if (i % 12 == 1){
            
            // Increment the year
            curYear++;
        }
        
        // Set the label value and add to the pickerLabels
        label = [NSString stringWithFormat:@"%@ %d", [self stringForMonth:i], curYear];
        [self.pickerLabels addObject:label];
        
        
        
        // Set the date value and add to the pickerDates
        if (i % 12 == 0){
            date = [NSString stringWithFormat:@"%d %d", 12, curYear];
        } else {
            date = [NSString stringWithFormat:@"%d %d", (i % 12), curYear];
        }
        
        [self.pickerDates addObject:[formatter dateFromString:date]];

    }
    
    
    if (![[(ListingTableNavigationController *)self.parentViewController source] isEqualToString:@"settings"]){
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Go" style:UIBarButtonItemStyleDone target:self action:@selector(donePressed:)];
        [self.navigationItem setRightBarButtonItem:button];
    }
}

// Run when viewIsDismissed
-(void)viewWillDisappear:(BOOL)animated{
    
    // will dismiss keyboard if it is currently showing before view dissapears
    [self.minRentField resignFirstResponder];
    [self.maxRentField resignFirstResponder];
}

#pragma mark- TableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // First two sections have two cells
    if (section < 2){
        return 2;
    }
    
    // Third section has two cells only if it should include the picker cell
    if (section == 2){
        if (showPicker) return 2;
        return 1;
    }
    
    // Fourth section has three cells for preferences
    if (section == 3){
        return 3;
    }
    
    if (section == 5){
        return 1;
    }
    
    // All other toggles, minus the three in section 4, go in the amenities section
    return self.toggleLabels.count - 3;
}

// Creates and returns the appropriate cell for each Table Row
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Cells for rooms selectors
    if (indexPath.section == 0){
        
        // Initialize cell with SegmentSelector
        SelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectorCell"];
        
        // Cannot select cell. Only the UI Elements within
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // For Beds cell
        if (indexPath.row == 0){
            
            // Set text label
            cell.label.text = @"Beds";
            
            // Set initial value from filter (0 by default)
            [cell.selector setSelectedSegmentIndex:self.filter.beds.integerValue];
            
            // Add selector for updating
            [cell.selector addTarget:self action:@selector(selectBeds:) forControlEvents:UIControlEventValueChanged];
        } else {
            
            // Same as beds cell
            cell.label.text = @"Baths";
            [cell.selector setSelectedSegmentIndex:self.filter.baths.integerValue];
            [cell.selector addTarget:self action:@selector(selectBaths:) forControlEvents:UIControlEventValueChanged];
        }
        
        // If cell was created sucessfully, return the cell
        if (cell) return cell;
    
    }
    // Cells for rent selector
    else if (indexPath.section == 1){
        
        // Get Cell with TextLabel and TextField
        RentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"minRentCell"];
        
        // Unable to select cell, only UI Elements within
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // For MinRent cell
        if (indexPath.row == 0){
            
            // Set text and placeholder
            [cell.label setText:@"Minimum Rent"];
            [cell.field setPlaceholder:@"$0"];
            
            
            // Attach cell's text field to minRentField
            self.minRentField = cell.field;
            
            // Add control target to field to handle changes
            [self.minRentField addTarget:self
                                  action:@selector(textFieldDidChange:)
                        forControlEvents:UIControlEventEditingChanged];
            
            // If filter has a low rent already set
            if (self.filter.lowRent != 0){
                
                // Override the placeholder with the lowRent value
                [self.minRentField setText:[NSString stringWithFormat:@"$%.0f", self.filter.lowRent]];
            }
        }
        
        // For MaxRent Cell
        else if (indexPath.row == 1){
            
            // Same as previous cell
            [cell.label setText:@"Maximum Rent"];
            [cell.field setPlaceholder:@"$4000"];
            
            self.maxRentField = cell.field;
            [self.maxRentField addTarget:self
                                  action:@selector(textFieldDidChange:)
                        forControlEvents:UIControlEventEditingChanged];
            
            if (self.filter.highRent != 0){
                [self.maxRentField setText:[NSString stringWithFormat:@"$%.0f", self.filter.highRent]];
            }
        }
        
        // If cell was properly initialzied, return
        if (cell) return cell;
    }
    // For month available section
    else if (indexPath.section == 2) {
        
        // Initial cell should show the currently selected month
        if (indexPath.row == 0){
            
            // Initialize cell with two UILabels
            MonthSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"monthLabel"];
            
            // If filter has nothing set for month
            if (self.filter.month == nil){
                
                // Set labels to "Any"
                [cell.monthLabel setText:@"Any"];
            } else {
                
                // If month preferred is set
                // Set the monthLabel to the appropriate text
                [formatter setDateFormat:@"MM yyyy"];
                [cell.monthLabel setText:[NSString stringWithFormat:@"%@ %@", [self stringForMonth:self.filter.month.intValue], self.filter.year]];
            }
            
            // Reset the date format to default value
            [formatter setDateFormat:@"M yyyy"];
            
            // If cell was properly initialized return
            if (cell) return cell;
        }
        // Picker cell
        else if (indexPath.row == 1){
            
            // Initialize from Storyboard
            PickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pickerCell"];
            
            // Cannot select the cell, can only interact with UI
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            // If picker has not been created yet
            if (!self.picker){
                
                // Initialize self.picker for the cell's picker and set delegates
                self.picker = cell.picker;
                [self.picker setDataSource:self];
                [self.picker setDelegate:self];
            } else {
                
                // If picker has already been created make sure it matches the one in the cell
                cell.picker = self.picker;
            }
            
            if (cell) return cell;
        }
    } else if (indexPath.section == 5){
        SliderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sliderCell"];
        
        self.rangeLabel = cell.rangeLabel;
        [self.rangeLabel setText:[NSString stringWithFormat:@"%.0f",self.filter.range]];
        cell.rangeSlider.value = self.filter.range / 50;
        
        [cell.rangeSlider addTarget:self action:@selector(sliderUpdated:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    // For Preferences or Amenities sections
    else {
        
        // Get cell with UISwitch from Storyboard
        ToggleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"toggleCell"];
        
        // Cannot select the cell, can only interact with UI
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        // Determine the current index
        NSInteger index = indexPath.row;
        
        // If in the amenities section, account for the three items in the previous section
        if (indexPath.section == 4) index = index + 3;
        
        // Set text with appropriate index
        [cell.label setText:[self.toggleLabels objectAtIndex:index]];
        
        // Set on to appropriate bool value
        [cell.toggle setOn:[[self.toggles objectAtIndex:index] boolValue]];
        
        // Set tag with index to identify on change
        [cell.toggle setTag:index];
        
        // Attach to action to respond to changes
        [cell.toggle addTarget:self action:@selector(changeToggle:) forControlEvents:UIControlEventValueChanged];
        
        // Return cell
        if (cell) return cell;
    }
    
    
    // Default cell to return in event of error
    // Only experienced on simulator
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Blah"];
}

// Returns appropriate height for each cell
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Picker Cell has one height
    if (indexPath.section == 2 && indexPath.row == 1){
        return 162;
    }
    
    // All others have default value
    return tableView.rowHeight;
}


// Returns appripriate section headers
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return @"Rooms";
    } else if (section == 1){
        return @"Rent";
    } else if (section == 2){
        return @"Move In Date";
    } else if (section == 3){
        return @"Preferences";
    } else if (section == 4){
        return @"Amenities";
    }
    return nil;
}


// Returns appropriate section footers
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 0){
        return @"";
    } else if (section == 1){
        return @"Only listings with rent in between these two values will be shown";
    } else if (section == 2){
        return @"Some listings may not be shown until closer to their Move-In date. Check the app regularly to see new listings available in the future";
    } else if (section == 3){
        return @"Listings fitting these preferences will be shown";
    }
    return nil;
}



#pragma mark - TableView Delegate

// Handle tableRow Selection
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Animate deselection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // If selected cell was the MonthCell (Not picker cell)
    if (indexPath.section == 2 && indexPath.row == 0){
        
        // Make the indexPath for the PickerCell
        NSIndexPath *pickerIndex = [NSIndexPath indexPathForRow:1 inSection:2];
        
        // If Picker cell is not already being displayed
        if ([tableView numberOfRowsInSection:2] != 2){
            
            // Set should show picker
            showPicker = YES;
            
            // Manually insert the desired row with animation
            [tableView insertRowsAtIndexPaths:@[pickerIndex] withRowAnimation:UITableViewRowAnimationFade];
            
            // Scroll table so picker is in the middle of the screen
            [tableView scrollToRowAtIndexPath:pickerIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            
            // Determine currently selected index of Picker
            NSInteger row = [self.picker selectedRowInComponent:0];
            
            // Ensure that the filter month and MonthCell textLabel match currently selected PickerIndex
            if (row == 0){
                [self.filter setMonth:nil];
                [self.filter setYear:nil];
            } else {
                [self.filter setMonth:[[formatter stringFromDate:self.pickerDates[row]] componentsSeparatedByString:@" "][0]];
                [self.filter setYear:[[formatter stringFromDate:self.pickerDates[row]] componentsSeparatedByString:@" "][1]];
            }
            [[(MonthSelectTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] monthLabel] setText:self.pickerLabels[row]];
            
            
        }
        // If Picker is already displayed
        else {
            
            // Set shouldn't show picker
            showPicker = NO;
            
            // Remove the picker row from the table
            [tableView deleteRowsAtIndexPaths:@[pickerIndex] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}



#pragma mark - PickerView Data Source

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    // Only one column for picker
    return 1;
}

// column has as many rows as determined in viewDidLoad
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerLabels.count;
}

// Column is represented by the label in pickerLabels at current index
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.pickerLabels[row];
}


#pragma mark - PickerView Delegate

// Run when user changes currently centered row or manually taps a particular index
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    // Identifies the monthCell
    NSIndexPath *labelIndex = [NSIndexPath indexPathForRow:0 inSection:2];
    MonthSelectTableViewCell *cell = (MonthSelectTableViewCell *)[self.tableView cellForRowAtIndexPath:labelIndex];
    
    // If user has selected "Any" option
    if (row == 0){
        // Set filter month values to nil
        [self.filter setMonth:nil];
        [self.filter setYear:nil];
    }
    // For any other option
    else {
        
        // Determine the appropriate values for month and year based on pickerDates
        [self.filter setMonth:[[formatter stringFromDate:self.pickerDates[row]] componentsSeparatedByString:@" "][0]];
        [self.filter setYear:[[formatter stringFromDate:self.pickerDates[row]] componentsSeparatedByString:@" "][1]];
    }
    
    // Reset the month label to apply
    [cell.monthLabel setText:self.pickerLabels[row]];
}


#pragma mark - Handle Option Changes

// Handles changing any toggle
-(IBAction)changeToggle:(id)sender{
    
    // Identify the amenity or preference by switch's tag
    NSInteger index = [(UISwitch *)sender tag];
    
    // Replace instance in toggles array with new value represented by NSNumber
    [self.toggles replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:[(UISwitch *)sender isOn]]];
}

// When a new option for numBeds is selected
-(IBAction)selectBeds:(id)sender{
    // Replace that value in the filter
    [self.filter setBeds:[NSNumber numberWithLong:[(UISegmentedControl *)sender selectedSegmentIndex]]];
}

// Same as with beds
-(IBAction)selectBaths:(id)sender{
    [self.filter setBaths:[NSNumber numberWithLong:[(UISegmentedControl *)sender selectedSegmentIndex]]];
}

// Used to handle change of Range slider
// Not used in current build
-(IBAction)sliderUpdated:(id)sender{
    
    // Updates label text
    // For simplicity, actual values on the slider and 50X smaller than desired values
    // Values go from 50 - 1000 on the label and in the filter
    // slider values are 1 - 20
    [self.rangeLabel setText:[NSString stringWithFormat:@"%d",(int)[(UISlider *)sender value] * 50]];
    [self.filter setRange:[(UISlider *)sender value] * 50];
}

// Handle change in RentLabel textFields
-(IBAction)textFieldDidChange:(id)sender{
    // Resets new text to include $ at the beginning after removing previous instances of the character
    [(UITextField *)sender setText:[NSString stringWithFormat:@"$%@", [[(UITextField *)sender text] stringByReplacingOccurrencesOfString:@"$" withString:@""]]];
}


#pragma mark - Finish and Save Filter

// Checks to make sure all fields are valid, and then ensures the filter has been updated before passing the filter along to the results page
- (IBAction)donePressed:(id)sender {
    
    // If minRent is greater than maxRent
    if (self.minRentField.text.floatValue > self.maxRentField.text.floatValue){
        
        // Tell the User they're stupid
        UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Bad Rent Values" message:@"Minimum rent cannot be more than the Maximum rent" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [fail show];
    }
    
    // If Looking for location but location is unknown
    else if (self.filter.location == nil && [[self.toggles objectAtIndex:0] boolValue]){
        
        // Inform the user that Location cannot be searched for
        UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Cannot determine location" message:@"Please search without 'Near Me' or close the search and try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [fail show];
    }
    
    // If no problems with user's intended search query
    else {
        
        // If min and Max fields have non nil values
        if (self.minRentField.text != nil){
            
            // Set the appropriate value in the filter
            [self.filter setLowRent:[self.minRentField.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue];
        }
        if (self.maxRentField.text != nil){
            [self.filter setHighRent:[self.maxRentField.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue];
        }
        
        // Set filter bools using values of toggles array
        [self.filter setFavorite:[self.toggles objectAtIndex:1]];
        [self.filter setCheckLocation:[self.toggles objectAtIndex:0]];
        [self.filter setImages:[self.toggles objectAtIndex:2]];
        [self.filter setCable:[self.toggles objectAtIndex:3]];
        [self.filter setHardWood:[self.toggles objectAtIndex:4]];
        [self.filter setFridge:[self.toggles objectAtIndex:5]];
        [self.filter setLaundry:[self.toggles objectAtIndex:6]];
        [self.filter setOven:[self.toggles objectAtIndex:7]];
        [self.filter setAir:[self.toggles objectAtIndex:8]];
        [self.filter setBalcony:[self.toggles objectAtIndex:9]];
        [self.filter setCarport:[self.toggles objectAtIndex:10]];
        [self.filter setDish:[self.toggles objectAtIndex:11]];
        [self.filter setFence:[self.toggles objectAtIndex:12]];
        [self.filter setFire:[self.toggles objectAtIndex:13]];
        [self.filter setGarage:[self.toggles objectAtIndex:14]];
        [self.filter setInternet:[self.toggles objectAtIndex:15]];
        [self.filter setMicrowave:[self.toggles objectAtIndex:16]];
        [self.filter setCloset:[self.toggles objectAtIndex:17]];
        
        // If this page if found through a advancedSearch cell on mainMenu
        if ([[(ListingTableNavigationController *)self.parentViewController source] isEqualToString:@"Search"]){
            
            // Push to a new navController containing the listingResults
            [self performSegueWithIdentifier:@"listings" sender:self];
        }
        
        // If source of this page is the preferences screen
        else if ([[(ListingTableNavigationController *)self.parentViewController source] isEqualToString:@"settings"]){
            
            NSMutableDictionary *prefDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"prefs.plist"]];
            
            [prefDict setObject:[NSKeyedArchiver archivedDataWithRootObject:self.filter] forKey:@"savedFilter"];
            [prefDict writeToFile:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"prefs.plist"] atomically:YES];
            
            // Dismiss containing viewController
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }
        
        // Only other path to this screen is modally from ListingResults screen
        else {
            
            // Modal views are contained in another NavigationController so
            // Dismiss contining navigation controller
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
}


#pragma mark - General

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    // If sending view to Listings Results
    if ([[segue identifier] isEqualToString:@"listings"]){
        
        // Send containing Navigation Controller's array of Listings
        [(ListingTableViewController *)[segue destinationViewController] setListings:[(ListingTableNavigationController *)self.navigationController listings]];
        
        // Send the adjusted filter
        [(ListingTableViewController *)[segue destinationViewController] setFilter:self.filter];
    }
}

// Cancel filter adjustment and dismiss view
- (IBAction)cancelPressed:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

// takes in the month as an int and returns the appropriate string
-(NSString *)stringForMonth:(int)month{
    switch (month%12) {
        case 1:
            return @"January";
            break;
        case 2:
            return @"Feburary";
            break;
        case 3:
            return @"March";
            break;
        case 4:
            return @"April";
            break;
        case 5:
            return @"May";
            break;
        case 6:
            return @"June";
            break;
        case 7:
            return @"July";
            break;
        case 8:
            return @"August";
            break;
        case 9:
            return @"September";
            break;
        case 10:
            return @"October";
            break;
        case 11:
            return @"November";
            break;
        case 0:
            return @"December";
            break;
            
        default:
            break;
    }
    return nil;
}

-(BOOL)shouldAutorotate{
    return NO;
}

@end

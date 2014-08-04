//
//  FilterSettingsTableViewController.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/11/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "FilterSettingsTableViewController.h"
#import "RentTableViewCell.h"
#import "SelectorTableViewCell.h"
#import "ToggleTableViewCell.h"
#import "SliderTableViewCell.h"

@interface FilterSettingsTableViewController ()

@end

@implementation FilterSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.filter = [(ListingTableNavigationController *)self.parentViewController filter];
    
    [self.navigationController.navigationItem setHidesBackButton:YES];
    
    self.optionsArray = [[NSArray alloc] initWithObjects:@"Near Me", @"Favorite", @"Includes Images", @"Cable", @"Hardwood Floors", @"Refrigerator", @"Laundry On Site", @"Oven", @"Air Conditioning", @"Balcony / Patio", @"Carport", @"Dishwasher", @"Fenced Yard", @"Fireplace", @"Garage", @"High Speed Internet", @"Microwave", @"Walk-In Closet", nil];
    [self.filter sing];
    NSLog(@"%@", [self.filter checkLocation]);
    self.toggles = [self.filter getAmenities];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.minRentField resignFirstResponder];
    [self.maxRentField resignFirstResponder];
    [self setTitle:@""];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section < 2){
        return 2;
    }
    if (section == 2){
        return 3;
    }
    return self.optionsArray.count - 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0){
        SelectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectorCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.row == 0){
            cell.label.text = @"Beds";
            [cell.selector setSelectedSegmentIndex:self.filter.beds.integerValue];
            [cell.selector addTarget:self action:@selector(selectBeds:) forControlEvents:UIControlEventValueChanged];
        } else {
            cell.label.text = @"Baths";
            [cell.selector setSelectedSegmentIndex:self.filter.baths.integerValue];
            [cell.selector addTarget:self action:@selector(selectBaths:) forControlEvents:UIControlEventValueChanged];
        }
        return cell;
    } else if (indexPath.section == 1){
        RentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"minRentCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        if (indexPath.row == 0){
            [cell.label setText:@"Minimum Rent"];
            [cell.field setPlaceholder:@"$0"];
            
            self.minRentField = cell.field;
            [self.minRentField addTarget:self
                                  action:@selector(textFieldDidChange:)
                        forControlEvents:UIControlEventEditingChanged];
            
            if (self.filter.lowRent != 0){
                [self.minRentField setText:[NSString stringWithFormat:@"$%.0f", self.filter.lowRent]];
            }
        } else if (indexPath.row == 1){
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
        return cell;
    } else {
        ToggleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"toggleCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        NSInteger index = indexPath.row;
        if (indexPath.section == 3) index = index + 3;
        [cell.label setText:[self.optionsArray objectAtIndex:index]];
        [cell.toggle setOn:[[self.toggles objectAtIndex:index] boolValue]];
        [cell.toggle setTag:index];
        [cell.toggle addTarget:self action:@selector(changeToggle:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
    
    return nil;
}

-(IBAction)changeToggle:(id)sender{
    NSInteger index = [(UISwitch *)sender tag];
    [self.toggles replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:[(UISwitch *)sender isOn]]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(IBAction)selectBeds:(id)sender{
    [self.filter setBeds:[NSNumber numberWithLong:[(UISegmentedControl *)sender selectedSegmentIndex]]];
}

-(IBAction)selectBaths:(id)sender{
    [self.filter setBaths:[NSNumber numberWithLong:[(UISegmentedControl *)sender selectedSegmentIndex]]];
}

-(IBAction)sliderUpdated:(id)sender{
    [self.rangeLabel setText:[NSString stringWithFormat:@"%d",(int)[(UISlider *)sender value] * 50]];
    [self.filter setRange:[(UISlider *)sender value] * 50];
}

-(IBAction)textFieldDidChange:(id)sender{
    [(UITextField *)sender setText:[NSString stringWithFormat:@"$%@", [[(UITextField *)sender text] stringByReplacingOccurrencesOfString:@"$" withString:@""]]];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0){
        return @"Rooms";
    } else if (section == 1){
        return @"Rent";
    } else if (section == 2){
        return @"Preferences";
    } else if (section == 3){
        return @"Amenities";
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 0){
        return @"";
    } else if (section == 1){
        return @"Only listings with rent in between these two values will be shown";
    } else if (section == 2){
        return @"Listings fitting these preferences will be shown";
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(id)sender {
// Adjust filter
    
    if (self.minRentField.text.floatValue > self.maxRentField.text.floatValue){
        UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Bad Rent Values" message:@"Minimum rent cannot be more than the Maximum rent" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [fail show];
    } else if (self.filter.location == nil && [[self.toggles objectAtIndex:0] boolValue]){
        
        UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Cannot determine location" message:@"Please search without 'Near Me' or close the search and try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [fail show];
    } else {
        if (self.minRentField.text != nil){
            [self.filter setLowRent:[self.minRentField.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue];
        }
        if (self.maxRentField.text != nil){
            [self.filter setHighRent:[self.maxRentField.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue];
        }
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
        
        [self.filter sing];
        
        if ([[(ListingTableNavigationController *)self.parentViewController source] isEqualToString:@"Search"]){
            [self performSegueWithIdentifier:@"listings" sender:self];
        } else if ([[(ListingTableNavigationController *)self.parentViewController source] isEqualToString:@"settings"]){
            
            NSString *filterFile = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"savedFiler"];
            
            [[NSKeyedArchiver archivedDataWithRootObject:self.filter] writeToFile:filterFile atomically:YES];
            
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"listings"]){
        [(ListingTableNavigationController *)[segue destinationViewController] setListing:[(ViewController *)self.presentingViewController listings]];
        [(ListingTableNavigationController *)[segue destinationViewController] setFilter:self.filter];
        [(ListingTableNavigationController *)[segue destinationViewController] setSource:@"Search"];
    }
}

- (IBAction)cancelPressed:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
@end

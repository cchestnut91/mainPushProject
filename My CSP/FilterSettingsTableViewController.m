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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.optionsArray = [[NSArray alloc] initWithObjects:@"Near Me", @"Favorite", @"Includes Images", @"Cable", @"Hardwood Floors", @"Refrigerator", @"Laundry On Site", @"Oven", @"Air Conditioning", @"Balcony / Patio", @"Carport", @"Dishwasher", @"Fenced Yard", @"Fireplace", @"Garage", @"High Speed Internet", @"Microwave", @"Walk-In Closet", nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.minRentField resignFirstResponder];
    [self.maxRentField resignFirstResponder];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section < 2){
        return 2;
    }
    return self.optionsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        SelectorTableViewCell *cell;
        if (indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"selectorCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.label setText:@"Beds"];
            [cell.selector addTarget:self action:@selector(selectBeds:) forControlEvents:UIControlEventValueChanged];
            [cell.selector setSelectedSegmentIndex:self.filter.beds.integerValue];
        } else if (indexPath.row == 1){
            cell = [tableView dequeueReusableCellWithIdentifier:@"selectorCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.label setText:@"Baths"];
            [cell.selector addTarget:self action:@selector(selectBaths:) forControlEvents:UIControlEventValueChanged];
            [cell.selector setSelectedSegmentIndex:self.filter.baths.integerValue];
        }
        return cell;
    } else if (indexPath.section == 1){
        if (indexPath.row == 0){
            RentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"minRentCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.label setText:@"Minimum Rent"];
            [cell.field setPlaceholder:@"$0"];
            
            self.minRentField = cell.field;
            [self.minRentField addTarget:self
                                  action:@selector(textFieldDidChange:)
                        forControlEvents:UIControlEventEditingChanged];
            
            if (self.filter.lowRent != 0){
                [self.minRentField setText:[NSString stringWithFormat:@"$%.0f", self.filter.lowRent]];
            }
            return cell;
        } else if (indexPath.row == 1){
            RentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"minRentCell"];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.label setText:@"Maximum Rent"];
            [cell.field setPlaceholder:@"$4000"];
            
            self.maxRentField = cell.field;
            [self.maxRentField addTarget:self
                          action:@selector(textFieldDidChange:)
                forControlEvents:UIControlEventEditingChanged];
            
            if (self.filter.highRent != 0){
                [self.maxRentField setText:[NSString stringWithFormat:@"$%.0f", self.filter.highRent]];
            }
            return cell;
        }
    } else if (indexPath.section == 2){
        ToggleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"toggleCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.label setText:[self.optionsArray objectAtIndex:indexPath.row]];
        if (indexPath.row == 0){
            
            self.nearSwitch = cell.toggle;
            
            [self.nearSwitch setOn:self.filter.checkLocation];
            
        } else if (indexPath.row == 1){
            
            self.favoriteSwitch = cell.toggle;
            
            [self.favoriteSwitch setOn:self.filter.favorite];
            
        } else {
            switch (indexPath.row) {
                case 2:
                    [cell.toggle setOn:self.filter.images];
                    break;
                case 3:
                    [cell.toggle setOn:self.filter.cable];
                    break;
                case 4:
                    [cell.toggle setOn:self.filter.hardWood];
                    break;
                case 5:
                    [cell.toggle setOn:self.filter.fridge];
                    break;
                case 6:
                    [cell.toggle setOn:self.filter.laundry];
                    break;
                case 7:
                    [cell.toggle setOn:self.filter.oven];
                    break;
                case 8:
                    [cell.toggle setOn:self.filter.air];
                    break;
                case 9:
                    [cell.toggle setOn:self.filter.balcony];
                    break;
                case 10:
                    [cell.toggle setOn:self.filter.carport];
                    break;
                case 11:
                    [cell.toggle setOn:self.filter.dish];
                    break;
                case 12:
                    [cell.toggle setOn:self.filter.fence];
                    break;
                case 13:
                    [cell.toggle setOn:self.filter.fire];
                    break;
                case 14:
                    [cell.toggle setOn:self.filter.garage];
                    break;
                case 15:
                    [cell.toggle setOn:self.filter.internet];
                    break;
                case 16:
                    [cell.toggle setOn:self.filter.microwave];
                    break;
                case 17:
                    [cell.toggle setOn:self.filter.closet];
                    break;
                    
                default:
                    break;
            }
        }
        return cell;
    }
    return nil;
}

-(IBAction)selectBeds:(id)sender{
    [self.filter setBeds:[NSNumber numberWithInt:[(UISegmentedControl *)sender selectedSegmentIndex]]];
}

-(IBAction)selectBaths:(id)sender{
    [self.filter setBaths:[NSNumber numberWithInt:[(UISegmentedControl *)sender selectedSegmentIndex]]];
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
        return @"Rent";
    } else if (section == 1){
        return @"Options";
    } else if (section == 2){
        return @"Near Range";
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 0){
        return @"Only listings with rent in between these two values will be shown";
    } else if (section == 1){
        return @"Toggle these settings to specify listings you would like to see";
    } else if (section == 2){
        return @"When 'Near Me' is on, this determines the 'near' range in meters";
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
    } else if (self.filter.location == nil && self.nearSwitch.isOn){
        UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Cannot determine location" message:@"Please search without 'Near Me' or close the search and try again" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [fail show];
    } else {
        [self setTitle:@""];
        if (self.minRentField.text != nil){
            [self.filter setLowRent:[self.minRentField.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue];
        }
        if (self.maxRentField.text != nil){
            [self.filter setHighRent:[self.maxRentField.text stringByReplacingOccurrencesOfString:@"$" withString:@""].floatValue];
        }
        [self.filter setFavorite:self.favoriteSwitch.isOn];
        [self.filter setCheckLocation:self.nearSwitch.isOn];
        [self.filter setImages:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:2]] toggle] isOn]];
        [self.filter setCable:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:3 inSection:2]] toggle] isOn]];
        [self.filter setHardWood:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:4 inSection:2]] toggle] isOn]];
        [self.filter setFridge:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:5 inSection:2]] toggle] isOn]];
        [self.filter setLaundry:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:6 inSection:2]] toggle] isOn]];
        [self.filter setOven:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:7 inSection:2]] toggle] isOn]];
        [self.filter setAir:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:8 inSection:2]] toggle] isOn]];
        [self.filter setBalcony:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:9 inSection:2]] toggle] isOn]];
        [self.filter setCarport:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:10 inSection:2]] toggle] isOn]];
        [self.filter setDish:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:11 inSection:2]] toggle] isOn]];
        [self.filter setFence:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:12 inSection:2]] toggle] isOn]];
        [self.filter setFire:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:13 inSection:2]] toggle] isOn]];
        [self.filter setGarage:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:14 inSection:2]] toggle] isOn]];
        [self.filter setInternet:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:15 inSection:2]] toggle] isOn]];
        [self.filter setMicrowave:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:16 inSection:2]] toggle] isOn]];
        [self.filter setCloset:[[(ToggleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:17 inSection:2]] toggle] isOn]];
        
        if ([[(ListingTableNavigationController *)self.parentViewController source] isEqualToString:@"Search"]){
            [self performSegueWithIdentifier:@"listings" sender:self];
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

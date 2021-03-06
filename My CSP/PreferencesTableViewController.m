//
//  PreferencesTableViewController.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/31/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "PreferencesTableViewController.h"

@interface PreferencesTableViewController ()

@end

@implementation PreferencesTableViewController {
    
    NSString *prefFile;
    NSString *savePlist;
    NSMutableDictionary *saveDict;
    NSMutableDictionary *prefDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    prefFile = [directory stringByAppendingPathComponent:@"prefs.plist"];
    savePlist = [directory stringByAppendingPathComponent:@"saves.plist"];
    
    saveDict = [[NSMutableDictionary alloc] initWithContentsOfFile:savePlist];
    prefDict = [[NSMutableDictionary alloc] initWithContentsOfFile:prefFile];

    
    [self.tableView setRowHeight:44];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // in iOS 8 you can link direcly to app's section in Settings.app
    // This section allows that by adding a new row
    // Return the number of rows in the section.
    if (section == 1 && [[UIDevice currentDevice].systemVersion floatValue] >= 8) return 2;
    
    // First section has a cell to clear preferences
    if (section == 0) return 2;
    return 1;
}

// Returns appropriate footer text for each section
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 0){
        return @"Search preferences will start with defaults, and can then be further customized in any search screen";
    }
    if (section == 1){
        return @"Nearby Notifications alert you if there is a nearby listing you may be interested in";
    }
    if (section == 2){
        return @"This cannot be undone";
    }
    return nil;
}

// Ensures each cell has expected height
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableView.rowHeight;
}

// Creates and returns cell for each row in table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Initializes an empty cell
    UITableViewCell *cell;
    
    // Search preferences section
    if (indexPath.section == 0){
        
        // Cell to link to search preferences
        if (indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
            return cell;
        } else {
            // Initializes the cell from the storyboard
            ButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultsCell"];
            
            // Cannot select Cell, only UI elements within
            [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            
            // Adds a target to the cell
            [cell.button addTarget:self action:@selector(clearSearch:) forControlEvents:UIControlEventTouchUpInside];
            
            // Sets title for the cell before returning
            [cell.button.titleLabel setText:@"Clear Preferences"];
            return cell;
        }
    }
    // Notifications preference cell
    else if (indexPath.section == 1){
        
        // Only this row will be displayed before iOS 8
        if (indexPath.row == 0){
            
            // Initializes cell from Storyboard
            ToggleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationsCell"];
            
            // If the preferences file exists, beacons allowed. Otherwise not
            [cell.toggle setOn:[prefDict[@"allowBeacons"] boolValue]];
            
            // Add target for change of switch state
            [cell.toggle addTarget:self action:@selector(toggleBeacons:) forControlEvents:UIControlEventTouchUpInside];
            
            // Set the cell's toggle to the new UISwitch
            return cell;
        }
        // Cell to link to Settings.app on iOS 8
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
            return cell;
        }
    }
    
    // Cell with option to clear saved favorites
    else {
        
        // Initializes cell from storyboard
        ButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favoritesCell"];
        
        // Adds action target to button
        [cell.button addTarget:self action:@selector(clearFavorites:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    // Return cell, if that has not already been done
    return cell;
}


#pragma mark - TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
    if (indexPath.section == 0 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"searchPreferences" sender:self];
    }
    if (indexPath.section == 0 && indexPath.row == 1){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Preferences?" message:@"Preferences will be adjusted to default values" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"I'm sure", nil];
        [alert show];
    }
    if (indexPath.section == 2){
        UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Deleting favorites cannot be undone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        [confirm show];
    }
}



#pragma mark - Respond to IBActions

// Asks user for confirmation to remove search preferences
-(IBAction)clearSearch:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Preferences?" message:@"Preferences will be adjusted to default values" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"I'm sure", nil];
    [alert show];
}

// Asks user for confirmation to remove saved favorites
-(IBAction)clearFavorites:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Deleting favorites cannot be undone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [alert show];
}


// Toggles beacon preferences
// There's probably a better way to do this
-(IBAction)toggleBeacons:(id)sender{
    // If file already exists
    if ([prefDict[@"allowBeacons"] boolValue]){
        
        // Remove the file
        [prefDict setObject:[NSNumber numberWithBool:NO] forKey:@"allowBeacons"];
        [prefDict writeToFile:prefFile atomically:YES];
    } else {
        
        // Create the file with dummy data
        [prefDict setObject:[NSNumber numberWithBool:YES] forKey:@"allowBeacons"];
        [prefDict writeToFile:prefFile atomically:YES];
    }
}


// Dismisses current view
- (IBAction)close:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - AlertView Delegate

// Handles user action of Alert View
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    // If alert view was to confirm deleting favorites
    if ([alertView.title isEqualToString:@"Are you sure?"]){
        
        // If user did not click cancel button
        if (buttonIndex != 0){
            
            
            // Read the items from the file
            NSArray *favorites = saveDict[@"savedFavorites"];
            
            // Remove the file from the Documents directory
            [saveDict setObject:[[NSMutableArray alloc] init] forKey:@"savedFavorites"];
            [saveDict writeToFile:savePlist atomically:YES];
            
            // Determine the userID to update favorites on server
            NSString *userID = saveDict[@"userUUID"];
            
            // For each favorite unitID in the favorites array
            for (NSString *favorite in favorites){
                
                // send REST command to remove the favorite from the user's favorites
                [[RESTfulInterface RESTAPI] removeUserFavorite:userID :favorite];
            }
            
            // Send notification to ViewController to update all listings
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLocalListings" object:nil];
        }
    }
    
    // If user responds to clear preferences confirmation
    else if ([alertView.title isEqualToString:@"Clear Preferences?"]){
        
        // User did not click cancel button
        if (buttonIndex != 0) {
            
            // Remove the save file from Docuemnts directory
            [prefDict removeObjectForKey:@"savedFilter"];
            [prefDict writeToFile:prefFile atomically:YES];
        }
    }
}


#pragma mark - General


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    // If sending user to a new Search Preferences view
    if ([segue.identifier isEqualToString:@"searchPreferences"]){
        
        // Initialize a default filter
        [(ListingTableNavigationController *)[segue destinationViewController] setFilter:[[ListingFilter alloc] initWithDefault]];
        
        // define the source
        [(ListingTableNavigationController *)[segue destinationViewController] setSource:@"settings"];
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

@end

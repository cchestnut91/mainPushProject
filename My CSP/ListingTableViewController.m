//
//  ListingTableViewController.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/8/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "ListingTableViewController.h"

@interface ListingTableViewController ()

@end

@implementation ListingTableViewController {
    
    // Holds selected Listing to pass to detail view
    Listing *selected;
}

#pragma mark-View Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Force custom row height
    [self.tableView setRowHeight:136];
    
    // Gets filter and listings from parent view
    self.filter = [(ListingTableNavigationController *)self.parentViewController filter];
    self.listings = [(ListingTableNavigationController *)self.parentViewController listings];
    
    
    // Forces to hide back button
    [self.navigationItem setHidesBackButton:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];\
    
    // If only showing a specific set of unitIDs
    if ([[(ListingTableNavigationController *)self.parentViewController source] isEqualToString:@"showUnits"]){
        
        // Different filter command
        self.filteredListings = [self.filter getSpecific:self.listings];
        
        // Remove search option so users don't get confused between this and a typical search screen
        [self.navigationItem setRightBarButtonItem:nil];
        
        // Add in a close button
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pressMenu:)]];
        
    } else {
        
        // Run the listing filter
        self.filteredListings = [self.filter filterListings:self.listings overrideDate:NO];
    }
    
    // Reload table View
    [self.tableView reloadData];
}

// Force close the containing navigation controller
- (IBAction)pressMenu:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.filteredListings.count == 0){
        // If no listings to display show 1 cell with message
        return 1;
    }
    
    // Return number of listings to display
    return self.filteredListings.count;
}

// Configure cell for display
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // If no listings to display
    if (self.filteredListings.count == 0){
        
        // Create and return 'no listings' cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noFoundCell" forIndexPath:indexPath];
        return cell;
    }
    
    // Create standard Listing cell
    ListingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listingCell" forIndexPath:indexPath];
    
    // Send Listing info to Cell
    [cell passListing:[self.filteredListings objectAtIndex:indexPath.row]];
    
    // Return cell
    return cell;
}

#pragma mark - TableView Delegate

// Handle user cell selection
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Animage cell deselection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // If no Listings, do nothing
    if (self.filteredListings.count == 0){
        return;
    }
    
    // Set Listing at selected Index as selected
    selected = [self.filteredListings objectAtIndex:indexPath.row];
    
    // Begin segue to Listing Detail View
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // If moving to Listing Details
    if ([[segue identifier] isEqualToString:@"showDetail"]){
        
        // Send selected Listing to target detail View
        [(ListingDetailViewController *)segue.destinationViewController passListing:selected];
        
    // If moving to search view
    } else if ([[segue identifier] isEqualToString:@"showSearch"]){
        
        // Pass the current filter to the Preferences view
        [(ListingTableNavigationController *)segue.destinationViewController setFilter:self.filter];
    }
}


// Force to stat in portrait
-(BOOL)shouldAutorotate{
    return NO;
}

@end

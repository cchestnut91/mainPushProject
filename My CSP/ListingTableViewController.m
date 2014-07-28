//
//  ListingTableViewController.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/8/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "ListingTableViewController.h"
#import "ListingDetailViewController.h"

@interface ListingTableViewController ()

@end

@implementation ListingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setRowHeight:136];
    
    self.filter = [(ListingTableNavigationController *)self.parentViewController filter];
    self.listings = [(ListingTableNavigationController *)self.parentViewController listing];
    
    [self.navigationItem setHidesBackButton:YES];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [closeButton setTitle:@"Menu" forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[self.navigationController.navigationBar.titleTextAttributes objectForKey:@"UITextAttributeFont"]];
    [closeButton addTarget:self action:@selector(closeParent) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    [self.navigationItem setLeftBarButtonItem:barButton];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    /*
    if ([[(ListingTableNavigationController *)self.parentViewController source] isEqualToString:@"Search"]){
        [(ListingTableNavigationController *)self.parentViewController setSource:nil];
        [self performSegueWithIdentifier:@"showSearch" sender:self];
    }
    */
    
    NSLog(@"%@", [self.presentingViewController class]);
     
    [self filterListings];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

-(void)closeParent{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)filterListings{
    self.filteredListings = [self.filter filterListings:self.listings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)search:(id)sender {
    if (self.navigationController.viewControllers.count >=2){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.filteredListings.count == 0){
        return 1;
    }
    return self.filteredListings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.filteredListings.count == 0){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noFoundCell" forIndexPath:indexPath];
        return cell;
    }
    ListingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listingCell" forIndexPath:indexPath];
    
    [cell passListing:[self.filteredListings objectAtIndex:indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.filteredListings.count == 0){
        return;
    }
    
    self.selected = [self.filteredListings objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]){
        [(ListingDetailViewController *)segue.destinationViewController passListing:self.selected];
    } else if ([[segue identifier] isEqualToString:@"showSearch"]){
        [(ListingTableNavigationController *)segue.destinationViewController setFilter:self.filter];
    }
}

@end

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

@implementation PreferencesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    /*
     iOS 8
    if (section == 1 && UIApplicationOpenSettingsURLString != nil) return 2;
    */
    return 1;
}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell"];
            return cell;
        } else {
            ButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favoritesCell"];
            [cell.button addTarget:self action:@selector(clearSearch:) forControlEvents:UIControlEventTouchUpInside];
            [cell.button.titleLabel setText:@"Clear Preferences"];
            return cell;
        }
    } else if (indexPath.section == 1){
        if (indexPath.row == 0){
            ToggleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationsCell"];
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"allowBeacons"];
            UISwitch *toggle = [[UISwitch alloc] initWithFrame:cell.toggle.frame];
            [toggle setOn:[[NSFileManager defaultManager] fileExistsAtPath:path]];
            [toggle addTarget:self action:@selector(toggleBeacons:) forControlEvents:UIControlEventValueChanged];
            cell.toggle = toggle;
            return cell;
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell"];
            return cell;
        }
    } else {
        ButtonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favoritesCell"];
        [cell.button addTarget:self action:@selector(clearFavorites:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    
    // Configure the cell...
    
    return cell;
}

-(IBAction)clearSearch:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Preferences?" message:@"Preferences will be adjusted to default values" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"I'm sure", nil];
    [alert show];
}
         
-(IBAction)clearFavorites:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Deleting favorites cannot be undone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [alert show];
}

-(IBAction)toggleBeacons:(id)sender{
    NSLog(@"Toggle");
}
- (IBAction)close:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    /*
     iOS 8
    if (indexPath.section == 1 && indexPath.row == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
     */
    if (indexPath.section == 0 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"searchPreferences" sender:self];
    }
    if (indexPath.section == 2){
        UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Deleting favorites cannot be undone" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
        [confirm show];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"Are you sure?"]){
        if (buttonIndex != 0){
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"favs.txt"];
            NSArray *favorites = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:path]];
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            NSString *userID = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:[path stringByReplacingOccurrencesOfString:@"favs.txt" withString:@"user.txt"]]];
            for (NSString *favorite in favorites){
                [[RESTfulInterface RESTAPI] removeUserFavorite:userID :favorite];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLocalListings" object:nil];
        }
    } else if ([alertView.title isEqualToString:@"Clear Preferences?"]){
        if (buttonIndex != 0) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"savedFiler"] error:nil];
            
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableView.rowHeight;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"searchPreferences"]){
        [(ListingTableNavigationController *)[segue destinationViewController] setFilter:[[ListingFilter alloc] initWithDefault]];
        [(ListingTableNavigationController *)[segue destinationViewController] setSource:@"settings"];
    }
}

-(BOOL)shouldAutorotate{
    return NO;
}

@end

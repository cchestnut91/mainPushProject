//
//  ViewController.m
//  My CSP
//
//  Created by Calvin Chestnut on 6/10/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.emptyFilter = [[ListingFilter alloc] init];
    
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *saveFile = [directory stringByAppendingPathComponent:@"savedListings.txt"];
    
    self.manager = [[CLLocationManager alloc] init];
    [self.manager setDelegate:self];
    self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined){
        [self.manager startMonitoringSignificantLocationChanges];
    }
    
    [self.table setDataSource:self];
    [self.table setDelegate:self];
    
    [self.searchBar setDelegate:self];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* attrs = [fm attributesOfItemAtPath:saveFile error:nil];
    
    BOOL needReload = YES;
    
    if (attrs != nil) {
        NSDate *date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
        NSLog(@"Date Created: %@", [date description]);
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy MM dd"];
        
        if ([[formatter stringFromDate:date] isEqualToString:[formatter stringFromDate:[NSDate date]]]){
            needReload = NO;
        } else {
            NSLog(@"Saved Before Today");
        }
    }
    else {
        NSLog(@"No attributes");
    }
    
    if (needReload){
        [self.table setUserInteractionEnabled:NO];
        [self.loadingView setHidden:NO];
        [self.loadingView.layer setCornerRadius:10];
        [self.loadingView setBackgroundColor:[UIColor colorWithRed:51/255.0 green:60/255.0 blue:77/255.0 alpha:.9]];
        dispatch_queue_t downloadListingQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
        
        dispatch_async(downloadListingQueue, ^{
            self.listings = [[[ListingPull alloc] init] getListings];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.loadingView setHidden:YES];
                [self.table setUserInteractionEnabled:YES];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.listings];
                [data writeToFile:saveFile atomically:YES];
            });
        });
    } else {
        [self.loadingView setHidden:YES];
        self.listings = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:saveFile]];
    }
    
    UIImage *imageA = [UIImage imageNamed:@"background.jpg"];
    UIImage *imageB = [UIImage imageNamed:@"scrollA.jpg"];
    UIImage *imageC = [UIImage imageNamed:@"scrollB.jpg"];
    UIImage *imageD = [UIImage imageNamed:@"scrollC.jpg"];
    self.backgroundArray = [[NSMutableArray alloc] initWithObjects:imageA, imageB, imageC, imageD, nil];
    
    self.pos = 0;
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(fadeImage:) userInfo:[NSNumber numberWithInt:self.pos] repeats:YES];
    [timer fire];
    self.pos++;
}

-(void)fadeImage:(NSTimer *)sender{
    int num = self.pos % self.backgroundArray.count;
    
    NSLog(@"%d", num);
    UIImage *toImage = [self.backgroundArray objectAtIndex:num];
    [UIView transitionWithView:self.backgroundImageView
                      duration:2.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.backgroundImageView.image = toImage;
                    } completion:nil];
    self.pos++;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
        UIAlertView *authorizeBeacons = [[UIAlertView alloc] initWithTitle:@"Find Listings With Beacons" message:@"Would you like to allow My CSP to use low energy Bluetooth to find places around you that you may be interested in the background?" delegate:self cancelButtonTitle:@"Sure!" otherButtonTitles:@"No Thanks", nil];
        [authorizeBeacons show];
    }
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] < 8  && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        UIAlertView *tryAgain = [[UIAlertView alloc] initWithTitle:@"Use Current Location" message:@"My CSP can use your location to show you listings closest to you. Would you like to allow this?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Ok!", nil];
        [tryAgain show];
    }
}

// TableView Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MainMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    
    switch (indexPath.row) {
        case 0:
            cell.label.text = @"Locations Near Me";
            [cell.iconImageView setImage:[UIImage imageNamed:@"MapPin"]];
            break;
        case 1:
            cell.label.text = @"Advanced Search";
            [cell.iconImageView setImage:[UIImage imageNamed:@"Glass"]];
            break;
        case 2:
            cell.label.text = @"My Favorites";
            [cell.iconImageView setImage:[UIImage imageNamed:@"Star"]];
            break;
        case 3:
            cell.label.text = @"My Profile";
            [cell.iconImageView setImage:[UIImage imageNamed:@"User"]];
            break;
        case 4:
            cell.label.text = @"Quick Tips";
            [cell.iconImageView setImage:[UIImage imageNamed:@"Bulb"]];
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 4){
        return (self.table.bounds.size.height / 5);
    }
    return self.table.rowHeight + 1;

}

// TableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0){
        if ([self locationEnabled]){
            if (self.location){
                self.filter = [[ListingFilter alloc] init];
                [self.filter setCheckLocation:YES];
                [self.filter setLocation:self.location];
                
                self.source = @"Near";
                
                [self performSegueWithIdentifier:@"showListings" sender:self];
            } else {
                UIAlertView *locating = [[UIAlertView alloc] initWithTitle:@"Cannot determine location" message:@"Still trying to locate you. Try again in a minute or two." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [locating show];
            }
        } else {
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Cannot Determine Location" message:@"You need to authorize My CSP to use your location. Would you like to open Location Settings?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [error show];
        }
    } else if (indexPath.row == 1){
        self.filter = [[ListingFilter alloc] init];
        [self.filter setLocation:self.location];
        
        self.source = @"Search";
        
        [self performSegueWithIdentifier:@"showSearch" sender:self];
    } else if (indexPath.row == 2) {
        self.filter = [[ListingFilter alloc] init];
        [self.filter setFavorite:YES];
        [self.filter setLocation:self.location];
        
        self.source = @"Favorites";
        
        [self performSegueWithIdentifier:@"showListings" sender:self];
    }
}

// AlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"Find Listings With Beacons"]){
        if (buttonIndex == 0){
            [self.manager requestAlwaysAuthorization];
        } else {
            UIAlertView *tryAgain = [[UIAlertView alloc] initWithTitle:@"Use Current Location" message:@"My CSP Can also use your location only within the app to show you places closest to you. Would you like to allow this?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Ok!", nil];
            [tryAgain show];
        }
    } else if ([alertView.title isEqualToString:@"Use Current Location"]){
        if (buttonIndex == 1){
            if ( [[[UIDevice currentDevice] systemVersion] floatValue] < 8 ){
                [self.manager startMonitoringSignificantLocationChanges];
            } else {
                [self.manager requestWhenInUseAuthorization];
            }
        }
    } else if ([alertView.title isEqualToString:@"Cannot Determine Location"]){
        if (buttonIndex == 1){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }
}

// SearchBar Delegate

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"Search");
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
    self.filter = [[ListingFilter alloc] init];
    [self.filter setKeyWords:[searchBar.text componentsSeparatedByString:@" "]];
    
    self.source = @"Keywords";
    
    [self performSegueWithIdentifier:@"showListings" sender:self];
}

// LocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status != kCLAuthorizationStatusNotDetermined){
        [manager startMonitoringSignificantLocationChanges];
    }
    if (status == kCLAuthorizationStatusAuthorizedAlways){
#warning Beacon Initialization and Monitoring goes here
    }
}

-(BOOL)locationEnabled{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        return true;
    }
    
    return false;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.location = locations.lastObject;
    self.filter.location = self.location;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showListings"]){
        [(ListingTableNavigationController *)[segue destinationViewController] setListing:self.listings];
        [(ListingTableNavigationController *)[segue destinationViewController] setFilter:self.filter];
        [(ListingTableNavigationController *)[segue destinationViewController] setSource:self.source];
    }
    if ([segue.identifier isEqualToString:@"showSearch"]){
        [(ListingTableNavigationController *)[segue destinationViewController] setListing:self.listings];
        [(ListingTableNavigationController *)[segue destinationViewController] setFilter:self.filter];
        [(ListingTableNavigationController *)[segue destinationViewController] setSource:self.source];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

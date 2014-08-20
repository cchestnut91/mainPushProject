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

@implementation ViewController{
    
    // Current position in array of background images to be displayed
    int pos;
    
    // Timer to handle image fade transitions
    NSTimer *timer;
    
    NSMutableDictionary *prefDict;
    NSMutableDictionary *saveDict;
    NSString *prefFile;
    NSString *savePlist;
}

#pragma mark-ViewLoading & Appearing

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initializes the LocationManager
    self.manager = [[CLLocationManager alloc] init];
    
    // Sets necessary delegates and data sources
    [self.table setDataSource:self];
    [self.table setDelegate:self];
    [self.searchBar setDelegate:self];
    [self.manager setDelegate:self];
    
    // Locates default documents directory
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    // Define files for saving data
    prefFile = [directory stringByAppendingPathComponent:@"prefs.plist"];
    savePlist = [directory stringByAppendingPathComponent:@"saves.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savePlist]){
        prefDict = [[NSMutableDictionary alloc] initWithContentsOfFile:prefFile];
        saveDict = [[NSMutableDictionary alloc] initWithContentsOfFile:savePlist];
    } else {
        prefDict = [[NSMutableDictionary alloc] init];
        saveDict = [[NSMutableDictionary alloc] init];
        
        [prefDict writeToFile:prefFile atomically:YES];
        [saveDict writeToFile:savePlist atomically:YES];
        
    }
    
    // String to hold UserID
    NSString *userUUID;
    
    // If userID File does not exist
    if (![saveDict objectForKey:@"userUUID"]){
        
        UIAlertView *welcome = [[UIAlertView alloc] initWithTitle:@"Welcome to the My CSP Beta" message:@"Thanks for helping us improve My CSP. Please report any issues you may have, or let us know if you have any other feedback. we'd love to hear from you! You can send bug reports or feedback at any time by shaking your phone. Try it out!" delegate:self cancelButtonTitle:@"Thanks!" otherButtonTitles:nil, nil];
        [welcome show];
        
        // Create a new UUID and save the string as the UserID
        userUUID = [[NSUUID UUID] UUIDString];
        
        // Attempt to send userID to server via RESTAPI
        // If it does not fail
        if (![[[RESTfulInterface RESTAPI] addNewAnonUser:userUUID] isEqualToString:@"0"]){
            
            [saveDict setObject:userUUID forKey:@"userUUID"];
            [saveDict writeToFile:savePlist atomically:YES];
        }
        
        // If RESTAPI failed to save data it will create a new UUID on next Load. No favorites will be saved
        
        [prefDict setObject:[NSNumber numberWithBool:YES] forKey:@"allowBeacons"];
        [prefDict writeToFile:prefFile atomically:YES];
        
    } else {
        
        // If file exists read the UserID from there
        userUUID = saveDict[@"userUUID"];
    }
    
    
    self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    // If status has been determined (approve or rejected on iOS 7)
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined){
        
        // Start monitoring for significant changes
        // Could be more specific with a loss to battery life
        [self.manager startMonitoringSignificantLocationChanges];
    }
    
    
    // Start notification observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openURLListings:) name:@"attemptDisplayListings" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceRemoveFavorites:) name:@"updateLocalListings" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToBeacon:) name:@"respondToBeacon" object:nil];

    
    // Disable UI elements on MainMenu during load
    [self.table setUserInteractionEnabled:NO];
    
    // Show Loading Indicator and set preferences
    [self.loadingView setHidden:NO];
    [self.loadingView.layer setCornerRadius:10];
    [self.loadingView setBackgroundColor:[UIColor colorWithRed:51/255.0 green:60/255.0 blue:77/255.0 alpha:.9]];
    
    
    // Create download queue for GCD
    dispatch_queue_t downloadListingQueue = dispatch_queue_create("com.Push.CSPListingDownload", 0);
    
    // Move to Listing Download Queue
    dispatch_async(downloadListingQueue, ^{
        
        // Get listings as array from ListingPull class
        self.listings = [[[ListingPull alloc] init] getListings];
        
        // Initialize bool saying that data is new
        BOOL new = YES;
        
        // If no listings were returned from ListingPull
        if (self.listings.count == 0){
            
            // If a previous save of the data is available
            if ([saveDict objectForKey:@"savedListings"]){
                
                // Load the listings from that data
                self.listings = [NSKeyedUnarchiver unarchiveObjectWithData:[saveDict objectForKey:@"savedListings"]];
                
                // This is not new data
                new = NO;
            }
        }
        
        // If data is new
        if (new){
            
            [saveDict setObject:[NSKeyedArchiver archivedDataWithRootObject:self.listings] forKey:@"savedListings"];
            [saveDict writeToFile:savePlist atomically:YES];
        }
        
        // Get favorites from server using UserID and RESTAPI
        NSArray *favorites = [[RESTfulInterface RESTAPI] getUserFavorites:userUUID];
        
        // If no favorites were returned from RESTAPI call
        if (favorites.count == 0){
            
            // Read favorites from save file
            if (saveDict[@"savedFavorites"]){
                favorites = [saveDict objectForKey:@"savedFavorites"];
            }
            // Make sure favorites match local listings favorites values
            [self checkFavorites:favorites];
            
            // If there are favorites saved that weren't accounted for in the server
            if (favorites.count != 0){
                
                // For each favorite
                for (NSString *unitID in favorites){
                    
                    // Attempt to save on the server database
                    if ([[RESTfulInterface RESTAPI] addUserFavorite:userUUID :unitID]) NSLog(@"Saved");
                }
            }
        }
        // If favorites were pulled from server sucessfully
        else {
            
            // Make sure they match with local listings
            [self checkFavorites:favorites];
        }
        
        // Save favorites to local file as backup
        [saveDict setObject:favorites forKey:@"savedFavorites"];
        [saveDict writeToFile:savePlist atomically:YES];
        
        // Return to the main queue for UI updates
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // Hide Loading Indicator
            [self.loadingView setHidden:YES];
            
            // Allow user to interact with UI
            [self.table setUserInteractionEnabled:YES];
            
            // Alert AppDelegate that listings have been loaded
            [[NSNotificationCenter defaultCenter] postNotificationName:@"finishLoadingListings" object:nil];
        });
    });
    
    
    
    // Uncomment to simulate beacons after launch
    // NSTimer *launchBeacon = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(simulateBeacon:) userInfo:nil repeats:NO];
    
    
}

// Forces statusBarStyle
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create background array
    self.backgroundArray = [[NSMutableArray alloc] initWithObjects:@"background.jpg", @"scrollB.jpg", @"scrollA.jpg", @"scrollC.jpg", nil];
    
    // Set the backgound view to the initial image
    [self.backgroundImageView setImage:[UIImage imageNamed:self.backgroundArray[0]]];
    
    // Makes sure navigation bar is hidden within this particular view
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    // Adjusts appearance of Search bar text field
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Method for iOS to allowAlwaysAuthorization. Requires iOS 8. Uncomment and refactor when iOS 8 reaches GM
    /*
     iOS 8 + 7
     if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [[[UIDevice currentDevice] systemVersion] floatValue] >= 8){
     UIAlertView *authorizeBeacons = [[UIAlertView alloc] initWithTitle:@"Find Listings With Beacons" message:@"Would you like to allow My CSP to use low energy Bluetooth to find places around you that you may be interested in the background?" delegate:self cancelButtonTitle:@"Sure!" otherButtonTitles:@"No Thanks", nil];
     [authorizeBeacons show];
     }
     */
    
    // If Device is not running iOS 8 AND authorizationStatus for LoactionManager has not been determined
    if ( [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        
        // Ask if the User would like to allow Location Services
        // AlertView Delegate method handles the rest
        UIAlertView *tryAgain = [[UIAlertView alloc] initWithTitle:@"Use Current Location" message:@"My CSP can use your location to show you listings closest to you. Would you like to allow this?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Ok!", nil];
        [tryAgain show];
    }
    
    // Initialize the position to zero
    pos = 0;
    
    // If images were properly loaded from the bundle
    if (self.backgroundArray.count != 0){
        
        // Initialize a timer that will fire every 10 seconds
        // On fire it will run fadeImage and pass pos as an NSNumber
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(fadeImage:) userInfo:[NSNumber numberWithInt:pos] repeats:YES];
        [timer fire];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [timer invalidate];
    
    self.backgroundArray = nil;
}

#pragma mark-Prepare to show Listing from URL

// Creates Views necessary to show Listings from URL link
// Called from posted notification
-(void)openURLListings:(NSNotification *)notification{
    
    // Gets URL Parameters as a NSDictionary from the notification
    NSDictionary *params = (NSDictionary *)notification.object;
    
    // Gets unitIDs for desired listings and saves as NSArray
    NSArray *listings = [[params objectForKey:@"listings"] componentsSeparatedByString:@","];
    
    // If only one listing needs to be shown
    if (listings.count == 1){
        
        // Step through each saved listing
        for (Listing *listing in self.listings){
            
            // Get Listing's unitID as a string
            NSString *unitID = listing.unitID.stringValue;
            
            // Check if equal to the desired unitID
            if ([unitID isEqualToString:listings[0]]){
                
                // Action triggered is a URL with single Listing
                self.source = @"single";
                
                // Grab needed navigation controller from the storyboard
                ListingTableNavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleNav"];
                
                // set navigation source
                nav.source = self.source;
                
                // Set navigation controller's Single listing object to current Listing
                nav.listings = [NSArray arrayWithObject:listing];
                
                
                // Request app delegate
                AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                
                // Instruct app delegate to display navigationController modally from currently visible ViewController
                [delegate presentViewControllerFromVisibleViewController:nav];
                
                
                // Breaks from the loop
                break;
            }
        }
    }
    
    // If more than one listing is being requested
    else if (listings.count > 1) {
        
        // Create a new empty filter
        self.filter = [[ListingFilter alloc] init];
        
        // Set filter's unitIDs value
        [self.filter setUnitIDS:listings];
        
        // set source to indicate showing particular unitIDS
        self.source = @"showUnits";
        
        // Get listingResults navigation controller form Storyboard
        ListingTableNavigationController *nav = [self.storyboard instantiateViewControllerWithIdentifier:@"listingResults"];
        
        // Set necessary values
        nav.source = self.source;
        nav.filter = self.filter;
        nav.listings = self.listings;
        
        // Request App delegate
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        // Instruct app delegate to display navigationController modally from currently visible ViewController
        [delegate presentViewControllerFromVisibleViewController:nav];
        
    }
}

-(void)simulateBeacon:(NSTimer *)sender{
    NSURL *unitsURL = [NSURL URLWithString:@"Cspmgmt://?listings=78018"];
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjects:@[unitsURL] forKeys:@[@"targetURL"]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"respondToBeacon" object:nil userInfo:userInfo];
}

-(void)respondToBeacon:(NSNotification *)notification{
    
    BOOL canShowBeacons = [prefDict[@"allowBeacons"] boolValue];
    if (canShowBeacons){
        
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication] displayNearbyNotification:notification];
    
    } else {
        NSLog(@"User has not allowed Nearby Notifications");
    }
    
}

// Forces local listings to match expected favorite values
-(void)checkFavorites:(NSArray *)favorites{
    
    // For each Listing
    for (Listing *listing in self.listings){

        // If favorites array contains the unitID
        // (expected favorite
        if ([favorites containsObject:listing.unitID.stringValue]){
            
            // If not favorited
            if (!listing.favorite){
                
                // set favorite
                [listing setFavorite:YES];
            }
        }
        // If array doesn't contain unitID
        // Expected unfavorite
        else {
            if (listing.favorite){
                [listing setFavorite:NO];
            }
        }
    }
}

// Creates an empty array of favorites and 'checks' them, effectively marking all Listings as unfavorited
// Called from notification when User confirms 'erase all favorites' from preferences
-(void)forceRemoveFavorites:(NSNotification *)notification{
    NSArray *favorites = [[NSArray alloc] init];
    [self checkFavorites:favorites];
}


// fades imageView to the next image in the background array
-(void)fadeImage:(NSTimer *)sender{
    
    pos = pos % self.backgroundArray.count;
    
    // Defines the next image to be displayed
    self.toImage = nil;
    self.toImage = [UIImage imageNamed:[self.backgroundArray objectAtIndex:pos % self.backgroundArray.count]];
    
    // Performs transition animation
    [UIView transitionWithView:self.backgroundImageView
                      duration:2.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        
                        // Defines actual change to the view to be made
                        self.backgroundImageView.image = self.toImage;
                    } completion:^(BOOL completed){
                        
                        pos++;
                    }];
}

#pragma mark-TableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

// Returns cell for each row in the table with the expected icon and text
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
            cell.label.text = @"Preferences";
            [cell.iconImageView setImage:[UIImage imageNamed:@"User"]];
            break;
        case 4:
            cell.label.text = @"Tenent Info";
            [cell.iconImageView setImage:[UIImage imageNamed:@"Bulb"]];
            break;
            
        default:
            break;
    }
    
    return cell;
}

// Determines height for each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Default value at 1/5 full size
    if (indexPath.row != 4){
        return (self.table.bounds.size.height / 5);
    }
    
    // Extra pixel to remove bottom border
    return self.table.rowHeight + 1;

}

#pragma mark-TableViewDelegate


// Called when user selects a row of a tableView
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Animate deselection
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Pressed near me
    if (indexPath.row == 0){
        
        // If locationServices have been enabled
        if ([self locationEnabled]){
            
            // If current location has been determined.
            if (self.location){
                
                // Initialize an empty filter
                self.filter = [[ListingFilter alloc] init];
                
                // Set filter to check by location
                [self.filter setCheckLocation:[NSNumber numberWithBool:YES]];
                
                // Pass filter the user's current location
                [self.filter setLocation:self.location];
                
                // User selected "near me"
                self.source = @"Near";
                
                // start segue to listing results page
                [self performSegueWithIdentifier:@"showListings" sender:self];
                
            }
            // if current location unknown
            else {
                
                // Alert user to try again later
                UIAlertView *locating = [[UIAlertView alloc] initWithTitle:@"Cannot determine location" message:@"Still trying to locate you. Try again in a minute or two." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [locating show];
            }
        }
        // If location services not enabled
        else {
            
            // Alert user to adjust privacy settings
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Cannot Determine Location" message:@"You need to authorize My CSP to use your location. You can do this in your device Privacy Settings" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [error show];
        }
    }
    // User selected Advanced Search
    else if (indexPath.row == 1){
        
        // Attempt to create filter with preferred settings
        self.filter = [[ListingFilter alloc] initWithDefault];
        
        // pass filter user's current location
        [self.filter setLocation:self.location];
        
        // User clicked Search
        self.source = @"Search";
        
        // Begin segue to search preferences page
        [self performSegueWithIdentifier:@"showSearch" sender:self];
    }
    // User selected favorites
    else if (indexPath.row == 2) {
        
        // Create empty filter
        self.filter = [[ListingFilter alloc] init];
        
        // Set filter by favorites
        [self.filter setFavorite:[NSNumber numberWithBool:YES]];
        
        // Pass user's location
        [self.filter setLocation:self.location];
        
        // User click favorites
        self.source = @"Favorites";
        
        // Begin segue to listings results page
        [self performSegueWithIdentifier:@"showListings" sender:self];
        
    }
    // User clicked preferences
    else if (indexPath.row == 3){
        
        // Begin segug to Preferences page
        [self performSegueWithIdentifier:@"preferences" sender:self];
    }
    // User clicked info
    else if (indexPath.row == 4){
        
        // Begin segue to Info page
        [self performSegueWithIdentifier:@"showInfo" sender:self];
    }
}

#pragma mark-AlertView Delegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    // Respond to request for AlwaysAuthroization
    // iOS 8 only
    /* 
     iOS 8
    if ([alertView.title isEqualToString:@"Find Listings With Beacons"]){
        if (buttonIndex == 0){
            [self.manager requestAlwaysAuthorization];
        } else {
            UIAlertView *tryAgain = [[UIAlertView alloc] initWithTitle:@"Use Current Location" message:@"My CSP Can also use your location only within the app to show you places closest to you. Would you like to allow this?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Ok!", nil];
            [tryAgain show];
        }
    } else 
     */
    
    // Check alert title to see if it is the Use Current Location request
    if ([alertView.title isEqualToString:@"Use Current Location"]){
        
        // If user did not click "No"
        if (buttonIndex == 1){
            /*
             iOS 7
             */
            // Automatically asks user for permission a second time
            [self.manager startMonitoringSignificantLocationChanges];
            
            /*
            iOS 8 & 7
            if ( [[[UIDevice currentDevice] systemVersion] floatValue] < 8 ){
                [self.manager startMonitoringSignificantLocationChanges];
            } else {
                [self.manager requestWhenInUseAuthorization];
            }
            */
        }
    }
}

#pragma mark-UISearchBar Delegate

// Activated when user clicks search bar
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // Animate in the cancel button
    [searchBar setShowsCancelButton:YES animated:YES];
}

// Handle user clicking cancel on Search Bar
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    // Hide cancel button and resign first responder
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

// Perform search
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    // resign first responder and hide the cancel button
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];

    // creates an empty filter
    self.filter = [[ListingFilter alloc] init];
    
    // set filter keywords to the contents of the searchBar
    // Seperate searchbar contents into an array of keywords
    [self.filter setKeyWords:[searchBar.text componentsSeparatedByString:@" "]];
    
    // User clicked keywords
    self.source = @"Keywords";
    
    // Start segue to listing results
    [self performSegueWithIdentifier:@"showListings" sender:self];
}

#pragma mark-LocationManager Delegate

// Called when authorizationStatus updates
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
    // If non-default status
    if (status != kCLAuthorizationStatusNotDetermined){
        
        // Attempt to start monitoring location
        [manager startMonitoringSignificantLocationChanges];
        
        // Will do nothing if not authorized
    }
    /*
     iOS 8 + 7
    if (status == kCLAuthorizationStatusAuthorizedAlways){
#warning Beacon Initialization and Monitoring goes here
    }
     */
    
    // If alwaysAuthorized enabled
    if (status == kCLAuthorizationStatusAuthorized){
        
        // Load beacon info from REST API call and begin monitoring for Beacons
        
        self.beaconDictionary = [[NSMutableDictionary alloc] init];
        
        NSArray *beaconData = [[RESTfulInterface RESTAPI] getAllBeacons];
        if (beaconData){
            for (NSArray *beaconArray in beaconData){
                CLBeaconRegion *beacon = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID UUID] initWithUUIDString:beaconArray[2]] major:[beaconArray[3] intValue] minor:[beaconArray[4] intValue] identifier:beaconArray[0]];
                [self.beaconDictionary setObject:beacon forKey:beaconArray[0]];
            }
            
            [saveDict setObject:[NSKeyedArchiver archivedDataWithRootObject:self.beaconDictionary] forKey:@"savedBeacons"];
            [saveDict writeToFile:savePlist atomically:YES];
            
        } else {
            NSLog(@"Attempting to load beacons from local copy");
            
            if (saveDict[@"savedBeacons"]){
                self.beaconDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:saveDict[@"savedBeacons"]];
            } else {
                NSLog(@"No Saved Beacons");
            }
        }
        
        if (self.beaconDictionary.count > 0){
            // Pull campaign data
            
            self.campaigns = [[NSMutableArray alloc] init];
            
            NSArray *campaigns = [[RESTfulInterface RESTAPI] getCampaignHasBeacon];
            
            if (campaigns){
                for (NSArray *campaign in campaigns){
                    NSDictionary *newCampaign = [[NSDictionary alloc] initWithObjects:@[campaign[0], campaign[1], campaign[2]] forKeys:@[@"campaignID", @"unitID", @"beaconID"]];
                    [self.campaigns addObject:newCampaign];
                }
                
                [saveDict setObject:self.campaigns forKey:@"savedCampaigns"];
                [saveDict writeToFile:savePlist atomically:YES];
            } else {
                
                NSLog(@"Erorr loading campaigns");
                // Attempt to load local campaigns
                
                if (saveDict[@"savedCampaigns"]){
                    self.campaigns = saveDict[@"savedCampaigns"];
                } else {
                    NSLog(@"No local copy");
                }
                
            }
            
            if (self.campaigns.count > 0){
                NSMutableDictionary *filteredBeacons = [[NSMutableDictionary alloc] init];
                NSMutableDictionary *beaconsToListings = [[NSMutableDictionary alloc] init];
                
                for (NSDictionary *campaign in self.campaigns){
                    [filteredBeacons setObject:[self.beaconDictionary objectForKey:campaign[@"beaconID"]] forKey:campaign[@"beaconID"]];
                    
                    if (![beaconsToListings objectForKey:campaign[@"beaconID"]]){
                        [beaconsToListings setObject:[[NSMutableArray alloc] initWithObjects:campaign[@"unitID"], nil] forKey:campaign[@"beaconID"]];
                    } else {
                        [[beaconsToListings objectForKey:campaign[@"beaconID"]] addObject:campaign[@"unitID"]];
                    }
                }
                
                // Filter for beacons within a campaign
                
                //filteredBeacons = self.beaconDictionary.allValues;
                
                [[PUSHListener defaultListener] setBeaconToListing:beaconsToListings];
                
                [[PUSHListener defaultListener] setCampaigns:self.campaigns];
                
                [[PUSHListener defaultListener] listenForBeacons:filteredBeacons.allValues notificationInterval:90];
            }
            
        }
    }
}


// Determines if location services are enabled
-(BOOL)locationEnabled{
    /*
     iOS 8 + 7
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        return true;
    }
     */
    
    // If locationServices authorized
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized){
        return true;
    }
    
    return false;
}

// Called when locationManager updates Location
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    // set current location to the user's last known location
    self.location = locations.lastObject;
    
    NSLog(@"Did update Location");
    NSLog(@"New Location Lat: %.5f\nLong: %.5f", self.location.coordinate.latitude, self.location.coordinate.longitude);
    NSLog(@"Accuracy: %.5f", self.location.horizontalAccuracy);
    
    [Instabug setUserData:[NSString stringWithFormat:@"Lat:%.5f, Long:%.5f, accur:%f", self.location.coordinate.latitude, self.location.coordinate.longitude, self.location.horizontalAccuracy]];
    
    // update current location in filter object as well
    self.filter.location = self.location;
}


#pragma mark-Segue preperation


// Called when view will use Segue to transition
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // If moving to Listing Results view or Search view
    if ([segue.identifier isEqualToString:@"showListings"] || [segue.identifier isEqualToString:@"showSearch"]){
        
        // Pass necessary information to new NavigationController
        [(ListingTableNavigationController *)[segue destinationViewController] setListings:self.listings];
        [(ListingTableNavigationController *)[segue destinationViewController] setFilter:self.filter];
        [(ListingTableNavigationController *)[segue destinationViewController] setSource:self.source];
    }
}

#pragma mark-General

// View will work only in portrait mode
-(BOOL)shouldAutorotate{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    self.backgroundArray = nil;
    [timer invalidate];
}

@end

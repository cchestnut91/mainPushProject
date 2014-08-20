//
//  AppDelegate.m
//  My CSP
//
//  Created by Calvin Chestnut on 6/10/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
            

@end

@implementation AppDelegate {
    
    // Used to hold URL while app loads Listings
    NSURL *holdURL;
    NSArray *campaignIDs;
}

// Called when application launches with options
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Instabug startWithToken:@"a5ff3ac4448286e3f46ce37d55688f7e" captureSource:IBGCaptureSourceUIKit invocationEvent:IBGInvocationEventShake];
    
    UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    // Checks to see if app opened with a URL
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        
        NSLog(@"launchOptions URL");
        
        // Saves this URL to the class to come back to when Listings have loaded
        holdURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        
        // Creates notification observer which will open the URL when called
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attemptOpenURL:) name:@"finishLoadingListings" object:nil];
        
    } else if (localNotification){
        
        NSLog(@"launchOptions localNotification");
        
        NSDictionary *userInfo = [localNotification userInfo];
        
//        UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"LocalNotification" message:@"Triggered" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [confirm show];
        
        
        holdURL = [NSURL URLWithString:userInfo[@"targetURLString"]];
        campaignIDs = userInfo[@"campaignIDs"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attemptOpenURL:) name:@"finishLoadingListings" object:nil];
    }
    
    // Allows app delegate to progress normally
    return YES;
}

// Selector for finishLoadingListings
// Tells application to attempt to open the URL
// Removes Notification observer
-(void)attemptOpenURL:(NSURL *)url{
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    NSArray *listings = [[self parseQueryString:url.query][@"listings"] componentsSeparatedByString:@","];
    
    NSLog(@"Begining to open URL: %@", url.absoluteString);
    if (listings.count > 0){
        
        NSString *message;
        
        if (listings.count == 1){
            message = @"There's a listing nearby you may be interested in";
        } else {
            message = [NSString stringWithFormat:@"There are %lu listings nearby you may be interested in", (unsigned long)listings.count];
        }
        
        NSLog(@"Displaying alert with %lu listings", (unsigned long)listings.count);
        
        UIAlertView *openBeacons = [[UIAlertView alloc] initWithTitle:@"Nearby Listings" message:message delegate:self cancelButtonTitle:@"No Thanks" otherButtonTitles:@"Show", nil];
        [openBeacons show];
        
    }
}

// Called when URL opened
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    // Passes URL query and receives a dictionary of URL parameters
    NSDictionary *params = [self parseQueryString:[url query]];
    
    // Sends notification with URL parameters to mainMenuViewController
    [[NSNotificationCenter defaultCenter] postNotificationName:@"attemptDisplayListings" object:params];
    
    // Allows app delegate to progress normally
    return YES;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"received notification");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openAfterNotification" object:nil];
    
    [self attemptOpenURL:holdURL];
}

// Allows application to open the URL
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    
    return YES;
}

// Takes in a URL query with format keyA=valueA&keyB=valueB
// Returns NSDictionary of key-value pairs
- (NSDictionary *)parseQueryString:(NSString *)query {
    
    // Creates new MutableDictionary
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // Seperates query into key-value pairs, formatted as an Array of Strings
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    // For each string pair
    for (NSString *pair in pairs) {
        
        // Split the pair into key and value
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // Add key-value pair to Dictionary
        [dict setObject:val forKey:key];
    }
    
    // Return Dictionary
    return dict;
}

// Displays listings from URL modally from whichever ViewController is currently visible
// Takes desired ViewController to be presented as a paramter
-(void)presentViewControllerFromVisibleViewController:(UIViewController *)toPresent{
    
    // Determines the currently visible ViewController
    UIViewController *vc = [(UINavigationController *)self.window.rootViewController visibleViewController];
    
    NSLog(@"Displaying notification over %@", vc.class);
    
    // Present desired ViewController modally from currently visible ViewController
    [vc presentViewController:toPresent animated:YES completion:nil];
}

-(void)application:(UIApplication *)application displayNearbyNotification:(NSNotification *)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    
    NSURL *targetURL = userInfo[@"targetURL"];
    
    holdURL = targetURL;
    campaignIDs = userInfo[@"campaignIDs"];
    
    
    UILocalNotification *openBeacons = [[UILocalNotification alloc] init];
    
    userInfo = [[NSDictionary alloc] initWithObjects:@[targetURL.absoluteString, userInfo[@"campaignIDs"]] forKeys:@[@"targetURLString", @"campaignIDs"]];
    
    NSArray *params = [[self parseQueryString:targetURL.query][@"listings"] componentsSeparatedByString:@","];;
    
    [openBeacons setUserInfo:userInfo];
    
    if (params.count == 1){
        [openBeacons setAlertBody:@"There's a listing nearby you may be interested in"];
    } else {
        [openBeacons setAlertBody:[NSString stringWithFormat:@"There are %lu listings nearby you may be interested in", (unsigned long)params.count]];
    }
    
    [openBeacons setAlertAction:@"View"];
    
    [openBeacons setSoundName:UILocalNotificationDefaultSoundName];
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:openBeacons];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attemptOpenURL:) name:@"openAfterNotification" object:nil];
    
    NSLog(@"close App");
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSString *userUUID = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"saves.plist"]][@"userUUID"];
    
    if (buttonIndex != 0){
        NSLog(@"User clicked Yes to see listings");
        for (NSString *campaignID in campaignIDs){
            [[RESTfulInterface RESTAPI] registerTriggeredBeaconAction:campaignID :@"rental" :YES :userUUID];
        }
        
        [self application:[UIApplication sharedApplication] openURL:holdURL sourceApplication:nil annotation:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishLoadingListings" object:nil];
    } else {
        NSLog(@"User clicked No to see listings");
        for (NSString *campaignID in campaignIDs){
            [[RESTfulInterface RESTAPI] registerTriggeredBeaconAction:campaignID :@"rental" :NO :userUUID];
        }
    }
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    
    NSLog(@"Received memory warning");
    NSNumber *currentID;
    UIViewController *vc;
    
    NSArray *listings = [(ViewController *)[(ListingTableNavigationController *)self.window.rootViewController viewControllers][0] listings];
    for (Listing *listing in listings){
        currentID = nil;
        vc = [(UINavigationController *)self.window.rootViewController visibleViewController];
        if ([vc isKindOfClass:[ListingDetailViewController class]]){
            currentID = [[(ListingDetailViewController *)vc listing] unitID];
        } else if ([vc isKindOfClass:[RotatingPreviewController class]]){
            currentID = [[(RotatingPreviewController *)vc listing] unitID];
        }
        
        if (currentID && [listing.unitID isEqualToNumber:currentID]){
            continue;
        }
        
        if (listing.imageArray.count > 0){
            listing.imageArray = [NSMutableArray arrayWithObject:listing.imageArray[0]];
        }
    }
    
}

// Untouched AppDelegate Methods

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"openAfterNotification" object:nil];
    // [[NSNotificationCenter defaultCenter] removeObserver:self name:@"openAfterNotification" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

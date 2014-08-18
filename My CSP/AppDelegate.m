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
}

// Called when application launches with options
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Checks to see if app opened with a URL
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        
        // Saves this URL to the class to come back to when Listings have loaded
        holdURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        
        // Creates notification observer which will open the URL when called
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attemptOpenURL:) name:@"finishLoadingListings" object:nil];
        
    }
    
    // Allows app delegate to progress normally
    return YES;
}

// Selector for finishLoadingListings
// Tells application to attempt to open the URL
// Removes Notification observer
-(void)attemptOpenURL:(NSURL *)url{
    
    [self application:[UIApplication sharedApplication] openURL:holdURL sourceApplication:nil annotation:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishLoadingListings" object:nil];
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
    
    // Present desired ViewController modally from currently visible ViewController
    [vc presentViewController:toPresent animated:YES completion:nil];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application{
    
    NSLog(@"Deleting From App Delegate");
    
    
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

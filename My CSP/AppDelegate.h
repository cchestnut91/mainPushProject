//
//  AppDelegate.h
//  My CSP
//
//  Created by Calvin Chestnut on 6/10/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListingDetailViewController.h"
#import "ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

// Displays listings from URL modally from whichever ViewController is currently visible
// Takes desired ViewController to be presented as a paramter
-(void)presentViewControllerFromVisibleViewController:(UIViewController *)toPresent;

-(void)application:(UIApplication *)application displayNearbyNotification:(NSNotification *)notification;

@end


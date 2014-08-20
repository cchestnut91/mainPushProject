//
//  PUSHListener.h
//  pushRestAPI
//
//  Created by Andrew Sowers on 6/27/14.
//  Copyright (c) 2014 Andrew Sowers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ListingFilter.h"
#import "ViewController.h"

@import CoreLocation;

// Notificaton
extern NSString * const kPUSHDidFindNotification;
extern NSString * const kPUSHBeacon;

@interface PUSHListener : NSObject

@property (strong, nonatomic) NSDictionary *beaconToListing;

@property (strong, nonatomic) NSArray *campaigns;

#pragma mark - Singleton
/**
 *  Singleton listner. Use this to register and lsitne for iBeacons acrross the app.
 *
 *  @return PUSHListner Singleton
 */

+(instancetype)defaultListener;

#pragma mark -Start Listner

/**
 *  Tells the listener to start listening for iBeacons with an array of beaconRegions to listne for. The default notification interval of 0 seconds is used.
 *
 *  @param proximityIds NSArray of NSUUIDs
 */
- (void)listenForBeacons:(NSArray *)beacons;

/**
 *  Tells the listener to start listening for iBeacons with an array of beaconRegions to listen for. The notification interval sets the number of seconds to wait after seeing a beacon before notifying again.
 *
 *  @param beacons NSArray
 *  @param seconds      NSTimeInterval
 */
- (void)listenForBeacons:(NSArray *)beacons notificationInterval:(NSTimeInterval)seconds;

/**
 *  Tells the listener to start listening for iBeacons with a dictionaty of beacon credentials. JSON scheme is predetermined and grabed via the RESTful service.
 *
 *  @param beaconJSON NSDictonary
 */
// - (void)listenForBeaconsFromJSONScheme:(NSDictionary *)beaconsWithinJSON;

/**
 *  Tells the listener to start listening for iBeacons with a dictionaty of beacon credentials. JSON scheme is predetermined and grabed via the RESTful service. The notification interval sets the number of seconds to wait after seeing a beacon before notifying again.
 *
 *  @param beaconJSON NSDictonary
 *  @param secons     NSTimeInterval
 */
// - (void)listenForBeaconsFromJSONScheme:(NSDictionary *)beaconsWithinJSON notificationInterval:(NSTimeInterval)seconds;

#pragma mark - Stop Listening

/**
 *  Stop listening for beacons with a certian BeaconID (From database)
 *
 *  @param uuid NSUUID
 */

// -(void)stopListeningForBeaconsWithProximityBeaconID:(NSString *)beaconId;

#pragma mark - Notification
/**
 *  Sets the notification interval duration for how often the Listener should update the app about each new beacon found.
 *
 *  @param seconds NSTimeInterval
 */
- (void)setNotificationInterval:(NSTimeInterval)seconds;
@end

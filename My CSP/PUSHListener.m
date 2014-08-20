//  The MIT License (MIT)
//
//  Copyright (c) 2014 Intermark Interactive
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "PUSHListener.h"

// Constant Strings
NSString * const kPUSHBeaconRangeIdentifier = @"com.PUSHBeacon.Region";
NSString * const kPUSHDidFindNotification = @"kPUSHDidFindBeaconNotification";
NSString * const kPUSHBeacon = @"kPUSHBeacon";
NSTimeInterval const kPUSHDefaultTimeInterval = 0;


// Interface
@interface PUSHListener() <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableDictionary *beaconRegions;

// Listening
@property (nonatomic) BOOL isListening;
@property (nonatomic) NSTimeInterval beaconInterval;
@property (nonatomic, strong) NSMutableDictionary *seenBeacons;
@end


// Implementation
@implementation PUSHListener

#pragma mark - Singleton
+ (instancetype)defaultListener {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}


#pragma mark - Init
- (instancetype)init {
    if (self = [super init]) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        self.beaconInterval = kPUSHDefaultTimeInterval;
        self.beaconRegions = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *saveDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"saves.plist"]];
        
        if ([saveDict objectForKey:@"seenBeacons"]){
            self.seenBeacons = saveDict[@"seenBeacons"];
        } else {
            self.seenBeacons = [NSMutableDictionary dictionary];
            [saveDict setObject:self.seenBeacons forKey:@"seenBeacons"];
            [saveDict writeToFile:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"saves.plist"] atomically:YES];
        }
        
        self.campaigns = [[NSMutableArray alloc] init];
    }
    
    return self;
}


#pragma mark - Start/Stop Listening
- (void)listenForBeacons:(NSArray *)beacons {
    // Register for region monitoring
    for (CLBeaconRegion *beaconRegion in beacons) {
        // Create the beacon region tohv be monitored.
        beaconRegion.notifyEntryStateOnDisplay = YES;
        
        // Register the beacon region with the location manager.
        [self.locationManager startMonitoringForRegion:beaconRegion];
        [self.locationManager requestStateForRegion:beaconRegion];
        [self.beaconRegions setObject:beaconRegion forKey:beaconRegion.proximityUUID.UUIDString];
    }
    
    NSLog(@"Started monitoring for %lu regions", (unsigned long)beacons.count);
}

- (void)listenForBeacons:(NSArray *)beacons notificationInterval:(NSTimeInterval)seconds {
    self.beaconInterval = seconds;
    [self listenForBeacons:beacons];
}

- (void)stopListening {
    for (CLBeaconRegion *region in self.beaconRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

- (void)stopListeningForBeaconsWithProximityUUID:(NSUUID *)uuid {
    if (self.beaconRegions[uuid.UUIDString]) {
        [self.locationManager stopMonitoringForRegion:self.beaconRegions[uuid.UUIDString]];
        [self.beaconRegions removeObjectForKey:uuid.UUIDString];
    }
}


#pragma mark - Notifications
- (void)setNotificationInterval:(NSTimeInterval)seconds {
    self.beaconInterval = seconds;
}

- (void)sendNotificationWithRegion:(CLBeaconRegion *)beacon {
    if ([self shouldSendNotificationForRegion:beacon.identifier]) {
        [self addRegionToSeenBeaconsDictionary:beacon];
        
        NSArray *listingsForBeacon = [self.beaconToListing objectForKey:beacon.identifier];
        
        NSString *urlQueryString = @"";
        
        ListingFilter *initialFilter = [[ListingFilter alloc] init];
        [initialFilter setUnitIDS:listingsForBeacon];
        
        NSArray *listings = [initialFilter getSpecific:[(ViewController *)[(ListingTableNavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController viewControllers][0] listings]];
        
        NSLog(@"Filtered campaign Listings");
        
        if (listings.count > 0){
            
            for (Listing *listing in listings){
                
                
                if ([urlQueryString isEqualToString:@""]){
                    urlQueryString = listing.unitID.stringValue;
                } else {
                    urlQueryString = [urlQueryString stringByAppendingString:[NSString stringWithFormat:@",%@", listing.unitID.stringValue]];
                }
            }
            
            
            NSURL *listingURL = [NSURL URLWithString:[NSString stringWithFormat:@"cspmtmg://?listings=%@", urlQueryString]];
            
            NSMutableArray *campaignIDS = [[NSMutableArray alloc] init];
            
            for (NSDictionary *campaign in self.campaigns){
                if ([campaign[@"beaconID"] isEqualToString:beacon.identifier]){
                    [campaignIDS addObject:campaign[@"campaignID"]];
                }
            }
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[campaignIDS, listingURL] forKeys:@[@"campaignIDs", @"targetURL"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"respondToBeacon" object:nil userInfo:userInfo];
            
            // [[NSNotificationCenter defaultCenter] postNotificationName:kPUSHDidFindNotification object:nil userInfo:@{kPUSHBeacon:beacon}];
        }
        
    } else {
        NSLog(@"Don't show notification");
    }
}

- (BOOL)shouldSendNotificationForRegion:(NSString *)beacon {
    if (self.seenBeacons[beacon]) {
        return abs([[NSDate date] timeIntervalSinceDate:self.seenBeacons[beacon]]) >= self.beaconInterval;
    }
    
    return YES;
}

- (void)addRegionToSeenBeaconsDictionary:(CLBeaconRegion *)beacon {
    [self.seenBeacons setObject:[NSDate date] forKey:[beacon identifier]];
    NSString *savePlist = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"saves.plist"];
    NSMutableDictionary *saveDict = [[NSMutableDictionary alloc] initWithContentsOfFile:savePlist];
    [saveDict setObject:self.seenBeacons forKey:@"seenBeacons"];
    [saveDict writeToFile:savePlist atomically:YES];
}


#pragma mark - Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"locationManager didRangeBeacons");
    // Notify for each Beacon found
    
    if (beacons.count > 0){
        
        [self sendNotificationWithRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    NSLog(@"locationManager didDetermineState");
    if ([region isKindOfClass:[CLBeaconRegion class]] && state == CLRegionStateInside) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
    else if ([region isKindOfClass:[CLBeaconRegion class]] && state == CLRegionStateOutside) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

@end

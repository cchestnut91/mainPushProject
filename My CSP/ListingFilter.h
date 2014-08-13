//
//  Filter.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/9/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Listing.h"

// Object used to filter through an array of Listings using search preferences
// Conforms to NSCoding protocol
@interface ListingFilter : NSObject <NSCoding>


// Stores Bools as NSNumbers
@property (strong, nonatomic) NSNumber *favorite;
@property (strong, nonatomic) NSNumber *images;
@property (strong, nonatomic) NSNumber *checkLocation;
@property (strong, nonatomic) NSNumber *cable;
@property (strong, nonatomic) NSNumber *hardWood;
@property (strong, nonatomic) NSNumber *fridge;
@property (strong, nonatomic) NSNumber *laundry;
@property (strong, nonatomic) NSNumber *oven;
@property (strong, nonatomic) NSNumber *air;
@property (strong, nonatomic) NSNumber *balcony;
@property (strong, nonatomic) NSNumber *carport;
@property (strong, nonatomic) NSNumber *dish;
@property (strong, nonatomic) NSNumber *fence;
@property (strong, nonatomic) NSNumber *fire;
@property (strong, nonatomic) NSNumber *garage;
@property (strong, nonatomic) NSNumber *internet;
@property (strong, nonatomic) NSNumber *microwave;
@property (strong, nonatomic) NSNumber *closet;

// Non bool criteria
@property (strong, nonatomic) NSNumber *beds;
@property (strong, nonatomic) NSNumber *baths;
@property (strong, nonatomic) NSString *month;
@property (strong, nonatomic) NSString *year;
@property (strong, nonatomic) NSArray *keyWords;
@property (strong, nonatomic) NSArray *unitIDS;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSDate *available;

@property (nonatomic) float lowRent;
@property (nonatomic) float highRent;

// Used to specify how many meters is 'nearby'
@property (nonatomic) float range;

// Initializes an empty filter
-(id)init;

// Attempts to load User prefered filter settings
-(id)initWithDefault;

// Take in an array of Listings and return the ones which pass the filter
-(NSArray *)filterListings:(NSArray *)listings;

// Takes in an array of listings and returns only ones which have UnitIDS stored in self.unitIDS
-(NSArray *)getSpecific:(NSArray *)listings;

// Returns array with current status of all bool checks
-(NSMutableArray *)getAmenities;

// NSCoding methods
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

@end

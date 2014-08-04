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

@interface ListingFilter : NSObject <NSCoding>

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
@property (nonatomic) float lowRent;
@property (nonatomic) float highRent;
@property (nonatomic) float range;
@property (strong, nonatomic) NSNumber *beds;
@property (strong, nonatomic) NSNumber *baths;
@property (strong, nonatomic) NSArray *keyWords;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSDate *available;

-(id)init;
-(id)initWithDefault;
-(NSArray *)filterListings:(NSArray *)listings;
-(void)sing;
-(NSMutableArray *)getAmenities;

-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

@end

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

@interface ListingFilter : NSObject

@property (nonatomic) BOOL favorite;
@property (nonatomic) BOOL images;
@property (nonatomic) BOOL checkLocation;
@property (nonatomic) BOOL cable;
@property (nonatomic) BOOL hardWood;
@property (nonatomic) BOOL fridge;
@property (nonatomic) BOOL laundry;
@property (nonatomic) BOOL oven;
@property (nonatomic) BOOL air;
@property (nonatomic) BOOL balcony;
@property (nonatomic) BOOL carport;
@property (nonatomic) BOOL dish;
@property (nonatomic) BOOL fence;
@property (nonatomic) BOOL fire;
@property (nonatomic) BOOL garage;
@property (nonatomic) BOOL internet;
@property (nonatomic) BOOL microwave;
@property (nonatomic) BOOL closet;
@property (nonatomic) float lowRent;
@property (nonatomic) float highRent;
@property (nonatomic) float range;
@property (strong, nonatomic) NSNumber *beds;
@property (strong, nonatomic) NSNumber *baths;
@property (strong, nonatomic) NSArray *keyWords;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSDate *available;

-(id)init;
-(NSArray *)filterListings:(NSArray *)listings;

@end

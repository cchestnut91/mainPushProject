//
//  Listing.h
//  My CSP
//
//  Created by Calvin Chestnut on 6/10/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "Property.h"

@interface Listing : NSObject <
    NSCoding
>

// Listing Info
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *addressShort;
@property (strong, nonatomic) NSString *town;
@property (strong, nonatomic) NSString *tourURL;
@property (strong, nonatomic) NSString *descrip;
@property (strong, nonatomic) NSString *heat;
@property (strong, nonatomic) NSNumber *beds;
@property (strong, nonatomic) NSNumber *baths;
@property (strong, nonatomic) NSNumber *sqft;
@property (strong, nonatomic) NSNumber *rent;
@property (strong, nonatomic) NSNumber *unitID;
@property (strong, nonatomic) NSDate *available;
@property (strong, nonatomic) NSArray *imageSrc;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) Property *property;

@property BOOL favorite;

// Amenity Info
@property BOOL cable;
@property BOOL hardwood;
@property BOOL refrigerator;
@property BOOL laundry;
@property BOOL oven;
@property BOOL virtualTour;
@property BOOL airConditioning;
@property BOOL balcony;
@property BOOL carport;
@property BOOL dishwasher;
@property BOOL fenced;
@property BOOL fireplace;
@property BOOL garage;
@property BOOL internet;
@property BOOL microwave;
@property BOOL walkCloset;

// List dates
@property (strong, nonatomic) NSDate *start;
@property (strong, nonatomic) NSDate *stop;

// Default Init
-(id)initWithDictionary:(NSDictionary *)infoIn;

// Allows Listings to be saved and loaded from local storage
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

// Returns amenities which this Property features as a dictionary
-(NSDictionary *)features;

// Takes in an ImageURL and loads the image
-(void)loadFirstImage:(NSString *)srcIn;

// Determines if the Listing should be displayed using the ListDate and EndListDate
- (BOOL)isNowBetweenDate:(NSDate *)earlierDate andDate:(NSDate *)laterDate;

@end

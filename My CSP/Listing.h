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

@interface Listing : NSObject <NSCoding>

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSNumber *beds;
@property (strong, nonatomic) NSNumber *baths;
@property (strong, nonatomic) NSNumber *sqft;
@property (strong, nonatomic) NSNumber *rent;
@property (strong, nonatomic) NSNumber *buildiumID;
@property (strong, nonatomic) NSNumber *unitID;
@property (strong, nonatomic) NSString *descrip;
@property (strong, nonatomic) NSDate *available;
@property (strong, nonatomic) NSMutableArray *imageArray;
@property (strong, nonatomic) NSArray *imageSrc;
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSTimer *timeout;

/*
 heat
 One of four values
 0 - No Info
 1 - Electric
 2 - Gas
 3 - Oil
 NSNumber or NSString?
 */
@property (strong, nonatomic) NSString *heat;

@property BOOL favorite;

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

@property (strong, nonatomic) NSDate *start;
@property (strong, nonatomic) NSDate *stop;

-(id)initWithDictionary:(NSDictionary *)infoIn;

-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

-(NSDictionary *)exportAsDictionary;

-(NSDictionary *)features;

- (BOOL)isDate:(NSDate *)first betweenDate:(NSDate *)earlierDate andDate:(NSDate *)laterDate;

@end

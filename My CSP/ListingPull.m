//
//  ListingPull.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/8/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "ListingPull.h"

@implementation ListingPull

// Performs REST call to get Listings for CSP and returns those in an array
-(NSArray *)getListings{

    // Initializes  new mutable array
    NSMutableArray *listings = [[NSMutableArray alloc] init];
    
    // Gets Listing data as an array of JSON Dictionaries from a syncronous REST call
    NSArray *data = [[RESTfulInterface RESTAPI]getAllListings];
    
    NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
    
    // Steps through each JSON Dictionary
    for (NSMutableDictionary *dict in data){
        
        [dict setObject:props forKey:@"properties"];
        
        // Passes the Dictionary to a new Listing object
        Listing *new = [[Listing alloc] initWithDictionary:dict];
        
        // Adds the Listing object to the array to be returned
        [listings addObject:new];
    }
    
    NSLog(@"Downloaded %d Listings", listings.count);

    // Returns the array of Listings
    return listings;
}

@end

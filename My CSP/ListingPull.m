//
//  ListingPull.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/8/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "ListingPull.h"

@implementation ListingPull

-(NSArray *)getListings{

    NSMutableArray *listings = [[NSMutableArray alloc] init];
    NSArray *data = [[RESTfulInterface RESTAPI]getAllListings];
    for (int i = 0; i < data.count; i++){
        Listing *new = [[Listing alloc] initWithDictionary:[data objectAtIndex:i]];
        [listings addObject:new];
    }

    return [NSArray arrayWithArray:listings];
}

@end

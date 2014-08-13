//
//  ListingPull.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/8/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Listing.h"
#import "RESTfulInterface.h"

@interface ListingPull : NSObject

// Returns array of all listings
-(NSArray *)getListings;

@end

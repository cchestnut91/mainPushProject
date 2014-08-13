//
//  Filter.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/9/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "ListingFilter.h"

@implementation ListingFilter

// Initializes an empty filter
-(id)init{
    self = [super init];
    
    // All values are set to default
    // Bools are set to no
    self.favorite = [NSNumber numberWithBool:NO];
    self.images = [NSNumber numberWithBool:NO];
    self.checkLocation = [NSNumber numberWithBool:NO];
    self.cable = [NSNumber numberWithBool:NO];
    self.hardWood = [NSNumber numberWithBool:NO];
    self.fridge = [NSNumber numberWithBool:NO];
    self.laundry = [NSNumber numberWithBool:NO];
    self.oven = [NSNumber numberWithBool:NO];
    self.air = [NSNumber numberWithBool:NO];
    self.balcony = [NSNumber numberWithBool:NO];
    self.carport = [NSNumber numberWithBool:NO];
    self.dish = [NSNumber numberWithBool:NO];
    self.fence = [NSNumber numberWithBool:NO];
    self.fire = [NSNumber numberWithBool:NO];
    self.garage = [NSNumber numberWithBool:NO];
    self.internet = [NSNumber numberWithBool:NO];
    self.microwave = [NSNumber numberWithBool:NO];
    self.closet = [NSNumber numberWithBool:NO];
    
    // Near is 200 meters
    self.range = 200;
    
    // Beds and Baths are 0 or more
    self.beds = 0;
    self.baths = 0;
    
    // Nothing set for month or year
    self.month = nil;
    self.year = nil;
    
    return self;
}

// Attempts to load default filter from saved file
-(id)initWithDefault{
    self = [super init];
    
    // Default save location for Filter File
    NSString *filterFile = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"savedFiler"];
    
    // If saved filter exits
    if ([[NSFileManager defaultManager] fileExistsAtPath:filterFile]){
        
        // Unarchive that data using the NSCoding Init method below
        self = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:filterFile]];
    } else {
        
        // Otherwise initialize empty filter
        self = [self init];
    }
    
    
    // Return self
    return self;
}


// Filters for a set of specific listings
// self.unitIDS must be set or nothing will be returned
-(NSArray *)getSpecific:(NSArray *)listings{
    
    // Creates array to return
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    
    // Step through each listing
    for (Listing *listing in listings){
        
        // Check to see if Listing unitID is in the list of IDS to be checked for
        if ([self.unitIDS containsObject:listing.unitID.stringValue]){
            
            // If so, add that to the return array
            [ret addObject:listing];
            
            // If as many Listings as needed have been found
            if (ret.count == self.unitIDS.count){
                
                // Break out of the loop
                break;
            }
        }
    }
    
    // Return Listings
    return ret;
}


// Runs listings through a filter and returns array of Listings which have passed
-(NSArray *)filterListings:(NSArray *)listings{
    
    // Creates array to be returned
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    
    // Step through each Listing in the array
    for (Listing *check in listings){
        
        // Listings pass unless determined otherwise
        BOOL pass = YES;
        
        // If current date is not between ListDate and StopListDate don't pass
        if (pass && ![check isNowBetweenDate:check.start andDate:check.stop]){
            pass = NO;
            break;
        }
        
        // Will not check other options if it has already failed to pass
        // If filter by year is set
        if (pass && self.year){
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy"];
            // Year Listing goes available
            NSString *y = [formatter stringFromDate:check.available];
            
            // If desired year is before the year listing goes available, don't pass
            if (!(y.intValue <= self.year.intValue)){
                pass = NO;
                break;
            }
        }
        
        // if filter by month is set
        if (pass && self.month){
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"M"];
            
            // Month listing goes available
            NSString *m = [formatter stringFromDate:check.available];
            
            [formatter setDateFormat:@"yyyy"];
            // Year Listing goes available
            NSString *y = [formatter stringFromDate:check.available];
            
            // Only fails if desired month is not equal to the available month AND
            // listing year is not before desired year
            // Honestly, I'm not sure about this bool statement, but it seems to work!
            if (![m isEqualToString:self.month] && !(y.intValue < self.year.intValue)){
                pass = NO;
                break;
            }
        }
        
        // If lowRent is set and Listing rent is not less than lowRent
        if (pass && self.lowRent != 0 && self.lowRent > check.rent.floatValue){
            pass = NO;
            break;
        }
        
        // If highRent is set and Listing rent is not more than highRent
        if (pass && self.highRent != 0 && self.highRent < check.rent.floatValue){
            pass = NO;
            break;
        }
        
        // If filter should check for current location
        if (pass && self.checkLocation.boolValue){
            
            // If user's current location is not within range of Listing's location
            if ([self.location distanceFromLocation:check.location] > self.range){
                pass = NO;
                break;
            }
        }
        
        // If desired number of beds is more than Listing's num beds
        if (pass && self.beds.intValue > check.beds.intValue){
            pass = NO;
            break;
        }
        // If desired number of baths is more than Listing's num baths
        if (pass && check.baths.intValue < self.baths.intValue){
            pass = NO;
            break;
        }
        
        // If filter should only return Listing's with Images
        if (pass && self.images.boolValue){
            
            // If Listing has no images
            if ([check imageSrc].count == 0){
                pass = NO;
                break;
            }
        }
        
        // Simple Bool checks
        if (pass && self.favorite.boolValue && !check.favorite){
            pass = NO;
            break;
        }
        if (pass && self.cable.boolValue && !check.cable){
            pass = NO;
            break;
        }
        if (pass && self.hardWood.boolValue && !check.hardwood){
            pass = NO;
            break;
        }
        if (pass && self.fridge.boolValue && !check.refrigerator){
            pass = NO;
            break;
        }
        if (pass && self.laundry.boolValue && !check.laundry){
            pass = NO;
            break;
        }
        if (pass && self.oven.boolValue && !check.oven){
            pass = NO;
            break;
        }
        if (pass && self.air.boolValue && !check.airConditioning){
            pass = NO;
            break;
        }
        if (pass && self.balcony.boolValue && !check.balcony){
            pass = NO;
            break;
        }
        if (pass && self.carport.boolValue && !check.carport){
            pass = NO;
            break;
        }
        if (pass && self.dish.boolValue && !check.dishwasher){
            pass = NO;
            break;
        }
        if (pass && self.fence.boolValue && !check.fenced){
            pass = NO;
            break;
        }
        if (pass && self.fire.boolValue && !check.fireplace){
            pass = NO;
            break;
        }
        if (pass && self.garage.boolValue && !check.garage){
            pass = NO;
            break;
        }
        if (pass && self.internet.boolValue && !check.internet){
            pass = NO;
            break;
        }
        if (pass && self.microwave.boolValue && !check.microwave){
            pass = NO;
            break;
        }
        if (pass && self.closet.boolValue && !check.walkCloset){
            pass = NO;
            break;
        }
        
        // If array of Keywords is not null
        // Will return true if ANY keywords are found in the Listing
        if (pass && self.keyWords){
            
            // Initial bool to be changed if keywords are found
            BOOL found = NO;
            
            // For each keyword in the array
            for (NSString *keyWord in self.keyWords){
                
                // If keyword is not an empty string
                if (![keyWord isEqualToString:@" "]){
                    
                    // If the listing address contains any of the keywords
                    if ([check.address.lowercaseString rangeOfString:[keyWord lowercaseString]].location != NSNotFound){
                        found = YES;
                        break;
                    }
                    // Else if the listing description contains any of the keywords
                    else if ([check.descrip.lowercaseString rangeOfString:[keyWord lowercaseString]].location != NSNotFound){
                        found = YES;
                        break;
                    }
                }
            }
            
            // If no keywords were found do not pass filter
            if (!found){
                pass = NO;
                break;
            }
            
        }
        
        // If listing has passed through the filter, add to the ret array
        if (pass){
            [ret addObject:check];
        }
    }
    
    return ret;
}


// Returns array of search preferences for amenities
-(NSMutableArray *)getAmenities{
    
    return [NSMutableArray  arrayWithObjects:self.checkLocation, self.favorite, self.images, self.cable, self.hardWood, self.fridge, self.laundry, self.oven, self.air, self.balcony, self.carport, self.dish, self.fence, self.fire, self.garage, self.internet, self.microwave, self.closet, nil];
    
}

#pragma mark-NSCoding methods

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.favorite forKey:@"favorites"];
    [aCoder encodeObject:self.images forKey:@"images"];
    [aCoder encodeObject:self.checkLocation forKey:@"checkLocation"];
    [aCoder encodeObject:self.cable forKey:@"cable"];
    [aCoder encodeObject:self.hardWood forKey:@"hardwood"];
    [aCoder encodeObject:self.fridge forKey:@"fridge"];
    [aCoder encodeObject:self.laundry forKey:@"laundry"];
    [aCoder encodeObject:self.oven forKey:@"oven"];
    [aCoder encodeObject:self.air forKey:@"air"];
    [aCoder encodeObject:self.balcony forKey:@"balcony"];
    [aCoder encodeObject:self.carport forKey:@"carport"];
    [aCoder encodeObject:self.dish forKey:@"dish"];
    [aCoder encodeObject:self.fence forKey:@"fence"];
    [aCoder encodeObject:self.fire forKey:@"fire"];
    [aCoder encodeObject:self.garage forKey:@"garage"];
    [aCoder encodeObject:self.internet forKey:@"internet"];
    [aCoder encodeObject:self.microwave forKey:@"microwave"];
    [aCoder encodeObject:self.closet forKey:@"closet"];
    [aCoder encodeObject:self.beds forKey:@"beds"];
    [aCoder encodeObject:self.baths forKey:@"baths"];
    [aCoder encodeObject:self.month forKey:@"month"];
    [aCoder encodeObject:self.year forKey:@"year"];
    [aCoder encodeObject:self.keyWords forKey:@"keywords"];
    [aCoder encodeObject:self.available forKey:@"available"];
    [aCoder encodeFloat:self.lowRent forKey:@"lowRent"];
    [aCoder encodeFloat:self.highRent forKey:@"highRent"];
    [aCoder encodeFloat:self.range forKey:@"range"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    self.favorite = [aDecoder decodeObjectForKey:@"favorites"];
    self.images = [aDecoder decodeObjectForKey:@"images"];
    self.checkLocation = [aDecoder decodeObjectForKey:@"checkLocation"];
    self.cable = [aDecoder decodeObjectForKey:@"cable"];
    self.hardWood = [aDecoder decodeObjectForKey:@"hardwood"];
    self.fridge = [aDecoder decodeObjectForKey:@"fridge"];
    self.laundry = [aDecoder decodeObjectForKey:@"laundry"];
    self.oven = [aDecoder decodeObjectForKey:@"oven"];
    self.air = [aDecoder decodeObjectForKey:@"air"];
    self.carport = [aDecoder decodeObjectForKey:@"carport"];
    self.dish = [aDecoder decodeObjectForKey:@"dish"];
    self.fence = [aDecoder decodeObjectForKey:@"fence"];
    self.fire = [aDecoder decodeObjectForKey:@"fire"];
    self.garage = [aDecoder decodeObjectForKey:@"garage"];
    self.internet = [aDecoder decodeObjectForKey:@"internet"];
    self.microwave = [aDecoder decodeObjectForKey:@"microwave"];
    self.closet = [aDecoder decodeObjectForKey:@"closet"];
    self.beds = [aDecoder decodeObjectForKey:@"beds"];
    self.baths = [aDecoder decodeObjectForKey:@"baths"];
    self.keyWords = [aDecoder decodeObjectForKey:@"keywords"];
    self.available = [aDecoder decodeObjectForKey:@"available"];
    self.balcony = [aDecoder decodeObjectForKey:@"balcony"];
    self.month = [aDecoder decodeObjectForKey:@"month"];
    self.year = [aDecoder decodeObjectForKey:@"year"];
    
    self.lowRent = [aDecoder decodeFloatForKey:@"lowRent"];
    self.highRent = [aDecoder decodeFloatForKey:@"highRent"];
    self.range = [aDecoder decodeFloatForKey:@"range"];
    
    return self;
    
}

@end

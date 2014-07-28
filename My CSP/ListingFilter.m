//
//  Filter.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/9/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "ListingFilter.h"

@implementation ListingFilter

-(id)init{
    self = [super init];
    
    self.favorite = NO;
    self.images = NO;
    self.checkLocation = NO;
    self.cable = NO;
    self.hardWood = NO;
    self.fridge = NO;
    self.laundry = NO;
    self.oven = NO;
    self.air = NO;
    self.balcony = NO;
    self.carport = NO;
    self.dish = NO;
    self.fence = NO;
    self.fire = NO;
    self.garage = NO;
    self.internet = NO;
    self.microwave = NO;
    self.closet = NO;
    self.range = 200;
    self.beds = 0;
    self.baths = 0;
    
    return self;
}

- (BOOL)isDate:(NSDate *)first betweenDate:(NSDate *)earlierDate andDate:(NSDate *)laterDate
{
    // first check that we are later than the earlierDate.
    if ([first compare:earlierDate] == NSOrderedDescending) {
        
        // next check that we are earlier than the laterData
        if ( [first compare:laterDate] == NSOrderedAscending ) {
            return YES;
        }
    }
    
    // otherwise we are not
    return NO;
}

-(NSArray *)filterListings:(NSArray *)listings{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (int i = 0; i < listings.count; i++){
        BOOL pass = YES;
        Listing *check = [listings objectAtIndex:i];
        NSDate *now = [[NSDate alloc] init];
        if (![self isDate:now betweenDate:check.start andDate:check.stop]){
            pass = NO;
        }
        if (self.lowRent != 0 && self.lowRent > check.rent.floatValue){
            pass = NO;
        }
        if (self.highRent != 0 && self.highRent < check.rent.floatValue){
            pass = NO;
        }
        if (self.favorite && !check.favorite){
            pass = NO;
        }
        if (self.checkLocation){
            if ([self.location distanceFromLocation:check.location] > self.range){
                pass = NO;
            }
        }
        if (check.beds < self.beds){
            pass = NO;
        }
        if (check.baths < self.baths){
            pass = NO;
        }
        if (self.images){
            if ([check imageSrc].count != 0){
                pass = NO;
            }
        }
        if (self.cable && check.cable){
            pass = NO;
        }
        if (self.hardWood && check.hardwood){
            pass = NO;
        }
        if (self.fridge && check.refrigerator){
            pass = NO;
        }
        if (self.laundry && check.laundry){
            pass = NO;
        }
        if (self.oven && check.oven){
            pass = NO;
        }
        if (self.air && check.airConditioning){
            pass = NO;
        }
        if (self.balcony && check.balcony){
            pass = NO;
        }
        if (self.carport && check.carport){
            pass = NO;
        }
        if (self.dish && check.dishwasher){
            pass = NO;
        }
        if (self.fence && check.fenced){
            pass = NO;
        }
        if (self.fire && check.fireplace){
            pass = NO;
        }
        if (self.garage && check.garage){
            pass = NO;
        }
        if (self.internet && check.internet){
            pass = NO;
        }
        if (self.microwave && check.microwave){
            pass = NO;
        }
        if (self.closet && check.walkCloset){
            pass = NO;
        }
        if (self.keyWords){
            BOOL found = NO;
            for (int j = 0; j < self.keyWords.count; j++){
                if (![[self.keyWords objectAtIndex:j] isEqualToString:@" "]){
                    if ([check.address.lowercaseString containsString:[[self.keyWords objectAtIndex:j] lowercaseString]]){
                        found = YES;
                        break;
                    } else if ([check.descrip.lowercaseString containsString:[[self.keyWords objectAtIndex:j] lowercaseString]]){
                        found = YES;
                        break;
                    }
                }
            }
            if (!found){
                pass = NO;
            }
            
        }
        if (pass){
            [ret addObject:check];
        }
    }
    
    return [NSArray arrayWithArray:ret];
}

@end

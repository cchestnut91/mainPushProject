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
    self.range = 200;
    self.beds = 0;
    self.baths = 0;
    
    return self;
}

-(id)initWithDefault{
    self = [super init];
    
    NSString *filterFile = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"savedFiler"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filterFile]){
        
        self = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:filterFile]];
    } else {
        self = [self init];
    }
    
    return self;
}

-(NSArray *)filterListings:(NSArray *)listings{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (int i = 0; i < listings.count; i++){
        BOOL pass = YES;
        Listing *check = [listings objectAtIndex:i];
        NSDate *now = [[NSDate alloc] init];
        if (pass && ![check isDate:now betweenDate:check.start andDate:check.stop]){
            pass = NO;
        }
        if (pass && self.lowRent != 0 && self.lowRent > check.rent.floatValue){
            pass = NO;
        }
        if (pass && self.highRent != 0 && self.highRent < check.rent.floatValue){
            pass = NO;
        }
        if (pass && self.favorite.boolValue && !check.favorite){
            pass = NO;
        }
        if (pass && self.checkLocation.boolValue){
            if ([self.location distanceFromLocation:check.location] > self.range){
                pass = NO;
            }
        }
        if (pass && self.beds.intValue > check.beds.intValue){
            pass = NO;
        }
        if (pass && check.baths.intValue < self.baths.intValue){
            pass = NO;
        }
        if (pass && self.images.boolValue){
            if ([check imageSrc].count == 0){
                pass = NO;
            }
        }
        if (pass && self.cable.boolValue && !check.cable){
            pass = NO;
        }
        if (pass && self.hardWood.boolValue && !check.hardwood){
            pass = NO;
        }
        if (pass && self.fridge.boolValue && !check.refrigerator){
            pass = NO;
        }
        if (pass && self.laundry.boolValue && !check.laundry){
            pass = NO;
        }
        if (pass && self.oven.boolValue && !check.oven){
            pass = NO;
        }
        if (pass && self.air.boolValue && !check.airConditioning){
            pass = NO;
        }
        if (pass && self.balcony.boolValue && !check.balcony){
            pass = NO;
        }
        if (pass && self.carport.boolValue && !check.carport){
            pass = NO;
        }
        if (pass && self.dish.boolValue && !check.dishwasher){
            pass = NO;
        }
        if (pass && self.fence.boolValue && !check.fenced){
            pass = NO;
        }
        if (pass && self.fire.boolValue && !check.fireplace){
            pass = NO;
        }
        if (pass && self.garage.boolValue && !check.garage){
            pass = NO;
        }
        if (pass && self.internet.boolValue && !check.internet){
            pass = NO;
        }
        if (pass && self.microwave.boolValue && !check.microwave){
            pass = NO;
        }
        if (pass && self.closet.boolValue && !check.walkCloset){
            pass = NO;
        }
        if (pass && self.keyWords){
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

-(NSMutableArray *)getAmenities{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    //[ret addObject:self.favorite];
    ret = [NSMutableArray arrayWithObjects:self.checkLocation, self.favorite, self.images, self.cable, self.hardWood, self.fridge, self.laundry, self.oven, self.air, self.balcony, self.carport, self.dish, self.fence, self.fire, self.garage, self.internet, self.microwave, self.closet, nil];
    return ret;
}

-(void)sing{
    if (self.favorite.boolValue){
        NSLog(@"Favorite");
    }
    if (self.images.boolValue){
        NSLog(@"Images");
    }
    if (self.checkLocation.boolValue){
        NSLog(@"Location");
    }
    if (self.cable.boolValue){
        NSLog(@"Cable");
    }
    if (self.laundry.boolValue){
        NSLog(@"Laundry");
    }
    if (self.oven.boolValue){
        NSLog(@"Oven");
    }
    if (self.air.boolValue){
        NSLog(@"Air");
    }
    if (self.balcony.boolValue){
        NSLog(@"Balcony");
    }
    if (self.carport.boolValue){
        NSLog(@"Carport");
    }
    if (self.dish.boolValue){
        NSLog(@"Dishwasher");
    }
    if (self.fence.boolValue){
        NSLog(@"Fenced");
    }
    if (self.fire.boolValue){
        NSLog(@"Fireplace");
    }
    if (self.garage.boolValue){
        NSLog(@"Garage");
    }
    if (self.internet.boolValue){
        NSLog(@"Internet");
    }
    if (self.hardWood.boolValue){
        NSLog(@"Hardwood");
    }
    if (self.microwave.boolValue){
        NSLog(@"Microwave");
    }
    if (self.closet.boolValue){
        NSLog(@"Closet");
    }
    if (self.fridge.boolValue){
        NSLog(@"Fridge");
    }
    NSLog(@"Low: %.0f", self.lowRent);
    NSLog(@"High: %.0f", self.highRent);
    NSLog(@"Beds: %d", self.beds.intValue);
    NSLog(@"Bath: %d", self.baths.intValue);
    
}

- (NSString *)description {
    return @"MyCustomDescription";
}

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
    
    self.lowRent = [aDecoder decodeFloatForKey:@"lowRent"];
    self.highRent = [aDecoder decodeFloatForKey:@"highRent"];
    self.range = [aDecoder decodeFloatForKey:@"range"];
    
    return self;
    
}

@end

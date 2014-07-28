//
//  Listing.m
//  My CSP
//
//  Created by Calvin Chestnut on 6/10/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "Listing.h"

@implementation Listing

dispatch_queue_t imageQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.push.mycsp.imagethread", 0);
    });
    return queue;
}

/*
 Listing - initWithDictionary:(NSDictionary *)infoIn
 Rest service should download information about listing from Push server
 Using minimal logic, service should compile an NSDictionary with JSON data
 Format of infoIn as follows
 
 infoIn - NSDictionary
    key                 type
    @"address"          NSString
        Note:   Street/apartment unit only. Town not needed for current scope.
 
    @"available"        NSString
        Note:   Could be an NSDate, but formatter currently present
                Format as MMMM d Y, ex. "June 3 2014"
 
    @"description"      NSString
    @"beds"             NSNumber
    @"baths"            NSNumber
    @"sqft"             NSNumber
    @"rent"             NSNumber
    @"heat"             NSNumber
        Note:   Read comment in Listing.h
 
        Note:   The rest are BOOL values, which cannot be stored in NSDictionary. Use NSNumber instead
                Any value where first digit != 0 evaluates to YES
    @"airConditioning"  NSNumber
    @"balcony"          NSNumber
    @"cable"            NSNumber
    @"carport"          NSNumber
    @"dishwasher"       NSNumber
    @"fenced"           NSNumber
    @"fireplace"        NSNumber
    @"garage"           NSNumber
    @"hardwood"         NSNumber
    @"internet"         NSNumber
    @"laundry"          NSNumber
    @"microwave"        NSNumber
    @"oven"             NSNumber
    @"refrigerator"     NSNumber
    @"virtualTour"      NSNumber
        Note:   Currently app does not handle Virtual Tours.
                This could link to the website, or launch an in-app virtual tour
 
    @"walkCloset"       NSNumber
    @"favorite"         NSNumber
        Note:   Server side logic would need to determine if user account != annonymous and return appropriate favorite tag
                Otherwise favorite returns NO
*/
-(id)initWithDictionary:(NSDictionary *)infoIn{
    
    self = [super init];
    
    self.address = infoIn[@"address"];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:[NSString stringWithFormat:@"%@, Ithaca, United States",self.address] completionHandler:^(NSArray* placemarks, NSError* error){
        if (!error){
            self.location = [(CLPlacemark *)[placemarks lastObject] location];
        }
    }];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [infoIn[@"available"] componentsSeparatedByString:@"T"][0];
    self.available = [formatter dateFromString:date];
    date = [infoIn[@"listDate"] componentsSeparatedByString:@"T"][0];
    self.start = [formatter dateFromString:date];
    date = [infoIn[@"unavailable"] componentsSeparatedByString:@"T"][0];
    self.stop = [formatter dateFromString:date];
    
    self.imageArray = [[NSMutableArray alloc] init];
    //self.imageSrc = [[NSArray alloc] initWithObjects:@"https://manager-prod.s3.amazonaws.com/Documents/29702/f6f99c88bc224126ac45f12f25b92d43.jpg", @"https://manager-prod.s3.amazonaws.com/Documents/29702/cc49340379374ddb97d6cdce9d5492b1.jpg", @"https://manager-prod.s3.amazonaws.com/Documents/29702/60d2ded3f7f642419aa385357af663e4.jpg", @"https://manager-prod.s3.amazonaws.com/Documents/29702/d42cb9688b2a4a93b79670083ba1cd6b.jpg", nil];
    if (![infoIn[@"listingsImage"] isKindOfClass:[NSNull class]]){
        self.imageSrc = [[NSArray alloc] initWithObjects:infoIn[@"listingsImage"], nil];
    } else {
        self.imageSrc = [[NSArray alloc] init];
    }
    
    if (self.imageSrc.count > 0){
        dispatch_async(imageQueue(), ^{
            NSDate *methodStart = [NSDate date];
            NSLog(@"%@",methodStart);
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:[self.imageSrc objectAtIndex:0]]];
            [self.imageArray addObject:[UIImage imageWithData:imageData]];
            
            NSDate *methodFinish = [NSDate date];
            NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
            NSLog(@"executionTime = %f", executionTime);
        });
    }
    
    if ([infoIn[@"description"] isKindOfClass:[NSString class]]){
        self.descrip = infoIn[@"description"];
        if ([self.descrip containsString:@"To view the virtual tour"]){
            self.descrip = [NSString stringWithFormat:@"%@%@", [self.descrip componentsSeparatedByString:@"To view the virtual"][0], [self.descrip componentsSeparatedByString:@">"][2]];
        }
    } else {
        self.descrip = @"No Description Available";
    }
    if ([infoIn[@"beds"] isKindOfClass:[NSNull class]]){
        self.beds = [NSNumber numberWithInt:0];
    } else {
        self.beds = [NSNumber numberWithInt:[infoIn[@"beds"] intValue]];
    }
    if ([infoIn[@"baths"] isKindOfClass:[NSNull class]]){
        self.baths = [NSNumber numberWithInt:0];
    } else {
        self.baths = [NSNumber numberWithInt:[infoIn[@"baths"] intValue]];
    }
    if ([infoIn[@"sqft"] isKindOfClass:[NSNull class]]){
        self.sqft = [NSNumber numberWithInt:0];
    } else {
        self.sqft = [NSNumber numberWithInt:[infoIn[@"sqft"] intValue]];
    }
    if ([infoIn[@"rent"] isKindOfClass:[NSNull class]]){
        self.rent = [NSNumber numberWithInt:0];
    } else {
        self.rent = [NSNumber numberWithInt:[infoIn[@"rent"] intValue]];
    }
    if ([infoIn[@"buildiumID"] isKindOfClass:[NSNull class]]){
        self.buildiumID = [NSNumber numberWithInt:0];
    } else {
        self.buildiumID = [NSNumber numberWithInt:[infoIn[@"buildiumID"] intValue]];
    }
    
    self.heat = infoIn[@"heat"];
    
    self.airConditioning = NO;
    self.balcony = NO;
    self.cable = NO;
    self.carport = NO;
    self.dishwasher = NO;
    self.fenced = NO;
    self.fireplace = NO;
    self.garage = NO;
    self.hardwood = NO;
    self.internet = NO;
    self.laundry = NO;
    self.microwave = NO;
    self.oven = NO;
    self.refrigerator = NO;
    self.virtualTour = NO;
    self.walkCloset = NO;
    
    if (![self checkIfNull:infoIn[@"airContioning"]]){
        if ([infoIn[@"airConditioning"] isKindOfClass:[NSString class]]){
            self.airConditioning = YES;
        }
    }
    if (![self checkIfNull:infoIn[@"balcony"]]){
        self.balcony = YES;
    }
    if (![self checkIfNull:infoIn[@"cable"]]){
        self.cable = YES;
    }
    if (![self checkIfNull:infoIn[@"carport"]]){
        self.carport = YES;
    }
    if (![self checkIfNull:infoIn[@"dishwasher"]]){
        self.dishwasher = YES;
    }
    if (![self checkIfNull:infoIn[@"fenced"]]){
        self.fenced = YES;
    }
    if (![self checkIfNull:infoIn[@"fireplace"]]){
        self.fireplace = YES;
    }
    if (![self checkIfNull:infoIn[@"garage"]]){
        self.garage = YES;
    }
    if (![self checkIfNull:infoIn[@"hardwood"]]){
        self.hardwood = YES;
    }
    if (![self checkIfNull:infoIn[@"internet"]]){
        self.internet = YES;
    }
    if (![self checkIfNull:infoIn[@"laundry"]]){
        self.laundry = YES;
    }
    if (![self checkIfNull:infoIn[@"microwave"]]){
        self.microwave = YES;
    }
    if (![self checkIfNull:infoIn[@"oven"]]){
        self.oven = YES;
    }
    if (![self checkIfNull:infoIn[@"refrigerator"]]){
        self.refrigerator = YES;
    }
    if (![self checkIfNull:infoIn[@"virtualTour"]]){
        self.virtualTour = YES;
    }
    if (![self checkIfNull:infoIn[@"walkCloset"]]){
        self.walkCloset = YES;
    }
    
    //self.favorite = [(NSNumber *)infoIn[@"favorite"] boolValue];
    
    return self;
}

-(BOOL)checkIfNull:(id)objectIn{
    if ([objectIn isKindOfClass:[NSNull class]]){
        return YES;
    }
    return NO;
}

-(NSDictionary *)exportAsDictionary{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d Y"];
    
    NSMutableDictionary *listingDict = [[NSMutableDictionary alloc] init];
    
    [listingDict setObject:self.address forKey:@"address"];
    [listingDict setObject:[formatter stringFromDate:self.available] forKey:@"available"];
    [listingDict setObject:self.descrip forKey:@"description"];
    [listingDict setObject:self.beds forKey:@"beds"];
    [listingDict setObject:self.baths forKey:@"baths"];
    [listingDict setObject:self.sqft forKey:@"sqft"];
    [listingDict setObject:self.rent forKey:@"rent"];
    [listingDict setObject:self.heat forKey:@"heat"];
    [listingDict setObject:self.buildiumID forKey:@"buildiumID"];
    [listingDict setObject:[NSNumber numberWithBool:self.airConditioning] forKey:@"airConditioning"];
    [listingDict setObject:[NSNumber numberWithBool:self.balcony] forKey:@"balcony"];
    [listingDict setObject:[NSNumber numberWithBool:self.cable] forKey:@"cable"];
    [listingDict setObject:[NSNumber numberWithBool:self.carport] forKey:@"carport"];
    [listingDict setObject:[NSNumber numberWithBool:self.dishwasher] forKey:@"dishwasher"];
    [listingDict setObject:[NSNumber numberWithBool:self.fenced] forKey:@"fenced"];
    [listingDict setObject:[NSNumber numberWithBool:self.fireplace] forKey:@"fireplace"];
    [listingDict setObject:[NSNumber numberWithBool:self.garage] forKey:@"garage"];
    [listingDict setObject:[NSNumber numberWithBool:self.hardwood] forKey:@"hardwood"];
    [listingDict setObject:[NSNumber numberWithBool:self.internet] forKey:@"internet"];
    [listingDict setObject:[NSNumber numberWithBool:self.laundry] forKey:@"laundry"];
    [listingDict setObject:[NSNumber numberWithBool:self.microwave] forKey:@"microwave"];
    [listingDict setObject:[NSNumber numberWithBool:self.oven] forKey:@"oven"];
    [listingDict setObject:[NSNumber numberWithBool:self.refrigerator] forKey:@"refrigerator"];
    [listingDict setObject:[NSNumber numberWithBool:self.virtualTour] forKey:@"virtualTour"];
    [listingDict setObject:[NSNumber numberWithBool:self.walkCloset] forKey:@"walkCloset"];
    [listingDict setObject:[NSNumber numberWithBool:self.favorite] forKey:@"favorite"];
    
    return [NSDictionary dictionaryWithDictionary:listingDict];
    
}

-(NSDictionary *)features{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    if (self.heat) [ret setObject:self.heat forKey:@"heat"];
    //if (self.sqft && self.sqft!= 0) [ret setObject:self.sqft forKey:@"sqft"];
    if (self.airConditioning) [ret setObject:[NSNumber numberWithBool:self.airConditioning] forKey:@"airConditioning"];
    if (self.balcony) [ret setObject:[NSNumber numberWithBool:self.balcony] forKey:@"balcony"];
    if (self.cable) [ret setObject:[NSNumber numberWithBool:self.cable] forKey:@"cable"];
    if (self.carport) [ret setObject:[NSNumber numberWithBool:self.carport] forKey:@"carport"];
    if (self.dishwasher) [ret setObject:[NSNumber numberWithBool:self.dishwasher] forKey:@"dishwasher"];
    if (self.fenced) [ret setObject:[NSNumber numberWithBool:self.fenced] forKey:@"fenced"];
    if (self.fireplace) [ret setObject:[NSNumber numberWithBool:self.fireplace] forKey:@"fireplace"];
    if (self.garage) [ret setObject:[NSNumber numberWithBool:self.garage] forKey:@"garage"];
    if (self.hardwood) [ret setObject:[NSNumber numberWithBool:self.hardwood] forKey:@"hardwood"];
    if (self.internet) [ret setObject:[NSNumber numberWithBool:self.internet] forKey:@"internet"];
    if (self.laundry) [ret setObject:[NSNumber numberWithBool:self.laundry] forKey:@"laundry"];
    if (self.microwave) [ret setObject:[NSNumber numberWithBool:self.microwave] forKey:@"microwave"];
    if (self.oven) [ret setObject:[NSNumber numberWithBool:self.oven] forKey:@"oven"];
    if (self.refrigerator) [ret setObject:[NSNumber numberWithBool:self.refrigerator] forKey:@"refrigerator"];
    if (self.walkCloset) [ret setObject:[NSNumber numberWithBool:self.walkCloset] forKey:@"walkCloset"];
    
    return [NSDictionary dictionaryWithDictionary:ret];
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.beds forKey:@"beds"];
    [aCoder encodeObject:self.baths forKey:@"baths"];
    [aCoder encodeObject:self.sqft forKey:@"sqft"];
    [aCoder encodeObject:self.rent forKey:@"rent"];
    [aCoder encodeObject:self.buildiumID forKey:@"buildiumID"];
    [aCoder encodeObject:self.descrip forKey:@"descrip"];
    [aCoder encodeObject:self.available forKey:@"available"];
    [aCoder encodeObject:self.imageArray forKey:@"imageArray"];
    [aCoder encodeObject:self.imageSrc forKey:@"imageSrc"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.heat forKey:@"heat"];
    [aCoder encodeObject:self.start forKey:@"start"];
    [aCoder encodeObject:self.stop forKey:@"stop"];
    
    [aCoder encodeBool:self.favorite forKey:@"favorite"];
    [aCoder encodeBool:self.cable forKey:@"cable"];
    [aCoder encodeBool:self.hardwood forKey:@"hardwood"];
    [aCoder encodeBool:self.refrigerator forKey:@"refrigerator"];
    [aCoder encodeBool:self.laundry forKey:@"laundry"];
    [aCoder encodeBool:self.oven forKey:@"oven"];
    [aCoder encodeBool:self.virtualTour forKey:@"virtualTour"];
    [aCoder encodeBool:self.airConditioning forKey:@"airConditioning"];
    [aCoder encodeBool:self.balcony forKey:@"balcony"];
    [aCoder encodeBool:self.carport forKey:@"carport"];
    [aCoder encodeBool:self.dishwasher forKey:@"dishwasher"];
    [aCoder encodeBool:self.fenced forKey:@"fenced"];
    [aCoder encodeBool:self.fireplace forKey:@"fireplace"];
    [aCoder encodeBool:self.garage forKey:@"garage"];
    [aCoder encodeBool:self.internet forKey:@"internet"];
    [aCoder encodeBool:self.microwave forKey:@"microwave"];
    [aCoder encodeBool:self.walkCloset forKey:@"walkCloset"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    self.address = [aDecoder decodeObjectForKey:@"address"];
    self.beds = [aDecoder decodeObjectForKey:@"beds"];
    self.baths = [aDecoder decodeObjectForKey:@"baths"];
    self.sqft = [aDecoder decodeObjectForKey:@"sqft"];
    self.rent = [aDecoder decodeObjectForKey:@"rent"];
    self.buildiumID = [aDecoder decodeObjectForKey:@"buildiumID"];
    self.descrip = [aDecoder decodeObjectForKey:@"descrip"];
    self.available = [aDecoder decodeObjectForKey:@"available"];
    self.imageArray = [aDecoder decodeObjectForKey:@"imageArray"];
    self.imageSrc = [aDecoder decodeObjectForKey:@"imageSrc"];
    self.location = [aDecoder decodeObjectForKey:@"location"];
    self.heat = [aDecoder decodeObjectForKey:@"heat"];
    self.start = [aDecoder decodeObjectForKey:@"start"];
    self.stop = [aDecoder decodeObjectForKey:@"stop"];
    
    if (self.imageArray.count == 0 && self.imageSrc.count != 0){
        dispatch_async(imageQueue(), ^{
            NSDate *methodStart = [NSDate date];
            NSLog(@"%@",methodStart);
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:[self.imageSrc objectAtIndex:0]]];
            [self.imageArray addObject:[UIImage imageWithData:imageData]];
            
            NSDate *methodFinish = [NSDate date];
            NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
            NSLog(@"executionTime = %f", executionTime);
        });
    }
    
    self.favorite = [aDecoder decodeBoolForKey:@"favorite"];
    self.cable = [aDecoder decodeBoolForKey:@"cable"];
    self.hardwood = [aDecoder decodeBoolForKey:@"hardwood"];
    self.refrigerator = [aDecoder decodeBoolForKey:@"refrigerator"];
    self.laundry = [aDecoder decodeBoolForKey:@"laundry"];
    self.oven = [aDecoder decodeBoolForKey:@"oven"];
    self.virtualTour = [aDecoder decodeBoolForKey:@"virtualTour"];
    self.airConditioning = [aDecoder decodeBoolForKey:@"airConditioning"];
    self.balcony = [aDecoder decodeBoolForKey:@"balcony"];
    self.carport = [aDecoder decodeBoolForKey:@"carport"];
    self.dishwasher = [aDecoder decodeBoolForKey:@"dishwasher"];
    self.fenced = [aDecoder decodeBoolForKey:@"fenced"];
    self.fireplace = [aDecoder decodeBoolForKey:@"fireplace"];
    self.garage = [aDecoder decodeBoolForKey:@"garage"];
    self.internet = [aDecoder decodeBoolForKey:@"internet"];
    self.microwave = [aDecoder decodeBoolForKey:@"microwave"];
    self.walkCloset = [aDecoder decodeBoolForKey:@"walkCloset"];
    
    return self;
}

@end

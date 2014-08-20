//
//  Listing.m
//  My CSP
//
//  Created by Calvin Chestnut on 6/10/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "Listing.h"

@implementation Listing {
    UIImage *firstImage;
}

// Creates a new dispatch queue to use for imageLoading if one does not already exist
dispatch_queue_t imageQueue() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.push.mycsp.imagethread", 0);
    });
    return queue;
}

// Uses a JSON dictionary to initialize the Listing
-(id)initWithDictionary:(NSDictionary *)infoIn{
    
    self = [super init];
    
    
    self.address = infoIn[@"address"];
    
    // Uses the shortens the Address and splits off the Town for displaying on small labels
    self.addressShort = self.address;
    self.addressShort = [self.addressShort componentsSeparatedByString:@":"][0];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@"Road" withString:@"Rd."];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@"Drive" withString:@"Dr."];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@"Street" withString:@"St."];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@"Court" withString:@"Ct."];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@"Avenue" withString:@"Ave."];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@"Lane" withString:@"Ln."];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@"Place" withString:@"Pl."];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@"North" withString:@"N."];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@"South" withString:@"S."];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@"East" withString:@"E."];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@"West" withString:@"W."];
    self.addressShort = [self.addressShort stringByReplacingOccurrencesOfString:@", NY" withString:@" NY,"];
    
    self.town = [self.addressShort componentsSeparatedByString:@","][1];
    self.town = [self.town stringByReplacingOccurrencesOfString:@" NY" withString:@", NY"];
    
    self.addressShort = [self.addressShort componentsSeparatedByString:@","][0];
    
    
    // Creates a dateFormatter to set available, start and end dates
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
    
    // Initializes dateFormat
    [formatter setDateFormat:@"yyyy-MM-dd"];
    // Date as String, passed from infoIn
    NSString *date = [infoIn[@"available"] componentsSeparatedByString:@"T"][0];
    // NSDate Result
    self.available = [formatter dateFromString:date];
    date = [infoIn[@"listDate"] componentsSeparatedByString:@"T"][0];
    self.start = [formatter dateFromString:date];
    date = [infoIn[@"unavailable"] componentsSeparatedByString:@"T"][0];
    self.stop = [formatter dateFromString:date];
    
    
    if ([self isNowBetweenDate:self.start andDate:self.stop]){
        // First attempt to create a geocoder to get Location from Address
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        
        NSLog(@"Attempting to geocode %@", self.addressShort);
        
        [geocoder geocodeAddressString:[NSString stringWithFormat:@"%@",self.address] completionHandler:^(NSArray* placemarks, NSError* error){
            if (!error){
                CLLocation *location = [(CLPlacemark *)[placemarks lastObject] location];
                NSLog(@"No Error receiving geolocation for %@ \nLat: %.5f, Long: %.5f", self.addressShort, location.coordinate.latitude, location.coordinate.longitude);
                NSLog(@"Horizontal accuracy: %.5f", location.horizontalAccuracy);
                
                // Saves to self.location if completed without error
                self.location = location;
            } else {
                NSLog(@"Error %@ receiving geolocation for %@", error, self.addressShort);
            }
        }];
    }
    
    // If info Contains a valid description
    if ([infoIn[@"description"] isKindOfClass:[NSString class]]){
        
        // Set the description
        self.descrip = infoIn[@"description"];
        
        
        /*
         iOS 8
         if ([self.descrip containsString:@"To view the virtual tour"]){
         */
        
        // Checks if the description contains a link to a virtual tour
        if ([self.descrip rangeOfString:@"To view the virtual tour"].location != NSNotFound){
            
            // Pull the URL for the tour from the description and saves to Listing
            NSString *url = [self.descrip componentsSeparatedByString:@"href=\""][1];
            url = [url componentsSeparatedByString:@"\""][0];
            self.tourURL = url;
            
            // Resaves description without link to the Tour
            self.descrip = [NSString stringWithFormat:@"%@%@", [self.descrip componentsSeparatedByString:@"To view the virtual"][0], [self.descrip componentsSeparatedByString:@">"][2]];
        }
    } else {
        self.descrip = @"No Description Available";
    }
    
    // Pulls info from infoIn and saves to Listing
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
    
    if ([infoIn[@"unitID"] isKindOfClass:[NSNull class]]){
        self.unitID = [NSNumber numberWithInt:0];
    } else {
        self.unitID = [NSNumber numberWithInt:[infoIn[@"unitID"] intValue]];
    }
    
    if ([infoIn[@"heat"] isKindOfClass:[NSNull class]]){
        self.heat = nil;
    } else {
        self.heat = infoIn[@"heat"];
    }
    
    // Initializes the array of images
    self.imageArray = [[NSMutableArray alloc] init];
    
    // If infoIn has valid ImageSrc
    if (![infoIn[@"listingsImage"] isKindOfClass:[NSNull class]]){
        // Array of Image Sources is pulled from infoIn
        self.imageSrc = [[NSArray alloc] initWithArray:infoIn[@"listingsImage"]];
    } else {
        // Else imageSrc is an empty array
        self.imageSrc = [[NSArray alloc] init];
    }
    
    
    if ([infoIn[@"buildiumID"] isKindOfClass:[NSNull class]]){
        self.property = [[Property alloc] initWithID:[NSNumber numberWithInt:0]];
        [infoIn[@"properties"] setObject:self.property forKey:self.property.buildiumID];
    } else {
        if ([infoIn[@"properties"] objectForKey:[NSNumber numberWithInt:[infoIn[@"buildiumID"] intValue]]]){
            self.property = [infoIn[@"properties"] objectForKey:[NSNumber numberWithInt:[infoIn[@"buildiumID"] intValue]]];
            if (!self.property.firstImage && self.imageSrc.count != 0 && [self isNowBetweenDate:self.start andDate:self.stop]){
                [self loadFirstImage:self.imageSrc[0]];
            } else if (self.property.firstImage && self.imageSrc.count != 0 && [self isNowBetweenDate:self.start andDate:self.stop]){
                [self.imageArray addObject:self.property.firstImage];
            }
        } else {
            self.property = [[Property alloc] initWithID:[NSNumber numberWithInt:[infoIn[@"buildiumID"] intValue]]];
            if (self.imageSrc.count > 0 && [self isNowBetweenDate:self.start andDate:self.stop]){
                [self loadFirstImage:self.imageSrc[0]];
            }
            [infoIn[@"properties"] setObject:self.property forKey:self.property.buildiumID];
        }

    }
    
    
    // Initializes booleans for amenities
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
    
    
    
    // If any amenitiy is not NULL, set it's appropriate bool to true
    if (![self checkIfNull:infoIn[@"airContioning"]]){
        self.airConditioning = YES;
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
    
    
    // Returns the new Listing
    return self;
}


// Returns YES if object is of NULL class
-(BOOL)checkIfNull:(id)objectIn{
    if ([objectIn isKindOfClass:[NSNull class]]){
        return YES;
    }
    return NO;
}


// Exports a dictionary witl info about Listing amenities
-(NSDictionary *)features{
    
    // Creates dictionary to be returned
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    
    // Adds objects to the return dictionary if they exist and are not null
    if (self.heat && ![self.heat isKindOfClass:[NSNull class]])
        [ret setObject:self.heat forKey:@"heat"];
    if (self.airConditioning)
        [ret setObject:[NSNumber numberWithBool:self.airConditioning] forKey:@"airConditioning"];
    if (self.balcony)
        [ret setObject:[NSNumber numberWithBool:self.balcony] forKey:@"balcony"];
    if (self.cable)
        [ret setObject:[NSNumber numberWithBool:self.cable] forKey:@"cable"];
    if (self.carport)
        [ret setObject:[NSNumber numberWithBool:self.carport] forKey:@"carport"];
    if (self.dishwasher)
        [ret setObject:[NSNumber numberWithBool:self.dishwasher] forKey:@"dishwasher"];
    if (self.fenced)
        [ret setObject:[NSNumber numberWithBool:self.fenced] forKey:@"fenced"];
    if (self.fireplace)
        [ret setObject:[NSNumber numberWithBool:self.fireplace] forKey:@"fireplace"];
    if (self.garage)
        [ret setObject:[NSNumber numberWithBool:self.garage] forKey:@"garage"];
    if (self.hardwood)
        [ret setObject:[NSNumber numberWithBool:self.hardwood] forKey:@"hardwood"];
    if (self.internet)
        [ret setObject:[NSNumber numberWithBool:self.internet] forKey:@"internet"];
    if (self.laundry)
        [ret setObject:[NSNumber numberWithBool:self.laundry] forKey:@"laundry"];
    if (self.microwave)
        [ret setObject:[NSNumber numberWithBool:self.microwave] forKey:@"microwave"];
    if (self.oven)
        [ret setObject:[NSNumber numberWithBool:self.oven] forKey:@"oven"];
    if (self.refrigerator)
        [ret setObject:[NSNumber numberWithBool:self.refrigerator] forKey:@"refrigerator"];
    if (self.walkCloset)
        [ret setObject:[NSNumber numberWithBool:self.walkCloset] forKey:@"walkCloset"];
    
    
    // Returns dictionary
    return ret;
}

// Takes in an ImageURL and loads the image
-(void)loadFirstImage:(NSString *)srcIn{
    
    // Sends block to the imageQueue for asyncronous loading
    dispatch_async(imageQueue(), ^{
        
        // Gets data from URL
        NSData *imageData = [[NSData alloc] initWithContentsOfURL:[[NSURL alloc] initWithString:srcIn]];
        
        // If data is not empty create an image and store it to ImageArray
        if (imageData)
            firstImage = [UIImage imageWithData:imageData];
            [self.imageArray addObject:firstImage];
            [self.property setFirstImage:firstImage];
    });
}


// Checks to see if current is within start and end date
- (BOOL)isNowBetweenDate:(NSDate *)earlierDate andDate:(NSDate *)laterDate
{
    
    // Determines current date
    NSDate *first = [[NSDate alloc] init];
    
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


#pragma mark-NSCoding Methods

// Encodes object to save as NSData
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.addressShort forKey:@"addressShort"];
    [aCoder encodeObject:self.town forKey:@"town"];
    [aCoder encodeObject:self.tourURL forKey:@"tourURL"];
    [aCoder encodeObject:self.beds forKey:@"beds"];
    [aCoder encodeObject:self.baths forKey:@"baths"];
    [aCoder encodeObject:self.sqft forKey:@"sqft"];
    [aCoder encodeObject:self.rent forKey:@"rent"];
    [aCoder encodeObject:self.property forKey:@"property"];
    [aCoder encodeObject:self.unitID forKey:@"unitID"];
    [aCoder encodeObject:self.descrip forKey:@"descrip"];
    [aCoder encodeObject:self.available forKey:@"available"];
    [aCoder encodeObject:self.imageArray forKey:@"imageArray"];
    [aCoder encodeObject:self.imageSrc forKey:@"imageSrc"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeDouble:self.location.coordinate.latitude forKey:@"lat"];
    [aCoder encodeDouble:self.location.coordinate.longitude forKey:@"long"];
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


// Init with decoder from NSData
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    self.address = [aDecoder decodeObjectForKey:@"address"];
    self.addressShort = [aDecoder decodeObjectForKey:@"addressShort"];
    self.tourURL = [aDecoder decodeObjectForKey:@"tourURL"];
    self.town = [aDecoder decodeObjectForKey:@"town"];
    self.beds = [aDecoder decodeObjectForKey:@"beds"];
    self.baths = [aDecoder decodeObjectForKey:@"baths"];
    self.sqft = [aDecoder decodeObjectForKey:@"sqft"];
    self.rent = [aDecoder decodeObjectForKey:@"rent"];
    self.property = [aDecoder decodeObjectForKey:@"property"];
    self.unitID = [aDecoder decodeObjectForKey:@"unitID"];
    self.descrip = [aDecoder decodeObjectForKey:@"descrip"];
    self.available = [aDecoder decodeObjectForKey:@"available"];
    self.imageArray = [NSMutableArray arrayWithArray:[aDecoder decodeObjectForKey:@"imageArray"]];
    self.imageSrc = [aDecoder decodeObjectForKey:@"imageSrc"];
    self.heat = [aDecoder decodeObjectForKey:@"heat"];
    self.start = [aDecoder decodeObjectForKey:@"start"];
    self.stop = [aDecoder decodeObjectForKey:@"stop"];
    
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
    
    
    // If lat/long coordinates were saved
    if ([aDecoder decodeDoubleForKey:@"lat"] != 0){
        
        // Initialize the location with the coordinates
        self.location = [[CLLocation alloc] initWithLatitude:[aDecoder decodeDoubleForKey:@"lat"] longitude:[aDecoder decodeDoubleForKey:@"long"]];
    } else {
        
        // Attempt to get the location from Geocoder with address
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:[NSString stringWithFormat:@"%@",self.address] completionHandler:^(NSArray* placemarks, NSError* error){
            if (!error){
                self.location = [(CLPlacemark *)[placemarks lastObject] location];
            }
        }];
    }
    
    // If no image was saved, there are images to be loaded, and Listing will be displayed in search results
    if (self.imageArray.count == 0 && self.imageSrc.count != 0 && [self isNowBetweenDate:self.start andDate:self.stop]){
        
        // Load the first image
        [self loadFirstImage:self.imageSrc[0]];
    }
    
    return self;
}

@end

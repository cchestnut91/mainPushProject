//
//  Property.m
//  My CSP
//
//  Created by Calvin Chestnut on 8/16/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "Property.h"

@implementation Property

-(id)initWithID:(NSNumber *)idIn{
    self = [super init];
    
    self.buildiumID = idIn;
    //self.firstImage = [UIImage imageNamed:@"default.png"];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    self.buildiumID = [aDecoder decodeObjectForKey:@"buildiumID"];
    self.firstImage = [aDecoder decodeObjectForKey:@"firstImage"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.buildiumID forKey:@"buildiumID"];
    [aCoder encodeObject:self.firstImage forKey:@"firstImage"];
}

@end

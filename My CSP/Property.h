//
//  Property.h
//  My CSP
//
//  Created by Calvin Chestnut on 8/16/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Property : NSObject <NSCoding>

@property (strong, nonatomic) NSNumber *buildiumID;
@property (strong, nonatomic) UIImage *firstImage;

-(id)initWithID:(NSNumber *)idIn;
-(id)initWithCoder:(NSCoder *)aDecoder;

-(void)encodeWithCoder:(NSCoder *)aCoder;

@end

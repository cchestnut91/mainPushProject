//
//  ListingTableNavigationController.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/8/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListingFilter.h"
#import "ViewController.h"

@interface ListingTableNavigationController : UINavigationController

@property (strong, nonatomic) NSArray *listing;
@property (strong, nonatomic) ListingFilter *filter;
@property (strong, nonatomic) NSString *source;

@end

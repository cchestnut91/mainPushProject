//
//  RotatingPreviewController.h
//  My CSP
//
//  Created by Calvin Chestnut on 8/12/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <QuickLook/QuickLook.h>
#import "Listing.h"

@interface RotatingPreviewController : QLPreviewController

@property (strong, nonatomic) Listing *listing;

@end

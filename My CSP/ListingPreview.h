//
//  ListingPreview.h
//  My CSP
//
//  Created by Calvin Chestnut on 8/12/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

// Used to hold URLs to Local Image Files for QuickLook to display
// Conforms to QLPreviewItem predicate

@interface ListingPreview : NSObject <
    QLPreviewItem
>

@property (atomic, retain) NSURL *previewItemURL;
@property (atomic, retain) NSString *previewItemTitle;

@end

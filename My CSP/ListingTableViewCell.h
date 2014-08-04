//
//  ListingTableViewCell.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/8/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Listing.h"

@interface ListingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *barView;
@property (weak, nonatomic) IBOutlet UILabel *rentLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *bedLabel;

-(void)passListing:(Listing *)listingIn;

@end

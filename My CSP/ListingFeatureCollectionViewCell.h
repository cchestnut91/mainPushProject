//
//  ListingFeatureCollectionViewCell.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/22/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>

// Rename to AmenityCollectionViewCell when Xcode gets the stick out of its ass
@interface ListingFeatureCollectionViewCell : UICollectionViewCell

// Collection view for amenities with an image and a label
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

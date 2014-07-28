//
//  ListingDetailViewController.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/9/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListingTableViewController.h"
#import "ListingFeatureCollectionViewCell.h"
#import <MapKit/MapKit.h>
#import <QuickLook/QuickLook.h>

@interface ListingDetailViewController : UIViewController <UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) Listing *listing;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *blurView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selector;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UICollectionView *featuresCollection;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *townLabel;
@property (weak, nonatomic) IBOutlet UILabel *rentLabel;
@property (weak, nonatomic) IBOutlet UILabel *availableLabel;

@property (weak, nonatomic) IBOutlet UITextView *detailText;
@property (strong, nonatomic) NSDictionary *features;

@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

@property CGFloat deltaY;
@property CGFloat ceil;
@property CGFloat floor;
@property int imgPos;

-(void)passListing:(Listing *)listingIn;
- (IBAction)updateSubView:(id)sender;
-(void)toggleFavorite;

@end

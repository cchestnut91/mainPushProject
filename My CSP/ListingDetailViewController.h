//
//  ListingDetailViewController.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/9/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ListingTableViewController.h"
#import "ListingFeatureCollectionViewCell.h"
#import "ListingPreview.h"
#import "MarqueeLabel.h"
#import "RotatingPreviewController.h"

@interface ListingDetailViewController : UIViewController <
    UIGestureRecognizerDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    QLPreviewControllerDataSource,
    QLPreviewControllerDelegate,
    UIActionSheetDelegate,
    MFMailComposeViewControllerDelegate,
    MKMapViewDelegate
>

// IBOutlets for UIElements
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageIndicator;
@property (weak, nonatomic) IBOutlet UIView *blurView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImage;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selector;

// InfoView & Elements
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *townLabel;
@property (weak, nonatomic) IBOutlet UILabel *rentLabel;
@property (weak, nonatomic) IBOutlet UILabel *availableLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UILabel *detailText;

// MapView
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

// Amenities View
@property (weak, nonatomic) IBOutlet UICollectionView *featuresCollection;

// Loading View
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIView *loadingView;

// Listing in question
@property (strong, nonatomic) Listing *listing;

// Handles switching the subview when SegmentedControl is changed
- (IBAction)updateSubView:(id)sender;

// Loads the listing
-(void)passListing:(Listing *)listingIn;

// Changes the favorite value of the listing
-(void)toggleFavorite;

// Determines appropriate string to label an amenity with
-(NSString *)stringForKey:(NSString *)key;

// Dismisses the containing NavigationController
- (IBAction)close:(id)sender;

// Attempts to open a new QLPreviewController
- (IBAction)previewImage:(id)sender;

// Swipe responder to change the displayed image in the ImageView and animate
- (IBAction)changeImage:(UISwipeGestureRecognizer *)recognizer;

// Contact realtor. may not be Carol
- (IBAction)callCarol:(id)sender;

// Initializes gesture recognizers and adds them to imageView
-(void)addGestures;

@end

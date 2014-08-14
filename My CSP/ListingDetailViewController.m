//
//  ListingDetailViewController.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/9/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "ListingDetailViewController.h"

@interface ListingDetailViewController ()

@end

@implementation ListingDetailViewController {
    
    // Listing in question
    Listing *listing;
    
    // Dictionary with amenities of Listing
    NSDictionary *features;
    
    // Preview items for QuickLook to display
    NSMutableArray *previews;
    
    // Used to determine if favorite value has been changed on viewWillDisappear
    BOOL wasFav;
    
    // Current image to be displayed in the imageView
    int imgPos;
}

// dispatch queue to download remaining images
// Only created once
dispatch_queue_t moreimages() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.push.mycsp.newimages", 0);
    });
    return queue;
}

#pragma mark - View initialization and Loading

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Only way listing would be set is if this view is being presented without a ListingResultsTableViewController
    // Meaning this is passed from a URL with a single UnitID
    if (!listing){
        
        // Pass listing to self from Navigation Controller
        // Navigation Controller should have only one listing
        [self passListing:[(ListingTableNavigationController*)self.navigationController listings][0]];
        
        // Add a close button to the Navigation Bar
#warning Not sure if necessary
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)]];
    }
    
    
    // Set featuresCollection dataSource & Delegate
    [self.featuresCollection setDataSource:self];
    [self.featuresCollection setDelegate:self];
    [self.mapView setDelegate:self];
    
    // Set title to match mockups
#warning Should we change this to something more relevant?
    [self setTitle:@"C.S.P. Managment"];
    
    //Initialize variables
    imgPos = 0;
    previews = [[NSMutableArray alloc] init];
    
    // Create 'favorite' button and set appropriate image
    UIButton *favButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    if (listing.favorite){
        [favButton setImage:[UIImage imageNamed:@"blueStar"] forState:UIControlStateNormal];
    } else {
        [favButton setImage:[UIImage imageNamed:@"blueStarEmpty"] forState:UIControlStateNormal];
    }
    // Add favorite button selector
    [favButton addTarget:self action:@selector(toggleFavorite) forControlEvents:UIControlEventTouchUpInside];
    
    // Add to navigation item as BarButtonItem
    UIBarButtonItem *favBarButton = [[UIBarButtonItem alloc] initWithCustomView:favButton];
    [self.navigationItem setRightBarButtonItem:favBarButton];
    
    
    // This block handles the PropImages Directory
    // Creates it if necessary, removes everything in it if it already exists
    BOOL isDir;
    NSError *saveError;
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *imgDir = [directory stringByAppendingPathComponent:@"PropImages"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imgDir isDirectory:&isDir]){
        
        // If file exists but it not a directory
        if (!isDir){
            
            // Remove file and create directory
            [[NSFileManager defaultManager] removeItemAtPath:imgDir error:nil];
            [[NSFileManager defaultManager] createDirectoryAtPath:imgDir withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        
        NSArray *listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imgDir error:nil];
        if (listOfFiles.count != 0){
            for (NSString *file in listOfFiles){
                [[NSFileManager defaultManager] removeItemAtPath:[imgDir stringByAppendingPathComponent:file] error:&saveError];
                NSLog(@"Attempted");
            }
        }
        
    } else {
        [[NSFileManager defaultManager] createDirectoryAtPath:imgDir withIntermediateDirectories:NO attributes:nil error:nil];
    }

    
    // This block handles three possible states of the imageArray
    
    // If an image has been downloaded for each imageURL in listing.imageSrc and there are more than one image
    if (listing.imageSrc.count == listing.imageArray.count && listing.imageSrc.count > 1){
        
        // Set the page indicator to the appropriate number
        [self.pageIndicator setNumberOfPages:listing.imageArray.count];
        
        // Set the initial image
        [self.imageView setImage:[listing.imageArray objectAtIndex:0]];
        
        // Add gesture recognizers to imageView
        [self addGestures];
        
        // Allow user interaction
        // Disabled by default for image Loading
        [self.imageView setUserInteractionEnabled:YES];
        
        
        // For each image in the imageArray
        for (UIImage *image in listing.imageArray){
            
            // Generate a unique URL for the image using a UUID
            NSString *imgURL = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"png"];
            
            // Save the UIImage as NSData with PNG format and write to the url within the image directory
            [UIImagePNGRepresentation(image) writeToFile:[imgDir stringByAppendingPathComponent:imgURL] atomically:YES];
            
            // Create a new instance of a ListingPreview item
            // This is what gets passed to the PreviewController and displays an image
            ListingPreview *preview = [[ListingPreview alloc] init];
            
            NSString *filePath = [imgDir stringByAppendingPathComponent:imgURL];
            preview.previewItemURL = [NSURL fileURLWithPath:filePath];
            preview.previewItemTitle = listing.addressShort;
            
            [previews addObject:preview];
        }
    }
    // If more than one imageURL but not all images have been downloaded
    else if (listing.imageSrc.count > 1){
        
        // set Page indicator count to number of images currently downloaded
        [self.pageIndicator setNumberOfPages:listing.imageArray.count];
        
        // Set the initial image
        [self.imageView setImage:[listing.imageArray objectAtIndex:0]];
        
        // Display Loading view
        [self.activity setHidden:NO];
        [self.loadingView setHidden:NO];
        [self.loadingView.layer setCornerRadius:10];
        [self.loadingView setClipsToBounds:YES];
        
        // Disable userInteraction in the imageView during download
        // Bottom half of the view is still interactable
        [self.imageView setUserInteractionEnabled:NO];
        
        // Create a unique URL for the first image
        NSString *imgURLString = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"png"];
        
        // Write image as PNG data to the Image URL within the imageDirectory
        [UIImagePNGRepresentation(listing.imageArray[0]) writeToFile:[imgDir stringByAppendingPathComponent:imgURLString] atomically:YES];
        
        
        // Creates a preview item for the first image
        ListingPreview *preview = [[ListingPreview alloc] init];
        
        preview.previewItemTitle = listing.addressShort;
        NSString *filePath = [imgDir stringByAppendingPathComponent:imgURLString];
        preview.previewItemURL = [NSURL fileURLWithPath:filePath];
        
        [previews addObject:preview];
        
        // Move into dispatch queue for asyncronous image downloading
        dispatch_async(moreimages(), ^{
            
            // For each imageURL after the first one
            for (int i = 1; i < listing.imageSrc.count; i++){
                
                // Gets the imageURL
                NSURL *imgUrl = [[NSURL alloc] initWithString:[listing.imageSrc objectAtIndex:i]];
                
                // Download the image as data syncronously
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:imgUrl];
                
                // Create the new image and initialize with data if no download error
                UIImage *newImage;
                if (imageData){
                    newImage = [UIImage imageWithData:imageData];
                } else {
                    newImage = [UIImage imageNamed:@"default.png"];
                }
                
                // Add the image to the listing image array
                [listing.imageArray addObject:newImage];
                
                // Create a unique URL to store the image
                NSString *imgURLString = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"png"];
                
                // Save the image as PNG Data
                [UIImagePNGRepresentation(newImage) writeToFile:[imgDir stringByAppendingPathComponent:imgURLString] atomically:YES];
                
                // Create new Preview item for the image
                ListingPreview *preview = [[ListingPreview alloc] init];
                
                preview.previewItemTitle = listing.addressShort;
                NSString *filePath = [imgDir stringByAppendingPathComponent:imgURLString];
                preview.previewItemURL = [NSURL fileURLWithPath:filePath];
                
                [previews addObject:preview];
                
                
                // Move to main queue for UI updates
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Update number of pages to show downloading progress
                    // Could potentially have better indicator of progress
                    [self.pageIndicator setNumberOfPages:listing.imageArray.count];
                    
                    // If an image has been downloaded for each imageURL
                    if (listing.imageArray.count == listing.imageSrc.count){
                        
                        // Allow imageView interaction & Hide loading indicator
                        [self.imageView setUserInteractionEnabled:YES];
                        [self.loadingView setHidden:YES];
                        [self.activity setHidden:YES];
                        
                        // Add gesture recognizers to imageView
                        [self addGestures];
                    }
                });
            }
        });
    }
    
    // If only one or 0 images
    else {
        
        // Hide page indicator
        [self.pageIndicator setHidden:YES];
        
        // if not 0 images
        if (listing.imageSrc.count != 0){
            
            // Allow user interaction of image
            [self.imageView setUserInteractionEnabled:YES];
            
            // If at least one image definitely loaded
            if (listing.imageArray.count != 0){
                
                // set the initial image
                [self.imageView setImage:[listing.imageArray objectAtIndex:0]];
                
                // Add gesture recognizers to imageView
                [self addGestures];
                
                // Create unique URL for image and save as PNG Data
                NSString *imgURL = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"png"];
                [UIImagePNGRepresentation(listing.imageArray[0]) writeToFile:[imgDir stringByAppendingPathComponent:imgURL] atomically:YES];
                
                // Generate preview item for image
                ListingPreview *preview = [[ListingPreview alloc] init];
                
                preview.previewItemTitle = listing.addressShort;
                NSString *filePath = [imgDir stringByAppendingPathComponent:imgURL];
                preview.previewItemURL = [NSURL fileURLWithPath:filePath];
                
                [previews addObject:preview];
            }
            
            // If no images saved
            else {
                
                // Set default image
                [self.imageView setImage:[UIImage imageNamed:@"default.png"]];
                
                // Deny user interaction of image
                [self.imageView setUserInteractionEnabled:NO];

            }
        }
    }
    
    // Bottom image is initialized with a horizontal reflection of the imageView
    [self.bottomImage setImage:[UIImage imageWithCGImage:self.imageView.image.CGImage scale:self.imageView.image.scale orientation:UIImageOrientationDownMirrored]];
    
    // Make sure imageView doesn't display image beyond forders
    [self.imageView setClipsToBounds:YES];
    
    
#warning Remove if there's a crash. Not sure if necessary
    //[self.view layoutIfNeeded];

    [self.townLabel setText:listing.town];
    
    NSString *address = listing.addressShort;
    
    // Clarifies Unit for ambiguous apartment text
    /*
     iOS 8
    if (![address containsString:@"Apt"] && ![address containsString:@"Room"] && ![address containsString:@"Terrace"] && [address containsString:@"-"]){
    */
    if ([address rangeOfString:@"Apt"].location == NSNotFound && [address rangeOfString:@"Room"].location == NSNotFound && [address rangeOfString:@"Terrace"].location == NSNotFound && [address rangeOfString:@"-"].location != NSNotFound){
        address = [address stringByReplacingOccurrencesOfString:@"-" withString:@"- Unit"];
    }
    
    
    // Sets the view title to the street address of the listing
    [self setTitle:[address componentsSeparatedByString:@"-"][0]];

    // Creates scrolling UILabel and initializes speed, length, and animation type
    MarqueeLabel *scrollLabel = [[MarqueeLabel alloc] initWithFrame:self.addressLabel.frame rate:20 andFadeLength:10];
    [scrollLabel setMarqueeType:MLContinuous];
    [scrollLabel setAnimationDelay:2];
    scrollLabel.continuousMarqueeExtraBuffer = 40;
    
    // Sets style and text
    [scrollLabel setText:address];
    scrollLabel.font = self.addressLabel.font;
    scrollLabel.textColor = self.addressLabel.textColor;
    
    // Adds scrolling UILabel to infoView
    [self.infoView addSubview:scrollLabel];
    
    // Sets other info labels and text
    [self.rentLabel setText:[NSString stringWithFormat:@"$%@", listing.rent]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM. d YYYY"];
    [self.availableLabel setText:[NSString stringWithFormat:@"Available %@",[formatter stringFromDate:listing.available]]];
    
    [self.detailText setText:listing.descrip];
    
    // Necessary for content to fit directly above and below detail text
    self.detailText.preferredMaxLayoutWidth = 280;
    
    
#warning remove if there's an error. Not sure if necessary
    //[self.infoView setBounds:CGRectMake(0, 0, self.scrollView.bounds.size.width, self.addressLabel.bounds.size.height + self.rentLabel.bounds.size.height + self.contactButton.bounds.size.height + 250 + 15 + 4 + 5)];
    
    // If listing location hasn't been properly set
    if (listing.location == nil){
        
        // Attempt again to get the listing location with a geocoder
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:[NSString stringWithFormat:@"%@",listing.address] completionHandler:^(NSArray* placemarks, NSError* error){
            
            // If no error locating address
            if (!error){
                
                // Update listing location
                listing.location = [(CLPlacemark *)[placemarks lastObject] location];
                
                // Create a map pin for the listing and initialize with address and coordinates
                MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
                [pin setTitle:address];
                [pin setCoordinate:listing.location.coordinate];
                
                // Add pin to the map
                [self.mapView addAnnotation:pin];
                
                // Set visible region of the map
                MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(listing.location.coordinate, 750, 750);
                MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
                [self.mapView setRegion:adjustedRegion animated:YES];
                
                
            } else {
                
                // Disable MapView from Segmented Control if no location determined
                [self.selector setEnabled:NO forSegmentAtIndex:2];
            }
        }];
    }
    
    // If location is already determined
    else {
        
        // Create a pin for the Listing and pass address and coordinate
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        [pin setTitle:address];
        [pin setCoordinate:listing.location.coordinate];
        
        // Add pin to the map
        [self.mapView addAnnotation:pin];
        
        // Adjust visible map region
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(listing.location.coordinate, 750, 750);
        MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
        [self.mapView setRegion:adjustedRegion animated:YES];
    }
    
    
    // Blur effect
    /*
     iOS 8
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    [self.blurView addSubview:blurEffectView];
    */
    
    // Set blur to opaque white color on iOS 7
    [self.blurView setBackgroundColor:[UIColor whiteColor]];
}


// Run when view is closing
-(void)viewWillDisappear:(BOOL)animated{
    
    // Checks to see if listing favorite value is different that it was originally
    if ((wasFav && !listing.favorite) || (!wasFav && listing.favorite)){
        
        // if so find the userID from the documents directory
        NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *idFile = [directory stringByAppendingPathComponent:@"user.txt"];
        NSString *uuid = [NSKeyedUnarchiver unarchiveObjectWithFile:idFile];
        
        // Open the local saved favorites
        NSMutableArray *favorites = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:[directory stringByAppendingPathComponent:@"favs.txt"]]];
        
        // if the Listing is now a favorite
        if (listing.favorite){

            // Attempt to save listing as favorite for user
            if (![[RESTfulInterface RESTAPI] addUserFavorite:uuid :listing.unitID.stringValue]){
                // Log error
                NSLog(@"Failed saving Favorite");
            }
            
            // Check if local favorites doesn't contain the unitID
            if (![favorites containsObject:listing.unitID.stringValue]){
                
                // if not add the unitID
                [favorites addObject:listing.unitID.stringValue];
                
                // save the local copy of the favorites to the favorites file
                [NSKeyedArchiver archiveRootObject:favorites toFile:[directory stringByAppendingPathComponent:@"favs.txt"]];
            }
        }
        // If listing has been unfavorited
        else {
            
            // Attempt to remove favorite from server
            if (![[RESTfulInterface RESTAPI] removeUserFavorite:uuid :listing.unitID.stringValue]){
                
                // Log error
                NSLog(@"Failed removing Favorite");
            }
            
            // If local favorites contains unitID
            if ([favorites containsObject:listing.unitID.stringValue]){
                
                // remove unitID and resave
                [favorites removeObject:listing.unitID.stringValue];
                [NSKeyedArchiver archiveRootObject:favorites toFile:[directory stringByAppendingPathComponent:@"favs.txt"]];
            }
        }
    }
    
    [super viewWillDisappear:animated];
}


#pragma mark - CollectionView Data Source

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    // Load the amenities from the listing
    features = listing.features;
    
    // Add two for Beds and Baths, which are shown with Amenities
    return features.count + 2;
}


// Create and return a collectionViewCell for each amenity
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // Initialize the cell from the storyboard
    ListingFeatureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"featureCell" forIndexPath:indexPath];
    
    // If first cell
    if (indexPath.row == 0){
        
        // Set label and amount for beds
        [cell.label setText:[NSString stringWithFormat:@"%@ Beds", listing.beds]];
        [cell.imageView setImage:[UIImage imageNamed:@"bed"]];
    }
    // If second cell
    else if (indexPath.row == 1){
        
        // Set label and amount for Baths
        [cell.label setText:[NSString stringWithFormat:@"%@ Baths", listing.baths]];
        [cell.imageView setImage:[UIImage imageNamed:@"bath"]];
    }
    
    // for all other cells
    else {
        
        // Get string for the given amenity key
        [cell.label setText:[self stringForKey:[[features allKeys] objectAtIndex:indexPath.row - 2]]];
        
        // Get image using same key as for ameninty
        [cell.imageView setImage:[UIImage imageNamed:[[features allKeys] objectAtIndex:indexPath.row - 2]]];
    }
    
    return cell;
}

#pragma mark - Collection View Delegate

// Forces size of each cell in the collection view
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 110);
}


#pragma mark - IBActions


// Guess
- (IBAction)close:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

// Creates a QLPreviewController and display modally
- (IBAction)previewImage:(id)sender{
    
    // If at least one image
    if (listing.imageSrc.count != 0){
        
        // Initialize the PreviewController
        // Subclass RotatingPreviewController fixes problem with standard rotation
        RotatingPreviewController *previewController=[[RotatingPreviewController alloc]init];
        
        previewController.delegate=self;
        previewController.dataSource=self;
        
        // Set current image to the same image displayed in the imageView
        [previewController setCurrentPreviewItemIndex:imgPos];
        
        // Present preview Controller
        [self presentViewController:previewController animated:YES completion:nil];
        
    }
}


// Update the selected subview using the segmented control
- (IBAction)updateSubView:(id)sender {
    
    // Determine which index has been selected
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) {
            
        // Show the intended subview, and hide the other two
        case 0:
            [self.mapView setHidden:YES];
            [self.featuresCollection setHidden:YES];
            [self.scrollView setHidden:NO];
            break;
        case 1:
            [self.mapView setHidden:YES];
            [self.featuresCollection setHidden:NO];
            [self.scrollView setHidden:YES];
            break;
        case 2:
            [self.mapView setHidden:NO];
            [self.featuresCollection setHidden:YES];
            [self.scrollView setHidden:YES];
            break;
        default:
            break;
    }
}


// Responds to the SwipeGesture recognizer to animate the transition between images in the imageView
- (IBAction)changeImage:(UISwipeGestureRecognizer *)recognizer{
    
    // Only change the image if there is more than one image for the listing
    if (listing.imageArray.count > 1){
        
        // Determine the direction the user is swiping in
        
        // If swiping to the right from left
        if (recognizer.direction == UISwipeGestureRecognizerDirectionRight){
            
            // imgPos should represent the index before the one currently selected
            imgPos--;
            
            // If new index is less than 0
            if (imgPos < 0){
                
                // set new index to the last item in the array
                imgPos = (int)listing.imageArray.count - 1;
            }
            
            // Create a new imageView
            // Set the frame to match the original imageView, but move it to the left equal to the width of the view
            // This creates a new view off screen
            UIImageView *newView = [[UIImageView alloc] initWithFrame:CGRectMake(-self.imageView.frame.size.width, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)];
            
            // Everything you do to the top imageView, you also do to the bottom imageView
            // This is gonna look great in iOS 8, I swear
            UIImageView *newBottom = [[UIImageView alloc] initWithFrame:CGRectMake(-self.bottomImage.frame.size.width, self.bottomImage.frame.origin.y, self.bottomImage.frame.size.width, self.bottomImage.frame.size.height)];
            
            // Set the image for the newView to the image at the new index
            [newView setImage:[listing.imageArray objectAtIndex:imgPos]];
            
            // Set the image for the new bottom to the newView's image, but reflect it horizontally
            [newBottom setImage:[UIImage imageWithCGImage:newView.image.CGImage scale:newView.image.scale orientation:UIImageOrientationDownMirrored]];
            
            // Set content display settings for both views
            [newView setContentMode:UIViewContentModeScaleAspectFill];
            [newBottom setContentMode:UIViewContentModeScaleAspectFill];
            [newView setClipsToBounds:YES];
            [newBottom setClipsToBounds:YES];
            
            // Add both new views to the superviews of the original imageViews
            [self.imageView.superview insertSubview:newView aboveSubview:self.imageView];
            [self.bottomImage.superview insertSubview:newBottom aboveSubview:self.bottomImage];
            
            // This does the actual animation
            // Duration is 0.2 seconds
            [UIView animateWithDuration:0.2f animations:^{
                
                // first parameter of offset determines what is changing
                // second parameter determines the x offset
                // third parameter determines the y offset
                newView.frame = CGRectOffset(newView.frame, newView.frame.size.width, 0);
                newBottom.frame = CGRectOffset(newBottom.frame, newBottom.frame.size.width, 0);
                
            } completion:^(BOOL finished){
                // Completion blocks are helpful
                
                // Set the images for the original imageViews to the new image
                [self.imageView setImage:[listing.imageArray objectAtIndex:imgPos]];
                [self.bottomImage setImage:[UIImage imageWithCGImage:self.imageView.image.CGImage scale:self.imageView.image.scale orientation:UIImageOrientationDownMirrored]];
                
                // Remove the new views from the superView
                [newView removeFromSuperview];
                [newBottom removeFromSuperview];
                
                // This completion block will not be viewable to the user. It looks like the new image just swipes in and covers the original image like a stack
                // It's pretty freaking cool
            }];
            
        }
        // If swiping from the right to the left
        else {
            
            // Increment the image index
            imgPos++;
            
            // If previous image was the last in the array
            if (imgPos == listing.imageArray.count){
                
                // Set the new index to the original
                imgPos = 0;
            }
            
            // Create new top and bottom image views with the same frames as the original
            // These will cover the original when placed in the superview
            UIImageView *newView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
            UIImageView *newBottom = [[UIImageView alloc] initWithFrame:self.bottomImage.frame];
            
            // Set the images for the new top and bottom imageViews
            // Images should match the current image in each view so their placement in the superview is not noticable
            // Everything you do to the top view, do to the bottomm view too
            // Flip the bottom image so it reflects the top horizontally
            [newView setImage:self.imageView.image];
            [newBottom setImage:[UIImage imageWithCGImage:self.bottomImage.image.CGImage scale:newView.image.scale orientation:UIImageOrientationDownMirrored]];
            
            // Set content settings for both new views
            [newView setContentMode:UIViewContentModeScaleAspectFill];
            [newBottom setContentMode:UIViewContentModeScaleAspectFill];
            [newView setClipsToBounds:YES];
            [newBottom setClipsToBounds:YES];
            
            // Add both new views to the superviews
            [self.imageView.superview insertSubview:newView aboveSubview:self.imageView];
            [self.bottomImage.superview insertSubview:newBottom aboveSubview:self.bottomImage];
            
            
            // Set the images for the original imageViews to the new index
            [self.imageView setImage:[listing.imageArray objectAtIndex:imgPos]];
            [self.bottomImage setImage:[UIImage imageWithCGImage:self.imageView.image.CGImage scale:self.imageView.image.scale orientation:UIImageOrientationDownMirrored]];
            
            
            // Animage the new imageViews out of the frame
            [UIView animateWithDuration:0.2f animations:^{
                
                // Move each view off screen to the left
                // This gives the impression that they have been 'swiped' away
                newView.frame = CGRectOffset(newView.frame, -newView.frame.size.width, 0);
                newBottom.frame = CGRectOffset(newBottom.frame, -newBottom.frame.size.width, 0);
            } completion:^(BOOL finished){
                
                // Remove new views from the superview on completion
                [newView removeFromSuperview];
                [newBottom removeFromSuperview];
            }];
        }
    }
    
    // Update the pageIndicator with new index
    [self.pageIndicator setCurrentPage:imgPos];

}

// Opens up contact action sheet.
// Does not guarentee you will call Carol
- (IBAction)callCarol:(id)sender {
    // Create action sheet with three buttons and display in main view
    UIActionSheet *contactAction = [[UIActionSheet alloc] initWithTitle:@"Contact CSP" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Call 607-277-6961", @"Email CSP Info", nil];
    [contactAction showInView:self.view];
}

#pragma mark - MapView Delegate

// Customizes the mapView pin for the Listing
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    // Allows for current location indicator to have default style
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    
    //Initializes a new Pin Annotation View
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"String"];
    
    // Creates a button to be placed in the annotationView to open in Maps
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setImage:[UIImage imageNamed:@"carport"] forState:UIControlStateNormal];
    
    // Add the button to the annotation view's callout
    // The callout is what appears when the pin is clicked
    annotationView.leftCalloutAccessoryView = button;
    annotationView.enabled = YES;
    
    // Allows the callout to show up when clicked
    annotationView.canShowCallout = YES;
    
    // Annotation is the same that came in. This contains the actual information about the Location, including coordinates and title
    annotationView.annotation = annotation;
    
    
    return annotationView;
}


// Reacts to the user tapping the button in the callout
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    // Create an MKMapItem to pass to the Maps app
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(listing.location.coordinate.latitude, listing.location.coordinate.longitude);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    // Sets the name of the callout
    [mapItem setName:listing.addressShort];
    
    // Sends the pin and the user to Maps.app
    [mapItem openInMapsWithLaunchOptions:nil];
}

#pragma mark - PreviewController DataSource


-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return previews.count;
}

// Sets the Preview Item title and passes it to the PreviewController
-(id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{

    [(ListingPreview *)[previews objectAtIndex:index] setPreviewItemTitle:[self.addressLabel.text stringByAppendingString:[NSString stringWithFormat:@" Img %d", (int)index + 1]]];
    
    return previews[index];
    
}

#pragma  mark - Action Sheet Delegate

// Responds to user selection of Call Carol action sheet
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    // user clicked Call
    if (buttonIndex == 0){
        
        // Place phone call
        NSString *phoneURL = [@"telprompt://" stringByAppendingString:@"6072776961"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
    }
    
    // If user clicked email
    else if (buttonIndex == 1){
        
        // Check if phone is able to send mail
        if ([MFMailComposeViewController canSendMail]){
            
            // If so create new MailCompose ViewController and set Delegate
            MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
            [mailView setMailComposeDelegate:self];
            
            // Initialize subject, recipient, and message body
            [mailView setSubject:[NSString stringWithFormat:@"Listing at %@", self.addressLabel.text]];
            [mailView setToRecipients:@[@"info@cspmanagement.com"]];
            [mailView setMessageBody:[NSString stringWithFormat:@"I'd like to speak to someone about this property.\nComments:\n\nProperty Details\nAddress: %@\n%@\nUnit ID: %@\nBuildium ID: %@\n\nFound with My CSP", listing.address, self.availableLabel.text, listing.unitID.stringValue, listing.buildiumID.stringValue] isHTML:NO];
            
            // Present message for aproval/action
            [self presentViewController:mailView animated:NO completion:nil];
        } else {
            
            // Alert user they can't send email
            UIAlertView *noMail = [[UIAlertView alloc] initWithTitle:@"Cannot send mail" message:@"Your device is not configured with a mail account" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [noMail show];
        }
    }
}

#pragma mark - MailCompose View Delegate


// Called when MailView closes
// Can determine result and react to sent or canceled message
// We just want to close it and be done
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - General


// Adds gestures to the imageView
-(void)addGestures{
    
    // Tap gesture to display Preview
    UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewImage:)];
    [self.imageView addGestureRecognizer:tapImage];
    
    
    // Initialize swipe gestures for left and right, set selectors, and assign delegates
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)];
    [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [leftSwipe setDelegate:self];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)];
    [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [rightSwipe setDelegate:self];
    
    // Assign swipe gesture recognizers to imageView
    [self.imageView addGestureRecognizer:rightSwipe];
    [self.imageView addGestureRecognizer:leftSwipe];
    
}


// Returns formatted String for each Amenity key
-(NSString *)stringForKey:(NSString *)key{
    NSString *ret;
    if ([key isEqualToString:@"heat"]){
        ret = [features objectForKey:key];
    } else if ([key isEqualToString:@"sqft"]){
        ret = [NSString stringWithFormat:@"%@ Sqft.", [features objectForKey:key]];
    } else if ([key isEqualToString:@"airConditioning"]){
        ret = @"Air Conditioning";
    } else if ([key isEqualToString:@"balcony"]){
        ret = @"Balcony/Deck/Patio";
    } else if ([key isEqualToString:@"cable"]){
        ret = @"Cable Ready";
    } else if ([key isEqualToString:@"carport"]){
        ret = @"Carport";
    } else if ([key isEqualToString:@"dishwasher"]){
        ret = @"Dishwasher";
    } else if ([key isEqualToString:@"fenced"]){
        ret = @"Fenced Yard";
    } else if ([key isEqualToString:@"fireplace"]){
        ret = @"Fireplace";
    } else if ([key isEqualToString:@"garage"]){
        ret = @"Garage Parking";
    } else if ([key isEqualToString:@"hardwood"]){
        ret = @"Hardwood Floors";
    } else if ([key isEqualToString:@"internet"]){
        ret = @"High Speed Internet";
    } else if ([key isEqualToString:@"laundry"]){
        ret = @"Laundry / Hookups";
    } else if ([key isEqualToString:@"microwave"]){
        ret = @"Microwave";
    } else if ([key isEqualToString:@"oven"]){
        ret = @"Oven / Range";
    } else if ([key isEqualToString:@"refrigerator"]){
        ret = @"Refrigerator";
    } else if ([key isEqualToString:@"walkCloset"]){
        ret = @"Walk In Closet";
    }
    
    return ret;
}


// Sets the listing and saves the current favorite value
-(void)passListing:(Listing *)listingIn{
    listing = listingIn;
    wasFav = listing.favorite;
}


// Does what it says and updates Favorite button accordingly
-(void)toggleFavorite{
    if (listing.favorite){
        UIButton *favButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [favButton setImage:[UIImage imageNamed:@"blueStarEmpty"] forState:UIControlStateNormal];
        [favButton addTarget:self action:@selector(toggleFavorite) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *favBarButton = [[UIBarButtonItem alloc] initWithCustomView:favButton];
        [self.navigationItem setRightBarButtonItem:favBarButton];
    } else {
        UIButton *favButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [favButton setImage:[UIImage imageNamed:@"blueStar"] forState:UIControlStateNormal];
        [favButton addTarget:self action:@selector(toggleFavorite) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *favBarButton = [[UIBarButtonItem alloc] initWithCustomView:favButton];
        [self.navigationItem setRightBarButtonItem:favBarButton];
    }
    listing.favorite = !listing.favorite;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return NO;
}



// This took a lot of thought and effort, and I don't have the heart to delete it
/*
 - (IBAction)detectPan:(UIPanGestureRecognizer *)recognizer {
 if (recognizer.state == UIGestureRecognizerStateEnded){
 if (self.deltaY < 0){
 NSLog(@"Map Height: %f", self.mapView.bounds.size.height);
 [UIView animateWithDuration:0.3 animations:^{
 self.dragView.frame = CGRectMake(recognizer.view.frame.origin.x, self.ceil, recognizer.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height - self.ceil);
 } completion:^(BOOL finished){
 [UIView animateWithDuration:0.1 animations:^{
 self.mapView.frame = CGRectMake(0, self.selector.frame.size.height, recognizer.view.frame.size.width, recognizer.view.frame.size.height - self.selector.frame.size.height);
 self.infoView.frame = CGRectMake(0, self.selector.frame.size.height, self.infoView.frame.size.width, self.dragView.frame.size.height - self.selector.frame.size.height);
 } completion:^(BOOL finished){
 [UIView animateWithDuration:0.1 animations:^{
 self.featuresCollection.bounds = CGRectMake(self.featuresCollection.bounds.origin.x, self.featuresCollection.bounds.origin.y, self.featuresCollection.bounds.size.width, self.infoView.bounds.size.height - self.featuresCollection.frame.origin.y);
 self.featuresCollection.frame = CGRectMake(self.featuresCollection.frame.origin.x, self.detailText.frame.origin.y + self.detailText.frame.size.height + 8, self.featuresCollection.bounds.size.width, self.featuresCollection.bounds.size.height);
 }];
 }];
 }];
 [self.featuresCollection setScrollEnabled:YES];
 } else {
 [self.featuresCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
 [UIView animateWithDuration:0.3 animations:^{
 self.dragView.frame = CGRectMake(recognizer.view.frame.origin.x, self.floor, recognizer.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height - self.floor);
 } completion:^(BOOL finished){
 [UIView animateWithDuration:0.1 animations:^{
 self.mapView.frame = CGRectMake(0, self.selector.frame.size.height, recognizer.view.frame.size.width, recognizer.view.frame.size.height - self.selector.frame.size.height);
 self.emailView.frame = CGRectMake(0, self.selector.frame.size.height, self.emailView.frame.size.width, self.dragView.frame.size.height - self.selector.frame.size.height);
 self.infoView.frame = CGRectMake(0, self.selector.frame.size.height, self.infoView.frame.size.width, self.dragView.frame.size.height - self.selector.frame.size.height);
 } completion:^(BOOL finished){
 [UIView animateWithDuration:0.1 animations:^{
 self.featuresCollection.bounds = CGRectMake(self.featuresCollection.bounds.origin.x, self.featuresCollection.bounds.origin.y, self.featuresCollection.bounds.size.width, self.infoView.bounds.size.height - self.featuresCollection.frame.origin.y);
 self.featuresCollection.frame = CGRectMake(self.featuresCollection.frame.origin.x, self.detailText.frame.origin.y + self.detailText.frame.size.height + 8, self.featuresCollection.bounds.size.width, self.featuresCollection.bounds.size.height);
 }];
 }];
 }];
 [self.featuresCollection setScrollEnabled:NO];
 
 }
 } else {
 CGPoint translation = [recognizer translationInView:self.dragView];
 self.deltaY = translation.y;
 if (self.deltaY != 0){
 
 if (recognizer.view.frame.origin.y + translation.y <= self.ceil){
 self.dragView.frame = CGRectMake(recognizer.view.frame.origin.x, self.ceil, recognizer.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height - self.ceil);
 } else if (recognizer.view.frame.origin.y + translation.y >= self.floor){
 self.dragView.frame = CGRectMake(recognizer.view.frame.origin.x, self.floor, recognizer.view.frame.size.width, [[UIScreen mainScreen] bounds].size.height - self.floor);
 } else {
 self.dragView.frame = CGRectMake(recognizer.view.frame.origin.x, recognizer.view.frame.origin.y + translation.y, recognizer.view.frame.size.width, recognizer.view.frame.size.height - translation.y);
 }
 }
 }
 
 }
 */

@end

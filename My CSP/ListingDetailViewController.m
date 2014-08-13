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

@implementation ListingDetailViewController

dispatch_queue_t moreimages() {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t queue;
    dispatch_once(&queueCreationGuard, ^{
        queue = dispatch_queue_create("com.push.mycsp.newimages", 0);
    });
    return queue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.listing){
        [self passListing:[(ListingTableNavigationController*)self.navigationController single]];
        [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)]];
    }
    
    [self.featuresCollection setDataSource:self];
    [self.featuresCollection setDelegate:self];
    // Do any additional setup after loading the view.
    
    [self setTitle:@"C.S.P. Managment"];
    self.imgPos = 0;
    self.previews = [[NSMutableArray alloc] init];
    
    UIButton *favButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    if (self.listing.favorite){
        [favButton setImage:[UIImage imageNamed:@"blueStar"] forState:UIControlStateNormal];
    } else {
        [favButton setImage:[UIImage imageNamed:@"blueStarEmpty"] forState:UIControlStateNormal];
    }
    [favButton addTarget:self action:@selector(toggleFavorite) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL isDir;
    NSError *saveError;
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *imgDir = [directory stringByAppendingPathComponent:@"PropImages"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imgDir isDirectory:&isDir]){
        if (!isDir){
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

    
    if (self.listing.imageSrc.count == self.listing.imageArray.count && self.listing.imageSrc.count > 1){
        [self.pageIndicator setNumberOfPages:self.listing.imageArray.count];
        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)];
        [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
        [leftSwipe setDelegate:self];
        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)];
        [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
        [rightSwipe setDelegate:self];
        
        [self.imageView addGestureRecognizer:rightSwipe];
        [self.imageView addGestureRecognizer:leftSwipe];
        [self.imageView setUserInteractionEnabled:YES];
        for (UIImage *image in self.listing.imageArray){
            NSString *imgURL = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"png"];
            [UIImagePNGRepresentation(image) writeToFile:[imgDir stringByAppendingPathComponent:imgURL] atomically:YES];
            ListingPreview *preview = [[ListingPreview alloc] init];
            NSString *filePath = [imgDir stringByAppendingPathComponent:imgURL];
            preview.previewItemURL = [NSURL fileURLWithPath:filePath];
            [self.previews addObject:preview];
        }
    } else if (self.listing.imageSrc.count > 1){
        [self.pageIndicator setNumberOfPages:self.listing.imageArray.count];
        [self.activity setHidden:NO];
        [self.loadingView setHidden:NO];
        [self.loadingView.layer setCornerRadius:10];
        [self.loadingView setClipsToBounds:YES];
        [self.imageView setUserInteractionEnabled:NO];
        NSString *imgURLString = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"png"];
        [UIImagePNGRepresentation(self.listing.imageArray[0]) writeToFile:[imgDir stringByAppendingPathComponent:imgURLString] atomically:YES];
        ListingPreview *preview = [[ListingPreview alloc] init];
        NSString *filePath = [imgDir stringByAppendingPathComponent:imgURLString];
        preview.previewItemURL = [NSURL fileURLWithPath:filePath];
        [self.previews addObject:preview];
        dispatch_async(moreimages(), ^{
            for (int i = 1; i < self.listing.imageSrc.count; i++){
                NSURL *imgUrl = [[NSURL alloc] initWithString:[self.listing.imageSrc objectAtIndex:i]];
                NSLog(@"%@", [[NSDate alloc] init]);
                NSData *imageData = [[NSData alloc] initWithContentsOfURL:imgUrl];
                NSLog(@"%@", [[NSDate alloc] init]);
                UIImage *newImage;
                if (imageData){
                    newImage = [UIImage imageWithData:imageData];
                } else {
                    newImage = [UIImage imageNamed:@"default.png"];
                }
                [self.listing.imageArray addObject:newImage];
                NSString *imgURLString = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"png"];
                [UIImagePNGRepresentation(newImage) writeToFile:[imgDir stringByAppendingPathComponent:imgURLString] atomically:YES];
                ListingPreview *preview = [[ListingPreview alloc] init];
                NSString *filePath = [imgDir stringByAppendingPathComponent:imgURLString];
                preview.previewItemURL = [NSURL fileURLWithPath:filePath];
                [self.previews addObject:preview];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pageIndicator setNumberOfPages:self.listing.imageArray.count];
                    if (self.listing.imageArray.count == self.listing.imageSrc.count){
                        [self.imageView setUserInteractionEnabled:YES];
                        [self.loadingView setHidden:YES];
                        [self.activity setHidden:YES];
                        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)];
                        [leftSwipe setDirection:UISwipeGestureRecognizerDirectionLeft];
                        [leftSwipe setDelegate:self];
                        UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)];
                        [rightSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
                        [rightSwipe setDelegate:self];
                        
                        [self.imageView addGestureRecognizer:rightSwipe];
                        [self.imageView addGestureRecognizer:leftSwipe];
                    }
                });
            }
        });
    } else {
        [self.pageIndicator setHidden:YES];
        [self.imageView setUserInteractionEnabled:YES];
        if (self.listing.imageSrc.count != 0){
            NSString *imgURL = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"png"];
            if (self.listing.imageArray.count != 0){
                [UIImagePNGRepresentation(self.listing.imageArray[0]) writeToFile:[imgDir stringByAppendingPathComponent:imgURL] atomically:YES];
                ListingPreview *preview = [[ListingPreview alloc] init];
                NSString *filePath = [imgDir stringByAppendingPathComponent:imgURL];
                preview.previewItemURL = [NSURL fileURLWithPath:filePath];
                [self.previews addObject:preview];
            }
        }
    }
    
    UIBarButtonItem *favBarButton = [[UIBarButtonItem alloc] initWithCustomView:favButton];
    [self.navigationItem setRightBarButtonItem:favBarButton];
    
    if (self.listing.imageArray.count > 0){
        [self.imageView setImage:[self.listing.imageArray objectAtIndex:0]];
    } else {
        [self.imageView setImage:[UIImage imageNamed:@"default.png"]];
    }
    [self.bottomImage setImage:[UIImage imageWithCGImage:self.imageView.image.CGImage scale:self.imageView.image.scale orientation:UIImageOrientationDownMirrored]];
    [self.imageView setClipsToBounds:YES];
    
    if (self.listing.imageSrc.count != 0){
        UITapGestureRecognizer *tapImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(previewImage:)];
        [self.imageView addGestureRecognizer:tapImage];
    }
    
    [self.view layoutIfNeeded];

    NSString *address = self.listing.address;
    address = [address componentsSeparatedByString:@":"][0];
    address = [address stringByReplacingOccurrencesOfString:@"Road" withString:@"Rd."];
    address = [address stringByReplacingOccurrencesOfString:@"Drive" withString:@"Dr."];
    address = [address stringByReplacingOccurrencesOfString:@"Street" withString:@"St."];
    address = [address stringByReplacingOccurrencesOfString:@"Court" withString:@"Ct."];
    address = [address stringByReplacingOccurrencesOfString:@"Avenue" withString:@"Ave."];
    address = [address stringByReplacingOccurrencesOfString:@"Lane" withString:@"Ln."];
    address = [address stringByReplacingOccurrencesOfString:@"Place" withString:@"Pl."];
    address = [address stringByReplacingOccurrencesOfString:@"North" withString:@"N."];
    address = [address stringByReplacingOccurrencesOfString:@"South" withString:@"S."];
    address = [address stringByReplacingOccurrencesOfString:@"East" withString:@"E."];
    address = [address stringByReplacingOccurrencesOfString:@"West" withString:@"W."];
    address = [address stringByReplacingOccurrencesOfString:@", NY" withString:@" NY,"];
    [self.townLabel setText:[address componentsSeparatedByString:@","][1]];
    [self.townLabel setText:[self.townLabel.text stringByReplacingOccurrencesOfString:@" NY" withString:@", NY"]];
    address = [address componentsSeparatedByString:@","][0];
    /*
     iOS 8
    if (![address containsString:@"Apt"] && ![address containsString:@"Room"] && ![address containsString:@"Terrace"] && [address containsString:@"-"]){
    */
    if ([address rangeOfString:@"Apt"].location == NSNotFound && [address rangeOfString:@"Room"].location == NSNotFound && [address rangeOfString:@"Terrace"].location == NSNotFound && [address rangeOfString:@"-"].location != NSNotFound){
        address = [address stringByReplacingOccurrencesOfString:@"-" withString:@"- Unit"];
    }
    [self setTitle:[address componentsSeparatedByString:@"-"][0]];
    [self.addressLabel setText:address];
    MarqueeLabel *scrollLabel = [[MarqueeLabel alloc] initWithFrame:self.addressLabel.frame rate:20 andFadeLength:10];
    [scrollLabel setMarqueeType:MLContinuous];
    [scrollLabel setAnimationDelay:2];
    [scrollLabel setText:self.addressLabel.text];
    scrollLabel.font = self.addressLabel.font;
    scrollLabel.textColor = self.addressLabel.textColor;
    scrollLabel.continuousMarqueeExtraBuffer = 40;
    [self.infoView addSubview:scrollLabel];
    [self.addressLabel setHidden:YES];
    [self.rentLabel setText:[NSString stringWithFormat:@"$%@", self.listing.rent]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM. d YYYY"];
    [self.availableLabel setText:[NSString stringWithFormat:@"Available %@",[formatter stringFromDate:self.listing.available]]];
    
    [self.detailText setText:self.listing.descrip];
    self.detailText.preferredMaxLayoutWidth = 280;
    //[self.detailText setContentOffset:CGPointZero animated:YES];
    /*
    [self.scrollView setContentSize:CGSizeMake(self.mapView.frame.size.width, 600)];
    [self.infoView setBounds:CGRectMake(0, 0, self.mapView.frame.size.width, self.scrollView.contentSize.height)];
    */
    
    [self.infoView setBounds:CGRectMake(0, 0, self.scrollView.bounds.size.width, self.addressLabel.bounds.size.height + self.rentLabel.bounds.size.height + self.contactButton.bounds.size.height + 250 + 15 + 4 + 5)];
    
    if (self.listing.location == nil){
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:[NSString stringWithFormat:@"%@",self.listing.address] completionHandler:^(NSArray* placemarks, NSError* error){
            if (!error){
                self.listing.location = [(CLPlacemark *)[placemarks lastObject] location];
                
                [self.mapView setDelegate:self];
                MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
                [pin setTitle:address];
                //[pin setSubtitle:self.listing.area];
                [pin setCoordinate:self.listing.location.coordinate];
                [self.mapView addAnnotation:pin];
                MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.listing.location.coordinate, 750, 750);
                MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
                [self.mapView setRegion:adjustedRegion animated:YES];
            } else {
                NSLog(@"%@",self.listing.address);
                [self.selector setEnabled:noErr forSegmentAtIndex:2];
            }
        }];
    } else {
        [self.mapView setDelegate:self];
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        [pin setTitle:address];
        //[pin setSubtitle:self.listing.area];
        [pin setCoordinate:self.listing.location.coordinate];
        [self.mapView addAnnotation:pin];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(self.listing.location.coordinate, 750, 750);
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
    
    [self.blurView setBackgroundColor:[UIColor whiteColor]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //self.floor = self.dragView.frame.origin.y;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    if ((self.wasFav && !self.listing.favorite) || (!self.wasFav && self.listing.favorite)){
        NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *idFile = [directory stringByAppendingPathComponent:@"user.txt"];
        NSString *uuid = [NSKeyedUnarchiver unarchiveObjectWithFile:idFile];
        NSMutableArray *favorites = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:[directory stringByAppendingPathComponent:@"favs.txt"]]];
        if (self.listing.favorite){
            NSLog(@"UnitID: %@", self.listing.unitID.stringValue);
            if (![[RESTfulInterface RESTAPI] addUserFavorite:uuid :self.listing.unitID.stringValue]){
                NSLog(@"Failed saving Favorite");
            }
            if (![favorites containsObject:self.listing.unitID.stringValue]){
                [favorites addObject:self.listing.unitID.stringValue];
                [NSKeyedArchiver archiveRootObject:favorites toFile:[directory stringByAppendingPathComponent:@"favs.txt"]];
            }
        } else {
            if (![[RESTfulInterface RESTAPI] removeUserFavorite:uuid :self.listing.unitID.stringValue]){
                NSLog(@"Failed removing Favorite");
            }
            if ([favorites containsObject:self.listing.unitID.stringValue]){
                [favorites removeObject:self.listing.unitID.stringValue];
                [NSKeyedArchiver archiveRootObject:favorites toFile:[directory stringByAppendingPathComponent:@"favs.txt"]];
            }
        }
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/currentImage.png", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]]]){
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/currentImage.png", NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]] error:nil];
    }
    
    [super viewWillDisappear:animated];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    self.features = self.listing.features;
    return self.features.count + 2;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ListingFeatureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"featureCell" forIndexPath:indexPath];
    if (indexPath.row == 0){
        [cell.label setText:[NSString stringWithFormat:@"%@ Beds", self.listing.beds]];
        [cell.imageView setImage:[UIImage imageNamed:@"bed"]];
    } else if (indexPath.row == 1){
        [cell.label setText:[NSString stringWithFormat:@"%@ Baths", self.listing.baths]];
        [cell.imageView setImage:[UIImage imageNamed:@"bath"]];
    } else {
        [cell.label setText:[self stringForKey:[[self.features allKeys] objectAtIndex:indexPath.row - 2]]];
        [cell.imageView setImage:[UIImage imageNamed:[[self.features allKeys] objectAtIndex:indexPath.row - 2]]];
    }
    
    cell.bounds = CGRectMake(cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width, 110);
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 110);
}

-(NSString *)stringForKey:(NSString *)key{
    NSString *ret;
    if ([key isEqualToString:@"heat"]){
        ret = [self.features objectForKey:key];
    } else if ([key isEqualToString:@"sqft"]){
        ret = [NSString stringWithFormat:@"%@ Sqft.", [self.features objectForKey:key]];
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
- (IBAction)close:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) return nil;
    MKPinAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"String"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setImage:[UIImage imageNamed:@"carport"] forState:UIControlStateNormal];
    annotationView.leftCalloutAccessoryView = button;
    annotationView.enabled = YES;
    annotationView.annotation = annotation;
    annotationView.canShowCallout = YES;
    return annotationView;
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    // Create an MKMapItem to pass to the Maps app
    CLLocationCoordinate2D coordinate =
    CLLocationCoordinate2DMake(self.listing.location.coordinate.latitude, self.listing.location.coordinate.longitude);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                   addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.addressLabel.text];
    [mapItem openInMapsWithLaunchOptions:nil];
}

- (IBAction)previewImage:(id)sender{
    if (self.listing.imageSrc.count != 0){
        RotatingPreviewController *previewController=[[RotatingPreviewController alloc]init];
        previewController.delegate=self;
        previewController.dataSource=self;
        
        [previewController setCurrentPreviewItemIndex:self.imgPos];
        [self presentViewController:previewController animated:YES completion:nil];
        //[self.navigationController pushViewController:previewController animated:YES];

    }
}

-(NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return self.previews.count;
}

-(id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{

    [(ListingPreview *)[self.previews objectAtIndex:index] setPreviewItemTitle:[self.addressLabel.text stringByAppendingString:[NSString stringWithFormat:@" Img %d", (int)index + 1]]];
    
    return self.previews[index];
    
}

- (IBAction)changeImage:(UISwipeGestureRecognizer *)recognizer{
    if (self.listing.imageArray.count > 1){
        if (recognizer.direction == UISwipeGestureRecognizerDirectionRight){
            self.imgPos--;
            if (self.imgPos < 0){
                self.imgPos = (int)self.listing.imageArray.count - 1;
            }
            UIImageView *newView = [[UIImageView alloc] initWithFrame:CGRectMake(-self.imageView.frame.size.width, self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)];
            UIImageView *newBottom = [[UIImageView alloc] initWithFrame:CGRectMake(-self.bottomImage.frame.size.width, self.bottomImage.frame.origin.y, self.bottomImage.frame.size.width, self.bottomImage.frame.size.height)];
            [newView setImage:[self.listing.imageArray objectAtIndex:self.imgPos]];
            [newBottom setImage:[UIImage imageWithCGImage:newView.image.CGImage scale:newView.image.scale orientation:UIImageOrientationDownMirrored]];
            [newView setContentMode:UIViewContentModeScaleAspectFill];
            [newBottom setContentMode:UIViewContentModeScaleAspectFill];
            [newView setClipsToBounds:YES];
            [newBottom setClipsToBounds:YES];
            
            [self.imageView.superview insertSubview:newView aboveSubview:self.imageView];
            [self.bottomImage.superview insertSubview:newBottom aboveSubview:self.bottomImage];
            [UIView animateWithDuration:0.2f animations:^{
                newView.frame = CGRectOffset(newView.frame, newView.frame.size.width, 0);
                newBottom.frame = CGRectOffset(newBottom.frame, newBottom.frame.size.width, 0);
            } completion:^(BOOL finished){
                [self.imageView setImage:[self.listing.imageArray objectAtIndex:self.imgPos]];
                [self.bottomImage setImage:[UIImage imageWithCGImage:self.imageView.image.CGImage scale:self.imageView.image.scale orientation:UIImageOrientationDownMirrored]];
                [newView removeFromSuperview];
                [newBottom removeFromSuperview];
            }];
            
        } else {
            self.imgPos++;
            if (self.imgPos == self.listing.imageArray.count){
                self.imgPos = 0;
            }
            UIImageView *newView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
            UIImageView *newBottom = [[UIImageView alloc] initWithFrame:self.bottomImage.frame];
            [newView setImage:self.imageView.image];
            [newBottom setImage:[UIImage imageWithCGImage:newView.image.CGImage scale:newView.image.scale orientation:UIImageOrientationDownMirrored]];
            [newView setContentMode:UIViewContentModeScaleAspectFill];
            [newView setClipsToBounds:YES];
            [newBottom setContentMode:UIViewContentModeScaleAspectFill];
            [newBottom setClipsToBounds:YES];
            [self.imageView.superview insertSubview:newView aboveSubview:self.imageView];
            [self.bottomImage.superview insertSubview:newBottom aboveSubview:self.bottomImage];
            
            [self.imageView setImage:[self.listing.imageArray objectAtIndex:self.imgPos]];
            [self.bottomImage setImage:[UIImage imageWithCGImage:self.imageView.image.CGImage scale:self.imageView.image.scale orientation:UIImageOrientationDownMirrored]];
            
            [UIView animateWithDuration:0.2f animations:^{
                newView.frame = CGRectOffset(newView.frame, -newView.frame.size.width, 0);
                newBottom.frame = CGRectOffset(newBottom.frame, -newBottom.frame.size.width, 0);
            } completion:^(BOOL finished){
                [newView removeFromSuperview];
                [newBottom removeFromSuperview];
            }];
        }
    }
    [self.pageIndicator setCurrentPage:self.imgPos];
    //[self.imageView setImage:[self.listing.imageArray objectAtIndex:self.imgPos]];
}
- (IBAction)callCarol:(id)sender {
    UIActionSheet *contactAction = [[UIActionSheet alloc] initWithTitle:@"Contact CSP" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Call 607-277-6961", @"Email CSP Info", nil];
    [contactAction showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        NSString *phoneURL = [@"telprompt://" stringByAppendingString:@"6072776961"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
    } else if (buttonIndex == 1){
        if ([MFMailComposeViewController canSendMail]){
            MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
            [mailView setMailComposeDelegate:self];
            [mailView setSubject:[NSString stringWithFormat:@"Listing at %@", self.addressLabel.text]];
            [mailView setToRecipients:@[@"info@cspmanagement.com"]];
            [mailView setMessageBody:[NSString stringWithFormat:@"I'd like to speak to someone about this property.\nComments:\n\nProperty Details\nAddress: %@\n%@\nUnit ID: %@\nBuildium ID: %@\n\nFound with My CSP", self.listing.address, self.availableLabel.text, self.listing.unitID.stringValue, self.listing.buildiumID.stringValue] isHTML:NO];
            [self presentViewController:mailView animated:NO completion:nil];
        } else {
            UIAlertView *noMail = [[UIAlertView alloc] initWithTitle:@"Cannot send mail" message:@"Your device is not configured with a mail account" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [noMail show];
        }
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)passListing:(Listing *)listingIn{
    self.listing = listingIn;
    self.wasFav = self.listing.favorite;
}

- (IBAction)updateSubView:(id)sender {
    switch ([(UISegmentedControl *)sender selectedSegmentIndex]) {
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
-(void)toggleFavorite{
    if (self.listing.favorite){
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
    self.listing.favorite = !self.listing.favorite;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return NO;
}

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

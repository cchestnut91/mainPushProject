//
//  RotatingPreviewController.m
//  My CSP
//
//  Created by Calvin Chestnut on 8/12/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "RotatingPreviewController.h"

@interface RotatingPreviewController ()

@end


// Allows the QLPreviewController to be rotated into Landscape without any other view rotating into Landscape
@implementation RotatingPreviewController {
    // Bool to allow view to rotate
    BOOL rotate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Forces view to initialize in Portrait to avoid errors
    rotate = NO;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Once view has loaded allow rotating
    rotate = YES;
}

// Allow rotation or not from here
-(BOOL)shouldAutorotate
{
    return rotate;
}

// Allow any orientation other than upside down
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// Allow any orientation other than upside down
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end

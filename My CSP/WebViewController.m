//
//  WebViewController.m
//  My CSP
//
//  Created by Calvin Chestnut on 8/11/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

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
    // Do any additional setup after loading the view.
    
    
    // Initialize webview
    [self.webView setDelegate:self];
    
    self.request = [[NSURLRequest alloc] initWithURL:self.url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    // Load request passed from the previous view
    [self.webView loadRequest:self.request];
}

// Creates and displays an action sheet asking if the user wants to open the current page in the browser
- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Open page in Safari?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Confirm", nil];
    [action showFromBarButtonItem:self.actionButton animated:YES];
}

// Responds to action sheet selection
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    // If user clicked YES
    if (buttonIndex == 0){
        
        // Open the URL in Safari
        [[UIApplication sharedApplication] openURL:self.webView.request.URL];
    }
}

@end

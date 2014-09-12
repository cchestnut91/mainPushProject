//
//  WebViewController.h
//  My CSP
//
//  Created by Calvin Chestnut on 8/11/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <
    UIActionSheetDelegate,
    UIWebViewDelegate
>

// Actual webview part
@property (weak, nonatomic) IBOutlet UIWebView *webView;

// Holds the URL request
@property (strong, nonatomic) NSURLRequest *request;

@property(strong, nonatomic) NSURL *url;

// Action button used as an anchor for the ActionSheet
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;

// Displays a confirmation action sheet to open in safari
- (IBAction)showActionSheet:(id)sender;

@end

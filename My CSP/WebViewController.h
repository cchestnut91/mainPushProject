//
//  WebViewController.h
//  My CSP
//
//  Created by Calvin Chestnut on 8/11/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIActionSheetDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSURLRequest *request;
- (IBAction)showActionSheet:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;

@end

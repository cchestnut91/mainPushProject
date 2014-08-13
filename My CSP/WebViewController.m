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
    
    [self.webView setDelegate:self];
    [self.webView loadRequest:self.request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showActionSheet:(id)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"Open page in Safari?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Confirm", nil];
    [action showFromBarButtonItem:self.actionButton animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        [[UIApplication sharedApplication] openURL:self.webView.request.URL];
    }
}

@end

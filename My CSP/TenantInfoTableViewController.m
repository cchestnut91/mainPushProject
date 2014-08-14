//
//  TenantInfoTableViewController.m
//  My CSP
//
//  Created by Calvin Chestnut on 8/11/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "TenantInfoTableViewController.h"

@interface TenantInfoTableViewController ()

@end

@implementation TenantInfoTableViewController {
    
    // Holds the URL the user selects to send to a webView
    NSString *selectedURL;
    
    // Title the webview should have
    NSString *titleString;
}

#pragma mark-Table View Delegate

// Handles user selection of a table cell
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
            
        // User clicked in CSP Log In section
        case 0:
            
            // Only one option here. Sets the selected URL and Title and opens the webViewController
            switch (indexPath.row) {
                case 0:
                    selectedURL = @"https://cspmgmt.managebuilding.com/";
                    titleString = @"CSP Login";
                    [self performSegueWithIdentifier:@"openWebview" sender:self];
                    break;
                    
                default:
                    break;
            }
            
            break;
        
            
        // User selected the NYSEG section
        case 1:
            
            switch (indexPath.row) {
                    
                // Opens their website in the Webview
                case 0:
                    selectedURL = @"http://www.nyseg.com/";
                    titleString = @"NYSEG";
                    [self performSegueWithIdentifier:@"openWebview" sender:self];
                    break;
                
                // Performs a call to their support number
                // There are two different URLS for a phone call
                // tel:// Places the call automatically, and when the call is ended will remain in the Phone app
                // telprompt:// brings up an uneditable confirmation "Place call to xxx-xxx-xxxx?" but will return to the app that send the URL when the call is ended
                // temprompt is usually always preferred
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://18005721111"]];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
            
        // User selected Ithaca Water Section
        case 2:
            
            switch (indexPath.row) {
                    
                // Open website in webview
                case 0:
                    selectedURL = @"http://www.cityofithaca.org/departments/dpw/water/index.cfm";
                    titleString = @"Ithaca Water and Sewer";
                    [self performSegueWithIdentifier:@"openWebview" sender:self];
                    break;
                    
                    
                // Place call to their typical number
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telpromopt://6072721717"]];
                    break;
                    
                    
                // Place call to their emergency number
                case 3:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telpromopt://6072734680"]];
                    break;
                    
                default:
                    break;
            }
            
            break;
        
            
        // I don't think we really need to comment all of these....
        case 3:
            
            switch (indexPath.row) {
                case 0:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telpromopt://6072723245"]];
                    break;
                case 1:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telpromopt://6072729973"]];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 4:
            
            switch (indexPath.row) {
                case 0:
                    selectedURL = @"http://www.cityofithaca.org/";
                    titleString = @"City of Ithaca";
                    [self performSegueWithIdentifier:@"openWebview" sender:self];
                    break;
                    
                case 1:
                {
                    
                    // Opens up the address in the Maps app
                    NSString *mapsURL = @"http://maps.apple.com/?q=108+E+Green+Street,+Ithaca,+NY";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsURL]];
                }
                    break;
                    
                case 2:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://6072746501"]];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
}

#pragma mark-Close View


// Guess what this does. Go on. Guess
- (IBAction)close:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-Segue Prep


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Check that segue is leading to the WebViewController
    if ([segue.identifier isEqualToString:@"openWebview"]){
        
        // Set request for webview
        [(WebViewController *)segue.destinationViewController setRequest:[[NSURLRequest alloc] initWithURL: [NSURL URLWithString: selectedURL] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:10]];
        
        // Set title for webViewController
        [segue.destinationViewController setTitle:titleString];
    }
}


@end

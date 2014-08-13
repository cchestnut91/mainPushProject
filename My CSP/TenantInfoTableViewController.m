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
    NSString *phoneURL;
    NSString *titleString;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
- (IBAction)close:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
            
            switch (indexPath.row) {
                case 0:
                    self.selectedURL = @"https://cspmgmt.managebuilding.com/";
                    titleString = @"CSP Login";
                    [self performSegueWithIdentifier:@"openWebview" sender:self];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 1:
            
            switch (indexPath.row) {
                case 0:
                    self.selectedURL = @"http://www.nyseg.com/";
                    titleString = @"NYSEG";
                    [self performSegueWithIdentifier:@"openWebview" sender:self];
                    break;
                
                case 1:
                    phoneURL = @"telprompt://18005721111";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 2:
            
            switch (indexPath.row) {
                case 0:
                    self.selectedURL = @"http://www.cityofithaca.org/departments/dpw/water/index.cfm";
                    titleString = @"Ithaca Water and Sewer";
                    [self performSegueWithIdentifier:@"openWebview" sender:self];
                    break;
                    
                case 1:
                    phoneURL = @"telpromopt://6072721717";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
                    break;
                    
                case 3:
                    phoneURL = @"telpromopt://6072734680";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
                    break;
                    
                default:
                    break;
            }
            
            break;
        
        case 3:
            
            switch (indexPath.row) {
                case 0:
                    phoneURL = @"telpromopt://6072723245";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
                    break;
                case 1:
                    phoneURL = @"telpromopt://6072729973";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        case 4:
            
            switch (indexPath.row) {
                case 0:
// Open www.cityofithaca.org
                    self.selectedURL = @"http://www.cityofithaca.org/";
                    titleString = @"City of Ithaca";
                    [self performSegueWithIdentifier:@"openWebview" sender:self];
                    break;
                    
                case 1:
// Open maps 108 East Green Street, Ithaca NY 14850
                {
                    NSString *mapsURL = @"http://maps.apple.com/?q=108+E+Green+Street,+Ithaca,+NY";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsURL]];
                }
                    break;
                    
                case 2:
// Call 607-274-6501
                    phoneURL = @"telprompt://6072746501";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneURL]];
                    break;
                    
                default:
                    break;
            }
            
            break;
            
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"openWebview"]){
        [(WebViewController *)segue.destinationViewController setRequest:[[NSURLRequest alloc] initWithURL: [NSURL URLWithString: self.selectedURL] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:10]];
        [segue.destinationViewController setTitle:titleString];
    }
}


@end

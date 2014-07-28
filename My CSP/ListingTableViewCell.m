//
//  ListingTableViewCell.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/8/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "ListingTableViewCell.h"

@implementation ListingTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

-(void)passListing:(Listing *)listingIn{
    [self.backgroundImageView setClipsToBounds:YES];
    if (listingIn.imageArray.count > 0){
        [self.backgroundImageView setImage:[[listingIn imageArray] objectAtIndex:0]];
    } else {
        [self.backgroundImageView setImage:[UIImage imageNamed:@"default.jpg"]];
    }
    if (listingIn.beds == NULL){
        [self.bedLabel setText:@"No Info"];
    } else {
        NSLog(@"%@", listingIn.beds.class);
        if (listingIn.beds.intValue == 1){
            [self.bedLabel setText:[NSString stringWithFormat:@"%@ Bedroom",listingIn.beds]];
        } else {
            [self.bedLabel setText:[NSString stringWithFormat:@"%@ Bedrooms",listingIn.beds]];
        }
    }
    
    NSString *address = listingIn.address;
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
    address = [address componentsSeparatedByString:@","][0];
    if (![address containsString:@"Apt"] && ![address containsString:@"Room"] && ![address containsString:@"Terrace"] && [address containsString:@"-"]){
        address = [address stringByReplacingOccurrencesOfString:@"-" withString:@"- Unit"];
    }
    [self.addressLabel setText:address];
    [self.rentLabel setText:[NSString stringWithFormat:@"$%@",listingIn.rent]];
    
    /*
    // Blur effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self.effectView setClipsToBounds:YES];
    [self.effectView setFrame:self.barView.bounds];
    [self.barView addSubview:self.effectView];
    [self.barView sendSubviewToBack:self.effectView];
    [self.barView setClipsToBounds:YES];
    */
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted){
        [self.barView setBackgroundColor:[UIColor colorWithRed:51/255.0 green:60/255.0 blue:77/255.0 alpha:.6]];
    } else {
        [self.barView setBackgroundColor:[UIColor colorWithRed:51/255.0 green:60/255.0 blue:77/255.0 alpha:.9]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected){
        [self.barView setBackgroundColor:[UIColor colorWithRed:51/255.0 green:60/255.0 blue:77/255.0 alpha:.9]];
    } else {
        [self.barView setBackgroundColor:[UIColor colorWithRed:51/255.0 green:60/255.0 blue:77/255.0 alpha:.9]];
    }
    
}

@end

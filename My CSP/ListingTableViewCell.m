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


// Takes in a Listing and sets UI elemets appropriately
// Functions as initializer
-(void)passListing:(Listing *)listingIn{
    
    // Make sure background view doesn't allow image to extend beyond borders
    [self.backgroundImageView setClipsToBounds:YES];
    
    // If Listing has loaded images to display
    if ([listingIn.property firstImage]){
        
        // Display the first one in the background view
        [self.backgroundImageView setImage:[[listingIn property] firstImage]];
    } else {
        
        // Display the default "No Images" image formatted for the cell
        [self.backgroundImageView setImage:[UIImage imageNamed:@"defaultWide.png"]];
    }
    
    // If no info for number of Beds show the appropriate label
    if (listingIn.beds == NULL){
        [self.bedLabel setText:@"No Info"];
    } else {
        
        // Set number of beds label to appropriate value with plural if necessary
        if (listingIn.beds.intValue == 1){
            [self.bedLabel setText:[NSString stringWithFormat:@"%@ Bedroom",listingIn.beds]];
        } else {
            [self.bedLabel setText:[NSString stringWithFormat:@"%@ Bedrooms",listingIn.beds]];
        }
    }
    
    
    // Get short version of address to display
    NSString *address = listingIn.addressShort;
    
    // Cleaner if statement, requires iOS 8
    /*
     iOS 8
     if (![address containsString:@"Apt"] && ![address containsString:@"Room"] && ![address containsString:@"Terrace"] && [address containsString:@"-"]){
     */
    
    // This if statement eliminates confusing addresses like "101 Main Street - 1" with "101 Main Street - Unit 1"
    // This will not apply if there is already a clarifier such as
    // "101 Main Street Apt 1"
    
    // If address doesn't contain "Apt", "Room" or "Terrace" but includes "-"
    if ([address rangeOfString:@"Apt"].location == NSNotFound && [address rangeOfString:@"Room"].location == NSNotFound && [address rangeOfString:@"Terrace"].location == NSNotFound && [address rangeOfString:@"-"].location != NSNotFound){
        
        // Add unit clarification
        address = [address stringByReplacingOccurrencesOfString:@"-" withString:@"- Unit"];
    }
    
    [self.addressLabel setText:address];
    
    
    // Set rent label text
    [self.rentLabel setText:[NSString stringWithFormat:@"$%@",listingIn.rent]];
    
}


// Overrides highlighted and selected behavious
// Default behavior brings the imageView to the front of the view and makes the infoBar invisible on Select or Highlight
// This override forces the barView to remain visible
// Will also change the opacity value on highlight to create distinction between selected and unselected apperance
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
    
    [self.barView setBackgroundColor:[UIColor colorWithRed:51/255.0 green:60/255.0 blue:77/255.0 alpha:.9]];
    
}

@end

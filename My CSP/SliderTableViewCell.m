//
//  SliderTableViewCell.m
//  My CSP
//
//  Created by Calvin Chestnut on 7/15/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "SliderTableViewCell.h"

@implementation SliderTableViewCell

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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

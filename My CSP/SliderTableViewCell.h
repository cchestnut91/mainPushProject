//
//  SliderTableViewCell.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/15/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SliderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *rangeLabel;
@property (weak, nonatomic) IBOutlet UISlider *rangeSlider;

@end

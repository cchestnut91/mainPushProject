//
//  SelectorTableViewCell.h
//  My CSP
//
//  Created by Calvin Chestnut on 7/24/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectorTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selector;

@end

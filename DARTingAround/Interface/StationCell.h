//
//  StationCell.h
//  DARTingAround
//
//  Created by Barry Scott on 20/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StationCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *favouriteImage;

@end

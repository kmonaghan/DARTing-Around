//
//  JourneyCell.h
//  DARTingAround
//
//  Created by Barry Scott on 20/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JourneyCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *destinationLabel;
@property (nonatomic, strong) IBOutlet UILabel *dueInLabel;
@property (nonatomic, strong) IBOutlet UILabel *directionLabel;
@property (nonatomic, strong) IBOutlet UILabel *departTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *lateLabel;

@end

//
//  JourneyCell.m
//  DARTingAround
//
//  Created by Barry Scott on 20/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "JourneyCell.h"

@implementation JourneyCell

@synthesize destinationLabel;
@synthesize dueInLabel;
@synthesize directionLabel;
@synthesize departTimeLabel;
@synthesize lateLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
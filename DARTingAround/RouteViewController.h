//
//  RouteViewController.h
//  DARTingAround
//
//  Created by Barry Scott on 28/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IrishRailDataManager.h"
#import "Journey.h"

@interface RouteViewController : UITableViewController

@property (nonatomic, retain) IrishRailDataManager *railDataManager;
@property (nonatomic, strong) Journey *detailJourney;

@end

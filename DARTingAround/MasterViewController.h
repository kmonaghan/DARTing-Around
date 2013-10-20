//
//  MasterViewController.h
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IrishRailDataManager.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (nonatomic, strong) DetailViewController *detailViewController;
@property (nonatomic, retain) IrishRailDataManager *railDataManager;

@end

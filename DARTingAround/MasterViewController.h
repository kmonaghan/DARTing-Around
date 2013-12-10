//
//  MasterViewController.h
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;
@class IrishRailDataManager;

@interface MasterViewController : UITableViewController

@property (nonatomic, strong) DetailViewController *detailViewController;
@property (nonatomic, retain) IrishRailDataManager *railDataManager;

- (IBAction)tapInfoButton:(id)sender;

@end

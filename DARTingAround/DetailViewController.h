//
//  DetailViewController.h
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Station.h"
#import "IrishRailDataManager.h"

@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate>

@property (nonatomic, retain) IrishRailDataManager *railDataManager;
@property (nonatomic, strong) Station *detailStation;

@property (strong, nonatomic) IBOutlet UIView *directionView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *directionSegmentedController;

- (IBAction)directionSegmentWasPicked:(id)sender;

@end

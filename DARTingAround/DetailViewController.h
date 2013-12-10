//
//  DetailViewController.h
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Station;
@class IrishRailDataManager;

@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate>

@property (nonatomic, retain) IrishRailDataManager *railDataManager;
@property (nonatomic, strong) Station *detailStation;

@property (strong, nonatomic) IBOutlet UIView *directionView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *directionSegmentedController;

@property (strong, nonatomic) IBOutlet UIView *stopwatchView;
@property (strong, nonatomic) IBOutlet UITextField *stopwatchTime;
@property (strong, nonatomic) IBOutlet UIButton *stopwatchGoButton;

- (IBAction)directionSegmentWasPicked:(id)sender;
- (IBAction)tapStopwatchGoButton:(id)sender;

@end

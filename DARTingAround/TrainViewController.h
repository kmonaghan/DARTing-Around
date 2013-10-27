//
//  TrainViewController.h
//  DARTingAround
//
//  Created by Barry Scott on 25/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IrishRailDataManager.h"
#import "Journey.h"
#import <MapKit/MapKit.h>

@interface TrainViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) Journey *detailJourney;
@property (nonatomic, retain) IrishRailDataManager *railDataManager;
@property (strong, nonatomic) IBOutlet MKMapView *trainMapView;

@end

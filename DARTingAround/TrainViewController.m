//
//  TrainViewController.m
//  DARTingAround
//
//  Created by Barry Scott on 25/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "TrainViewController.h"
#import <TSMessages/TSMessage.h>

@interface TrainViewController () <IrishRailDataManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) Train *detailTrain;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end


@implementation TrainViewController

#pragma mark - Managing the detail item

- (void)setDetailJourney:(Journey *)newDetailJourney
{
    LogIt(@"setDetailJourney");
    if (_detailJourney != newDetailJourney) {
        _detailJourney = newDetailJourney;
        // Update the view
        self.title = _detailJourney.journeyTrainCode;
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)refreshData {
    LogIt(@"refreshData");
    if (_detailJourney)
        [self.railDataManager fetchDataForTrain:_detailJourney.journeyTrainCode];
}

- (void)updateInterface {
    LogIt(@"updateInterface");
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.publicMessageLabel.text = self.detailTrain.trainPublicMessage;
//        [self.publicMessageWebView loadHTMLString:self.detailTrain.trainPublicMessage baseURL:nil];
        // Add a map annotation for the train
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = [self.detailTrain.trainLocation coordinate];
        point.title = self.detailTrain.trainCode;
        point.subtitle = self.detailTrain.trainDirection;
        //
        [self.trainMapView addAnnotation:point];
    });
}

#pragma mark - IrishRailDataManagerDelegate Methods

- (void)receivedTrainData:(Train *)trainData {
    LogIt(@"receivedTrainData");
    [TSMessage dismissActiveNotification];
    //
    if (trainData) {
        _detailTrain = trainData;
        [self updateInterface];
    }
    else {
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Nothing found"
                                           subtitle:@"I couldn't find any data for that train, sorry. Please try again."
                                               type:TSMessageNotificationTypeError
                                           duration:3.0
                                           callback:^{}
                                        buttonTitle:nil
                                     buttonCallback:^{}
                                         atPosition:TSMessageNotificationPositionTop
                                canBeDismisedByUser:YES];
    }
}

#pragma mark - Standard Methods

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    LogIt(@"initWithNibName");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    LogIt(@"viewDidLoad");
    [super viewDidLoad];
	//
    self.railDataManager = [IrishRailDataManager new];
    self.railDataManager.delegate = self;
    //
    self.trainMapView.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    LogIt(@"viewDidAppear");
    [super viewDidAppear:animated];
    [TSMessage showNotificationInViewController:self.navigationController
                                          title:@"Searching..."
                                       subtitle:@"I'm calling the fat controller to get data on this train and journey."
                                           type:TSMessageNotificationTypeWarning
                                       duration:0.0
                                       callback:^{}
                                    buttonTitle:nil
                                 buttonCallback:^{}
                                     atPosition:TSMessageNotificationPositionTop
                            canBeDismisedByUser:NO];
    //
    [self refreshData];
}

- (void)viewWillDisappear:(BOOL)animated {
    LogIt(@"viewWillDisappear");
    [super viewWillDisappear:animated];
    [TSMessage dismissActiveNotification];
}

- (void)didReceiveMemoryWarning
{
    LogIt(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  RouteViewController.m
//  DARTingAround
//
//  Created by Barry Scott on 28/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "RouteViewController.h"
#import "RouteStop.h"
#import <TSMessages/TSMessage.h>

@interface RouteViewController () <IrishRailDataManagerDelegate> {
    NSMutableArray *_displayObjects;
}

@end

@implementation RouteViewController

- (void)customiseAppearance {
    LogIt(@"customiseAppearance");
    self.title = @"Stops";
}

- (void)fetchDataFromServer {
    LogIt(@"fetchDataFromServer");
    [self.railDataManager fetchAllRouteStopsForTrain:self.detailTrain];
}

- (id)initWithStyle:(UITableViewStyle)style {
    LogIt(@"initWithStyle");
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    LogIt(@"viewDidLoad");
    [super viewDidLoad];
    //
    self.railDataManager = [IrishRailDataManager new];
    self.railDataManager.delegate = self;
    //
    [self customiseAppearance];
    //
    [self setupRefreshControl];
}

- (void)setupRefreshControl {
    LogIt(@"setupRefreshControl");
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTriggered) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating stops..."];
    [self setRefreshControl:refreshControl];
}

- (void)refreshTriggered {
    LogIt(@"refreshTriggered");
    [_displayObjects removeAllObjects];
    [self fetchDataFromServer];
}

- (void)viewDidAppear:(BOOL)animated {
    LogIt(@"viewDidAppear");
    if ([_displayObjects count] == 0) {
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        [self.refreshControl beginRefreshing];
        [self fetchDataFromServer];
    }
}

- (void)didReceiveMemoryWarning {
    LogIt(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LogIt(@"numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LogIt(@"numberOfRowsInSection");
    return _displayObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogIt(@"cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(void) updateTable {
    LogIt(@"updateTable");
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - Managing the detail item

- (void)setDetailTrain:(NSString *)newDetailTrain
{
    LogIt(@"setDetailTrain");
    if (_detailTrain != newDetailTrain) {
        _detailTrain = newDetailTrain;
    }
}

#pragma mark - IrishRailDataManagerDelegate Methods

- (void)receivedStopsData:(NSArray *)stopsArray {
    LogIt(@"receivedStopsData");
    _displayObjects = [NSMutableArray arrayWithArray:stopsArray];
    if ([_displayObjects count] > 0) {
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    else {
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Nothing found"
                                           subtitle:@"I couldn't find any stops, sorry. Please try again."
                                               type:TSMessageNotificationTypeError
                                           duration:3.0
                                           callback:^{}
                                        buttonTitle:nil
                                     buttonCallback:^{}
                                         atPosition:TSMessageNotificationPositionTop
                                canBeDismisedByUser:YES];
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end

//
//  DetailViewController.m
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "Station.h"
#import "Journey.h"
#import "JourneyCell.h"
#import <TSMessages/TSMessage.h>

@interface DetailViewController () <IrishRailDataManagerDelegate> {
    NSMutableArray *_objects;
    NSMutableArray *_originalObjectsArray;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;

@end


@implementation DetailViewController

- (void)fetchDataFromServer {
    LogIt(@"fetchDataFromServer");
    [self.directionSegmentedController setSelectedSegmentIndex:1];
    [self.railDataManager fetchAllJourneysForStation:self.detailStation.stationCode];
}

#pragma mark - Managing the detail item

- (void)setDetailStation:(Station *)newDetailStation
{
    LogIt(@"setDetailStation");
    if (_detailStation != newDetailStation) {
        _detailStation = newDetailStation;
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    LogIt(@"configureView");
    if (self.detailStation) {
        self.navigationItem.title = self.detailStation.stationDesc;
    }
}

- (void)viewDidLoad
{
    LogIt(@"viewDidLoad");
    [super viewDidLoad];
	//
    self.railDataManager = [IrishRailDataManager new];
    self.railDataManager.delegate = self;
    //
    [self configureView];
    //
    [self setupRefreshControl];
}

- (void)setupRefreshControl {
    LogIt(@"setupRefreshControl");
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTriggered) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating journeys..."];
    [self setRefreshControl:refreshControl];
}

- (void)refreshTriggered {
    LogIt(@"refreshTriggered");
    [_objects removeAllObjects];
    [self fetchDataFromServer];
}

- (void)viewDidAppear:(BOOL)animated {
    LogIt(@"viewDidAppear");
    if ([_objects count] == 0) {
        [self.refreshControl beginRefreshing];
        [self fetchDataFromServer];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    LogIt(@"splitController willHideViewController");
    barButtonItem.title = NSLocalizedString(@"Stations", @"Stations");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    LogIt(@"splitController willShowViewController");
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    LogIt(@"numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LogIt(@"tableView numberOfRowsInSection");
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogIt(@"tableView cellForRowAtIndexPath");
    JourneyCell *cell = (JourneyCell *)[tableView dequeueReusableCellWithIdentifier:@"JourneyCell" forIndexPath:indexPath];
    
    Journey *aJourney = _objects[indexPath.row];
    
	cell.dueInLabel.text = [NSString stringWithFormat:@"%@m", aJourney.journeyDueIn];
	cell.directionLabel.text = aJourney.journeyDirection;
    
    if ([aJourney.journeySchdepart isEqualToString:@"00:00"]) {
        // Terminates here
        cell.destinationLabel.text = @"Terminates here";
        cell.departTimeLabel.text = @"";
    }
    else {
        // You can get on this train
        cell.destinationLabel.text = aJourney.journeyDestination;
        cell.departTimeLabel.text = aJourney.journeyExpdepart;
    }
    
    if ([aJourney.journeyLate integerValue] > 0) {
        cell.lateLabel.text = [NSString stringWithFormat:@"%ldm LATE", (long)[aJourney.journeyLate integerValue]];
        cell.lateLabel.textColor = UIColorFromRGB(COLOUR_RED);
    }
    else {
        cell.lateLabel.text = @"ON TIME";
        cell.lateLabel.textColor = UIColorFromRGB(COLOUR_GREEN);
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogIt(@"tableView didSelectRowAtIndexPath");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        Station *object = _objects[indexPath.row];
//        self.detailViewController.detailStation = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LogIt(@"prepareForSegue");
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Station *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailStation:object];
    }
}

- (void)updateTable
{
    LogIt(@"updateTable");
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - IrishRailDataManagerDelegate Methods

- (IBAction)directionSegmentWasPicked:(id)sender {
    LogIt(@"directionSegmentWasPicked");
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    _objects = nil;
    _objects = [[NSMutableArray alloc] initWithCapacity:[_originalObjectsArray count]];
    if (segmentedControl.selectedSegmentIndex == 0) {
        LogIt(@"directionSegmentWasPicked :: Chose Northbound");
        for (Journey *aJourney in _originalObjectsArray) {
            if ([aJourney.journeyDirection isEqualToString:@"Northbound"])
                [_objects addObject:aJourney];
        }
    }
    else if(segmentedControl.selectedSegmentIndex == 1) {
        LogIt(@"directionSegmentWasPicked :: Chose All");
        _objects = _originalObjectsArray;
    }
    else if(segmentedControl.selectedSegmentIndex == 2) {
        LogIt(@"directionSegmentWasPicked :: Chose Southbound");
        for (Journey *aJourney in _originalObjectsArray) {
            if ([aJourney.journeyDirection isEqualToString:@"Southbound"])
                [_objects addObject:aJourney];
        }
    }
    [self updateTable];
}

- (void)receivedJourneyData:(NSArray *)journeysArray {
    LogIt(@"receivedJourneyData");
    _objects = [NSMutableArray arrayWithArray:journeysArray];
    _originalObjectsArray = _objects;
    if ([_objects count] > 0) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateTable];
        });
        //        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    else {
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Nothing found"
                                           subtitle:@"I couldn't find any trains, sorry. Please try again."
                                               type:TSMessageNotificationTypeError
                                           duration:3.0
                                           callback:^{}
                                        buttonTitle:nil
                                     buttonCallback:^{}
                                         atPosition:TSMessageNotificationPositionTop
                                canBeDismisedByUser:YES];
    }
}

@end

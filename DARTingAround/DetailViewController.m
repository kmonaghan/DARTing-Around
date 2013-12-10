//
//  DetailViewController.m
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "DetailViewController.h"
#import "IrishRailDataManager.h"
#import "Station.h"
#import "Journey.h"
#import "JourneyCell.h"
#import <TSMessages/TSMessage.h>
#import "NSDate+NVTimeAgo.h"
#import "RouteViewController.h"

@interface DetailViewController () <IrishRailDataManagerDelegate, UITextFieldDelegate> {
    NSMutableArray *_objects;
    NSMutableArray *_originalObjectsArray;
    NSString *_formattedQueryDate;
    NSTimer *_queryHowLongAgoTimer;
    NSNumber *_currentStopwatchTimer;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIToolbar *fieldAccessoryView;

- (void)configureView;

@end


@implementation DetailViewController

- (void)fetchDataFromServer {
    LogIt(@"fetchDataFromServer");
    [self.railDataManager fetchAllJourneysForStation:self.detailStation.stationCode];
}

- (void)toggleFavourite {
    LogIt(@"toggleFavourite");
    NSArray *favouriteStationsArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"FavouriteStations"];
    NSMutableArray *newFavouriteStationsArray = [[NSMutableArray alloc] initWithCapacity:[favouriteStationsArray count]];
    newFavouriteStationsArray = [NSMutableArray arrayWithArray:favouriteStationsArray];
    if ([favouriteStationsArray containsObject:self.detailStation.stationCode]) {
        // Removing this station from favourites
        [newFavouriteStationsArray removeObject:self.detailStation.stationCode];
    }
    else {
        // Adding this station to favourites
        [newFavouriteStationsArray addObject:self.detailStation.stationCode];
    }
    [[NSUserDefaults standardUserDefaults] setObject:newFavouriteStationsArray forKey:@"FavouriteStations"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    LogIt(@"toggleFavourite :: newFavouriteStationsArray: %@", newFavouriteStationsArray);
    [self configureNavigationBarButtons];
}

- (void)removeNavigationBarButtons {
    LogIt(@"removeNavigationBarButtons");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.rightBarButtonItems = @[];
    });
}
- (void)configureNavigationBarButtons {
    LogIt(@"configureNavigationBarButtons");
    self.navigationItem.rightBarButtonItems = nil;
    // Favourite station
    UIImage *favButtonImage;
    NSArray *favouriteStationsArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"FavouriteStations"];
    if ([favouriteStationsArray containsObject:self.detailStation.stationCode]) {
        favButtonImage = [UIImage imageNamed:@"star_on.png"];
    }
    else {
        favButtonImage = [UIImage imageNamed:@"star_off.png"];
    }
    favButtonImage = [favButtonImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *favButton = [[UIBarButtonItem alloc]
                                  initWithImage:favButtonImage
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(toggleFavourite)];
    // Stopwatch
    UIImage *stopwatchImage;
    if ([_currentStopwatchTimer floatValue] > 0.0f) {
        stopwatchImage = [UIImage imageNamed:@"stopwatch_on.png"];
    }
    else {
        stopwatchImage = [UIImage imageNamed:@"stopwatch.png"];
    }
    stopwatchImage = [stopwatchImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    // Create a custom view nav button with stopwatch image and time in it
    UIButton *stopwatchImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stopwatchImageButton setBackgroundImage:stopwatchImage forState:UIControlStateNormal];
    [stopwatchImageButton addTarget:self action:@selector(stopwatchAction) forControlEvents:UIControlEventTouchUpInside];
    [stopwatchImageButton setFrame:CGRectMake(6.0, 6.0, 25.0, 25.0)];

    UIView *buttView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 37.0, 37.0)];
    [buttView addSubview:stopwatchImageButton];
    
    UILabel *timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.0, 17.0, 20.0, 20.0)];
    [timerLabel setFont:[UIFont boldSystemFontOfSize:9.0]];
    [timerLabel setBackgroundColor:[UIColor clearColor]];
    [timerLabel setTextColor:UIColorFromRGB(COLOUR_DARK_BLUE)];
    [timerLabel setTextAlignment:NSTextAlignmentRight];
    if ([_currentStopwatchTimer floatValue] > 0.0f) {
        timerLabel.text = [NSString stringWithFormat:@"%d", [_currentStopwatchTimer integerValue]];
    } else {
        timerLabel.text = @"0";
    }
    [buttView addSubview:timerLabel];
    
    UIBarButtonItem *stopwatchButton = [[UIBarButtonItem alloc] initWithCustomView:buttView];

    // Add the buttons
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *navButtons = @[favButton, stopwatchButton];
        self.navigationItem.rightBarButtonItems = navButtons;
    });
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

- (void)refreshTriggered {
    LogIt(@"refreshTriggered");
    [self.stopwatchView removeFromSuperview];
    [self configureNavigationBarButtons];
    [self.tableView setContentOffset:CGPointMake(0.0, -64.0)];
    //
    if (self.detailStation) {
        [self fetchDataFromServer];
    }
    else {
        [self.refreshControl endRefreshing];
    }
}

- (void)configureView
{
    LogIt(@"configureView");
    if (self.detailStation) {
        self.navigationItem.title = self.detailStation.stationDesc;
    }
}

- (void)setupRefreshControl {
    LogIt(@"setupRefreshControl");
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTriggered) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating journeys..."];
    [self setRefreshControl:refreshControl];
}

- (void)viewDidLoad
{
    LogIt(@"viewDidLoad");
    [super viewDidLoad];
	//
    self.railDataManager = [IrishRailDataManager new];
    self.railDataManager.delegate = self;
    //
    self.directionView.alpha = 0.0;
    [self.directionView removeFromSuperview];
    [self configureView];
    //
    [self setupRefreshControl];
    //
    [self.stopwatchView removeFromSuperview];
    [self createAccessoryView];
    [self.stopwatchTime setInputAccessoryView:self.fieldAccessoryView];
    //
    _queryHowLongAgoTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                             target:self
                                                           selector:@selector(displayQueryTime)
                                                           userInfo:nil
                                                            repeats:YES];
}

- (void)dealloc {
    LogIt(@"dealloc");
    [_queryHowLongAgoTimer invalidate];
    _queryHowLongAgoTimer = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    LogIt(@"viewDidAppear");
    [super viewDidAppear:animated];
    _currentStopwatchTimer = [self fetchCurrentWalkToStationTimeFromDefaults];
    if (([_objects count] == 0) && (self.detailStation)) {
        [self refreshTriggered];
        self.directionView.hidden = 0.0;
        self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
        [self.refreshControl beginRefreshing];
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
    LogIt(@"tableView numberOfRowsInSection : %lu", (unsigned long)_objects.count);
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
        cell.dueInLabel.textColor = UIColorFromRGB(COLOUR_RED);
    }
    else {
        // You can get on this train
        cell.destinationLabel.text = aJourney.journeyDestination;
        cell.departTimeLabel.text = aJourney.journeyExpdepart;
        // Will I make it to the station in time?
        NSInteger departsInInteger = [aJourney.journeyDueIn integerValue];
        if (departsInInteger >= [_currentStopwatchTimer integerValue]) {
            // Yay, I can make it
            cell.dueInLabel.textColor = UIColorFromRGB(COLOUR_GREEN);
        }
        else {
            // Can't get there in time, will it be close?
            if ((departsInInteger + 1) >= [_currentStopwatchTimer integerValue]) {
                cell.dueInLabel.textColor = UIColorFromRGB(COLOUR_ORANGE);
            } else {
                cell.dueInLabel.textColor = UIColorFromRGB(COLOUR_RED);
            }
        }
    }
    
    if ([aJourney.journeyLate integerValue] > 0) {
        cell.lateLabel.text = [NSString stringWithFormat:@"%ldm Late", (long)[aJourney.journeyLate integerValue]];
        cell.lateLabel.textColor = UIColorFromRGB(COLOUR_RED);
    }
    else {
        cell.lateLabel.text = @"On Time";
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LogIt(@"prepareForSegue");
    if ([[segue identifier] isEqualToString:@"showStops"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Journey *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailJourney:object];
        // Hide the text on the back button
        self.title = @"";
    }
}

- (void)updateTable
{
    LogIt(@"updateTable");
    [self.refreshControl endRefreshing];
    [UIView animateWithDuration:1.0 animations:^{
        [self.view addSubview:self.directionView];
        self.directionView.alpha = 1.0;
    }];
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
    if ([journeysArray count] > 0) {
        [_objects removeAllObjects];
        _objects = [NSMutableArray arrayWithArray:journeysArray];
        _originalObjectsArray = _objects;
        if ([_objects count] > 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self directionSegmentWasPicked:self.directionSegmentedController];
            });
        }
        [self displayQueryTime];
    }
    else {
        [self performSelectorOnMainThread:@selector(showNothingFoundError) withObject:nil waitUntilDone:NO];
    }
//    [self configureNavigationBarButtons];
}

- (void)showNothingFoundError {
    LogIt(@"showNothingFoundError");
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
    [self updateTable];
}

- (void)displayQueryTime {
    LogIt(@"displayQueryTime");
    if ([_objects count] > 0) {
        Journey *aJourney = [_objects objectAtIndex:0];
        _formattedQueryDate = [aJourney.journeyQueryTime formattedAsTimeAgo];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *refreshTitle = [NSString stringWithFormat:@"Updated %@", _formattedQueryDate];
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:refreshTitle];
        });
    }
}

#pragma mark - UITextField and stopwatch methods

- (void)stopwatchAction {
    LogIt(@"stopwatchAction");
    [self.tableView setScrollEnabled:NO];
    if ([_currentStopwatchTimer floatValue] > 0.0f) {
        self.stopwatchTime.text = [NSString stringWithFormat:@"%d", [_currentStopwatchTimer integerValue]];
    } else {
        self.stopwatchTime.text = @"";
    }
    [self.view addSubview:self.stopwatchView];
    [self.tableView setContentOffset:CGPointMake(self.stopwatchView.frame.origin.x, self.stopwatchView.frame.origin.y)];
    [self.stopwatchTime becomeFirstResponder];
    //
    [self removeNavigationBarButtons];
}

- (void)createAccessoryView {
	LogIt(@"createAccessoryView");
	CGRect frame = CGRectMake(0.0, self.view.bounds.size.height, self.view.bounds.size.width, 44.0);
	self.fieldAccessoryView = [[UIToolbar alloc] initWithFrame:frame];
	self.fieldAccessoryView.tag = 200;
	//
	self.fieldAccessoryView.barStyle = UIBarStyleDefault;
	//
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				target:self
																				action:@selector(tapStopwatchCancelButton)];
	UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				 target:nil
																				 action:nil];
    UIBarButtonItem *findButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
																				target:self
																				action:@selector(tapStopwatchGoButton:)];
	//
	[self.fieldAccessoryView setItems:[NSArray arrayWithObjects:doneButton, spaceButton, findButton, nil] animated:NO];
}

- (IBAction)tapStopwatchGoButton:(id)sender {
    LogIt(@"tapStopwatchGoButton");
    [self.tableView setScrollEnabled:YES];
    [self.stopwatchTime resignFirstResponder];
    NSNumber *stopwatchTimeToSave = @([self.stopwatchTime.text integerValue]);
    [self saveCurrentWalkToStationTimeToDefaults:stopwatchTimeToSave];
    _currentStopwatchTimer = [NSNumber numberWithFloat:[self.stopwatchTime.text floatValue]];
    [self refreshTriggered];
}

- (void)tapStopwatchCancelButton {
    LogIt(@"tapStopwatchCancelButton");
    [self.tableView setScrollEnabled:YES];
    [self.stopwatchTime resignFirstResponder];
    [self saveCurrentWalkToStationTimeToDefaults:@0];
    _currentStopwatchTimer = @0.0f;
    [self refreshTriggered];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    LogIt(@"textFieldShouldReturn");
	[self.stopwatchTime resignFirstResponder];
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    LogIt(@"touchesBegan");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (NSNumber *)fetchCurrentWalkToStationTimeFromDefaults {
    LogIt(@"fetchCurrentWalkToStationTimeFromDefaults");
    NSNumber *walkToStationTime = nil;
    NSArray *walksArray = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"WalkToStationTimeArray"]];
    if ([walksArray count] > 0) {
        NSDictionary *existingWalkTimeDict = [self findDictionaryWithValueForKey:self.detailStation.stationCode inArray:walksArray];
        if (existingWalkTimeDict) {
            walkToStationTime = existingWalkTimeDict[@"walkTime"];
        }
    }
    return walkToStationTime;
}

- (void)saveCurrentWalkToStationTimeToDefaults:(NSNumber *)time {
    LogIt(@"saveCurrentWalkToStationTimeToDefaults");
    if ([time integerValue] > 80) {
        time = @80;
        self.stopwatchTime.text = [time stringValue];
    }
    //
    NSDictionary *walkTimeDict = @{@"stationCode": self.detailStation.stationCode, @"walkTime": time};
    NSMutableArray *walksArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"WalkToStationTimeArray"]];
    if ([walksArray count] > 0) {
        NSDictionary *existingWalkTimeDict = [self findDictionaryWithValueForKey:self.detailStation.stationCode inArray:walksArray ];
        if (existingWalkTimeDict) {
            NSUInteger objectIndex = [walksArray indexOfObject:existingWalkTimeDict];
            [walksArray replaceObjectAtIndex:objectIndex withObject:walkTimeDict];
        }
        else {
            [walksArray addObject:walkTimeDict];
        }
    }
    else {
        [walksArray addObject:walkTimeDict];
    }
    [[NSUserDefaults standardUserDefaults] setObject:walksArray forKey:@"WalkToStationTimeArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)findDictionaryWithValueForKey:(NSString *)name inArray:(NSArray *)myArray {
    __block BOOL found = NO;
    __block NSDictionary *dict = nil;
    [myArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dict = (NSDictionary *)obj;
        NSString *title = [dict valueForKey:@"stationCode"];
        if ([title isEqualToString:name]) {
            found = YES;
            *stop = YES;
        }
    }];
    if (found) {
        return dict;
    } else {
        return nil;
    }
}

@end

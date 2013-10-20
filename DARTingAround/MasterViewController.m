//
//  MasterViewController.m
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "Station.h"
#import "StationCell.h"
#import <TSMessages/TSMessage.h>

@interface MasterViewController () <IrishRailDataManagerDelegate> {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController

- (void)customiseAppearance {
//    [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor greenColor];
}

- (void)fetchDataFromServer {
    LogIt(@"fetchDataFromServer");
    [self.railDataManager fetchAllStations];
}

- (void)awakeFromNib {
    LogIt(@"awakeFromNib");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad {
    LogIt(@"viewDidLoad");
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
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
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating stations..."];
    [self setRefreshControl:refreshControl];
}

- (void)refreshTriggered {
    LogIt(@"refreshTriggered");
    [_objects removeAllObjects];
    [self fetchDataFromServer];
}

- (void)viewWillAppear:(BOOL)animated {
    LogIt(@"viewWillAppear");
    self.title = @"Stations";
}

- (void)viewDidAppear:(BOOL)animated {
    LogIt(@"viewDidAppear");
    if ([_objects count] == 0) {
        [self.refreshControl beginRefreshing];
        [self fetchDataFromServer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    LogIt(@"numberOfSectionsInTableView");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LogIt(@"tableView numberOfRowsInSection :: %lu", (unsigned long)_objects.count);
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LogIt(@"tableView cellForRowAtIndexPath");
    StationCell *cell = (StationCell *)[tableView dequeueReusableCellWithIdentifier:@"StationCell" forIndexPath:indexPath];

    Station *aStation = _objects[indexPath.row];
    
//    UILabel *stationLabel = (UILabel *)[cell viewWithTag:100];
//	stationLabel.text = aStation.stationDesc;
    
    cell.nameLabel.text = aStation.stationDesc;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LogIt(@"tableView didSelectRowAtIndexPath");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        Station *object = _objects[indexPath.row];
        self.detailViewController.detailStation = object;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    LogIt(@"prepareForSegue");
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Station *object = _objects[indexPath.row];
        [[segue destinationViewController] setDetailStation:object];
        // Hide the text on the back button
        self.title = @"";
    }
}

-(void) updateTable {
    LogIt(@"updateTable");
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

#pragma mark - IrishRailDataManagerDelegate Methods

- (void)receivedStationData:(NSArray *)stationsArray {
    LogIt(@"receivedStationData");
    _objects = [NSMutableArray arrayWithArray:stationsArray];
    if ([_objects count] > 0) {
        [self performSelectorOnMainThread:@selector(updateTable) withObject:nil waitUntilDone:NO];
    }
    else {
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Nothing found"
                                           subtitle:@"I couldn't find any stations, sorry. Please try again."
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

@end

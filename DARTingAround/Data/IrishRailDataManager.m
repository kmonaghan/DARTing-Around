//
//  IrishRailDataManager.m
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "IrishRailDataManager.h"
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>
#import <TBXML/TBXML.h>
#import "Station.h"
#import "Journey.h"
#import "Mixpanel.h"

@interface IrishRailDataManager () <NSXMLParserDelegate> {
    NSNumber *stationCount;
}
@end

@implementation IrishRailDataManager

#pragma mark - Data Methods

// ==========================================
// JOURNEYS
// ==========================================

- (void)fetchAllJourneysForStation:(NSString *)stationCode {
    LogIt(@"fetchAllJourneysForStation :: stationCode: %@", stationCode);
    if ([stationCode length] == 0) return;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    NSString *url = [NSString stringWithFormat:@"http://api.irishrail.ie/realtime/realtime.asmx/getStationDataByCodeXML_WithNumMins?StationCode=%@&NumMins=90", stationCode];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *journeysArray = [NSMutableArray array];
        NSString *strData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        LogIt(@"fetchAllJourneysForStation :: responseObject (Stringified): %@", strData);
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *initError;
            // TODO: Check the error here
            TBXML *sourceXML = [[TBXML alloc] initWithXMLData:responseObject error:&initError];
            if (!sourceXML) {
                [self fetchAllJourneysForStationFailedWithError:nil];
                return;
            }
            TBXMLElement *rootElement = sourceXML.rootXMLElement;
            if (!rootElement) {
                [self fetchAllJourneysForStationFailedWithError:nil];
                return;
            }
            TBXMLElement *journeyElement = [TBXML childElementNamed:@"objStationData" parentElement:rootElement];
            if (!journeyElement) {
                [self fetchAllJourneysForStationFailedWithError:nil];
                return;
            }
            do {
                NSMutableDictionary *journeyDict = [NSMutableDictionary new];
                //
                NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [formatter setLocale:[NSLocale systemLocale]];
                //
                TBXMLElement *codeElement = [TBXML childElementNamed:@"Traincode" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:codeElement] forKey:@"journeyTrainCode"];
                
                TBXMLElement *typeElement = [TBXML childElementNamed:@"Traintype" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:typeElement] forKey:@"journeyTrainType"];
                
                TBXMLElement *dateElement = [TBXML childElementNamed:@"Traindate" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:dateElement] forKey:@"journeyTrainDate"];
                
                TBXMLElement *stationCodeElement = [TBXML childElementNamed:@"Stationcode" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:stationCodeElement] forKey:@"journeyStationCode"];
                
                TBXMLElement *nameElement = [TBXML childElementNamed:@"Stationfullname" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:nameElement] forKey:@"journeyStationFullName"];
                
                TBXMLElement *originElement = [TBXML childElementNamed:@"Origin" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:originElement] forKey:@"journeyOrigin"];
                
                TBXMLElement *originTimeElement = [TBXML childElementNamed:@"Origintime" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:originTimeElement] forKey:@"journeyOriginTime"];
                
                TBXMLElement *directionElement = [TBXML childElementNamed:@"Direction" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:directionElement] forKey:@"journeyDirection"];
                
                TBXMLElement *destinationElement = [TBXML childElementNamed:@"Destination" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:destinationElement] forKey:@"journeyDestination"];
                
                TBXMLElement *destinationTimeElement = [TBXML childElementNamed:@"Destinationtime" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:destinationTimeElement] forKey:@"journeyDestinationTime"];
                
                TBXMLElement *statusElement = [TBXML childElementNamed:@"Status" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:statusElement] forKey:@"journeyStatus"];
                
                TBXMLElement *locationElement = [TBXML childElementNamed:@"Lastlocation" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:locationElement] forKey:@"journeyLastLocation"];
                
                TBXMLElement *dueElement = [TBXML childElementNamed:@"Duein" parentElement:journeyElement];
                [journeyDict setObject:@([[TBXML textForElement:dueElement] integerValue]) forKey:@"journeyDueIn"];
                
                TBXMLElement *lateElement = [TBXML childElementNamed:@"Late" parentElement:journeyElement];
                [journeyDict setObject:@([[TBXML textForElement:lateElement] integerValue]) forKey:@"journeyLate"];
                
                TBXMLElement *schArriveElement = [TBXML childElementNamed:@"Scharrival" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:schArriveElement] forKey:@"journeyScharrival"];
                
                TBXMLElement *expArriveElement = [TBXML childElementNamed:@"Exparrival" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:expArriveElement] forKey:@"journeyExparrival"];
                
                TBXMLElement *schDepartElement = [TBXML childElementNamed:@"Schdepart" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:schDepartElement] forKey:@"journeySchdepart"];
                
                TBXMLElement *expDepartElement = [TBXML childElementNamed:@"Expdepart" parentElement:journeyElement];
                [journeyDict setObject:[TBXML textForElement:expDepartElement] forKey:@"journeyExpdepart"];

//                TBXMLElement *serverTimeElement = [TBXML childElementNamed:@"Servertime" parentElement:journeyElement];
//                if (serverTimeElement != nil) {
//                    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSS"];
//                    NSString *dateString = [TBXML textForElement:serverTimeElement];
//                    NSDate *aDate = [formatter dateFromString:dateString];
//                    [journeyDict setObject:aDate forKey:@"journeyServerTime"];
//                }
//                [journeyDict setObject:[TBXML textForElement:serverTimeElement] forKey:@"journeyServerTime"];
//                TBXMLElement *queryTimeElement = [TBXML childElementNamed:@"Querytime" parentElement:journeyElement];
                
                [journeyDict setObject:[NSDate date] forKey:@"journeyQueryTime"];

                Journey *thisJourney = [[Journey alloc] initWithJourneyDictionary:journeyDict];
                [journeysArray addObject:thisJourney];
            } while ((journeyElement = journeyElement->nextSibling) != nil);
            // Found an array of journeys, sort it
            NSArray *sortedArray;
            sortedArray = [journeysArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSNumber *first = [(Journey*)a journeyDueIn];
                NSNumber *second = [(Journey*)b journeyDueIn];
                return [first compare:second];
            }];
            // Now return the sorted array
            if ([self.delegate respondsToSelector:@selector(receivedJourneyData:)]) {
                LogIt(@"fetchAllJourneysForStation :: Telling delegate we found journeys");
                [self.delegate receivedJourneyData:[NSArray arrayWithArray:sortedArray]];
            }
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self fetchAllJourneysForStationFailedWithError:error];
    }];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"API Request Run" properties:@{
                                                    @"Type": @"Journeys",
                                                    @"Option": stationCode
                                                    }];
}

- (void)fetchAllJourneysForStationFailedWithError:(NSError *)error {
    LogIt(@"fetchAllJourneysForStationFailedWithError :: Error: %@", [[error userInfo] description]);
    if ([self.delegate respondsToSelector:@selector(receivedJourneyData:)]) {
        [self.delegate receivedJourneyData:nil];
    }
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"API Request Failed" properties:@{
                                                    @"Type": @"Journeys"
                                                    }];
}

// ==========================================
// STATIONS
// ==========================================

- (void)fetchAllStations {
    LogIt(@"fetchAllStations");
    // If an array of stations already exists return that, then update that list in the background if required (once per day)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullFileName = [NSString stringWithFormat:@"%@/Stations", docDir];
    NSMutableArray *arrayFromDisk = [NSKeyedUnarchiver unarchiveObjectWithFile:fullFileName];
    if (arrayFromDisk) {
        // Found an array of stations, sort it
        NSArray *sortedArray;
        sortedArray = [arrayFromDisk sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(Station*)a stationDesc];
            NSString *second = [(Station*)b stationDesc];
            return [first compare:second];
        }];
        // Now return the sorted array
        LogIt(@"fetchAllStations :: Found stations on disk");
        if ([self.delegate respondsToSelector:@selector(receivedStationData:)]) {
            LogIt(@"fetchAllStations :: Telling delegate we found stations");
            [self.delegate receivedStationData:[NSArray arrayWithArray:sortedArray]];
        }
        // How old is this data? If more than one day then update it
        NSDate *savedDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"stationsDataSavedAt"];
        NSDate *rightNow = [NSDate date];
        NSTimeInterval savedDiff = [savedDate timeIntervalSinceNow];
        NSTimeInterval nowDiff = [rightNow timeIntervalSinceNow];
        NSTimeInterval dateDiff = savedDiff - nowDiff; // Returns number of seconds
        LogIt(@"fetchAllStations :: Station data is %f seconds from now, that's %d days", dateDiff, abs(dateDiff / (60*60*24)));
        if ( (abs(dateDiff / (60*60*24))) > 1) {
            LogIt(@"fetchAllStations :: Station data on disk needs refreshed");
            [self fetchAllStationsFromServer];
        }
    }
    else {
        // Need to fetch stations from the server
        LogIt(@"fetchAllStations :: Station data needs to be fetched from server");
        [self fetchAllStationsFromServer];
    }
}

- (void)fetchAllStationsFromServer {
    LogIt(@"fetchAllStationsFromServer");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:@"http://api.irishrail.ie/realtime/realtime.asmx/getAllStationsXML_WithStationType?StationType=D" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *stationsArray = [NSMutableArray array];
        NSString *strData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        LogIt(@"fetchAllStationsFromServer :: XML (Stringified): %@", strData);
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            TBXML *sourceXML = [[TBXML alloc] initWithXMLData:responseObject error:nil];
            if (!sourceXML) {
                [self fetchStationsFailedWithError:nil];
                return;
            }
            TBXMLElement *rootElement = sourceXML.rootXMLElement;
            if (!rootElement) {
                [self fetchStationsFailedWithError:nil];
                return;
            }
            TBXMLElement *stationElement = [TBXML childElementNamed:@"objStation" parentElement:rootElement];
            if (!stationElement) {
                [self fetchStationsFailedWithError:nil];
                return;
            }
            do {
                TBXMLElement *descElement = [TBXML childElementNamed:@"StationDesc" parentElement:stationElement];
                NSString *stationDesc = [TBXML textForElement:descElement];
                
                TBXMLElement *codeElement = [TBXML childElementNamed:@"StationCode" parentElement:stationElement];
                NSString *stationCode = [TBXML textForElement:codeElement];
                
                TBXMLElement *idElement = [TBXML childElementNamed:@"StationId" parentElement:stationElement];
                NSNumber *stationId = @([[TBXML textForElement:idElement] integerValue]);
                
                TBXMLElement *latElement = [TBXML childElementNamed:@"StationLatitude" parentElement:stationElement];
                CLLocationDegrees stationLat = [[TBXML textForElement:latElement] doubleValue];
                
                TBXMLElement *lngElement = [TBXML childElementNamed:@"StationLongitude" parentElement:stationElement];
                CLLocationDegrees stationLng = [[TBXML textForElement:lngElement] doubleValue];
                
                LogIt(@"fetchAllStationsFromServer :: Found station: %@", stationDesc);
                Station *thisStation = [[Station alloc] initWithStationCode:stationCode
                                                                description:stationDesc
                                                                         id:stationId
                                                                        lat:stationLat
                                                                        lng:stationLng];
                [stationsArray addObject:thisStation];
            } while ((stationElement = stationElement->nextSibling) != nil);
            // Got an array of stations, sort it
            NSArray *sortedArray;
            sortedArray = [stationsArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSString *first = [(Station*)a stationDesc];
                NSString *second = [(Station*)b stationDesc];
                return [first compare:second];
            }];
            // Now return the sorted array
            if ([self.delegate respondsToSelector:@selector(receivedStationData:)]) {
                LogIt(@"fetchAllStationsFromServer :: Telling delegate we found stations");
                [self.delegate receivedStationData:[NSArray arrayWithArray:sortedArray]];
            }
            // Save this data on device
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docDir = [paths objectAtIndex:0];
            NSString *fullFileName = [NSString stringWithFormat:@"%@/Stations", docDir];
            [NSKeyedArchiver archiveRootObject:stationsArray toFile:fullFileName];
            // Record when this was saved
            NSDate *rightNow = [NSDate date];
            [[NSUserDefaults standardUserDefaults] setObject:rightNow forKey:@"stationsDataSavedAt"];
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        LogIt(@"fetchAllStationsFromServer :: AFHTTPRequestOperation Error: %@", error);
        [self fetchStationsFailedWithError:error];
    }];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"API Request Run" properties:@{
                                                  @"Type": @"Stations",
                                                  @"Option": @""
                                                  }];
}

- (void)fetchStationsFailedWithError:(NSError *)error {
    LogIt(@"fetchStationsFailedWithError :: Error: %@", [[error userInfo] description]);
    if ([self.delegate respondsToSelector:@selector(receivedStationData:)]) {
        [self.delegate receivedStationData:nil];
    }
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"API Request Failed" properties:@{
                                                       @"Type": @"Stations"
                                                       }];
}

// ==========================================
// TRAINS
// ==========================================

- (void)fetchDataForTrain:(NSString *)requiredTrainCode {
    LogIt(@"fetchDataForTrain");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    [manager GET:@"http://api.irishrail.ie/realtime/realtime.asmx/getCurrentTrainsXML_WithTrainType?TrainType=D" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        __block Train *myTrain; // Only looking for data on one train
        NSString *strData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        LogIt(@"fetchDataForTrain :: XML (Stringified): %@", strData);
        //
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            TBXML *sourceXML = [[TBXML alloc] initWithXMLData:responseObject error:nil];
            if (!sourceXML) {
                [self fetchTrainFailedWithError:nil];
                return;
            }
            TBXMLElement *rootElement = sourceXML.rootXMLElement;
            if (!rootElement) {
                [self fetchTrainFailedWithError:nil];
                return;
            }
            TBXMLElement *trainElement = [TBXML childElementNamed:@"objTrainPositions" parentElement:rootElement];
            if (!trainElement) {
                [self fetchTrainFailedWithError:nil];
                return;
            }
            do {
                TBXMLElement *codeElement = [TBXML childElementNamed:@"TrainCode" parentElement:trainElement];
                NSString *trainCode = [TBXML textForElement:codeElement];
                
                if ([trainCode isEqualToString:requiredTrainCode]) {
                    TBXMLElement *statusElement = [TBXML childElementNamed:@"TrainStatus" parentElement:trainElement];
                    NSString *trainStatus = [TBXML textForElement:statusElement];
                    
                    TBXMLElement *messageElement = [TBXML childElementNamed:@"PublicMessage" parentElement:trainElement];
                    NSString *trainPublicMessage = [TBXML textForElement:messageElement];
                    
                    TBXMLElement *directionElement = [TBXML childElementNamed:@"Direction" parentElement:trainElement];
                    NSString *trainDirection = [TBXML textForElement:directionElement];
                    
                    TBXMLElement *latElement = [TBXML childElementNamed:@"TrainLatitude" parentElement:trainElement];
                    CLLocationDegrees trainLat = [[TBXML textForElement:latElement] doubleValue];
                    
                    TBXMLElement *lngElement = [TBXML childElementNamed:@"TrainLongitude" parentElement:trainElement];
                    CLLocationDegrees trainLng = [[TBXML textForElement:lngElement] doubleValue];
                    
                    LogIt(@"fetchDataForTrain :: Found train: %@", trainCode);
                    myTrain = [[Train alloc] initWithTrainCode:trainCode
                                                        status:trainStatus
                                                       message:trainPublicMessage
                                                     direction:trainDirection
                                                           lat:trainLat
                                                           lng:trainLng];
                }
            } while ((trainElement = trainElement->nextSibling) != nil);
            // Now return the data for the one train we are interested in
            if ([self.delegate respondsToSelector:@selector(receivedTrainData:)]) {
                LogIt(@"fetchDataForTrain :: Telling delegate we found data");
                [self.delegate receivedTrainData:myTrain];
            }
        });
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        LogIt(@"fetchDataForTrain :: AFHTTPRequestOperation Error: %@", error);
        [self fetchTrainFailedWithError:error];
    }];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"API Request Run" properties:@{
                                                    @"Type": @"Train",
                                                    @"Option": requiredTrainCode
                                                    }];
}

- (void)fetchTrainFailedWithError:(NSError *)error {
    LogIt(@"fetchTrainFailedWithError :: Error: %@", [[error userInfo] description]);
    if ([self.delegate respondsToSelector:@selector(receivedTrainData:)]) {
        [self.delegate receivedTrainData:nil];
    }
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"API Request Failed" properties:@{
                                                       @"Type": @"Train"
                                                       }];
}

#pragma mark - Management Methods

- (id)init {
    LogIt(@"init");
    if (self = [super init]) {
        stationCount = @0;
    }
    return self;
}

- (void)dealloc {
    LogIt(@"dealloc");
    // Should never be called, but just here for clarity really.
}

@end

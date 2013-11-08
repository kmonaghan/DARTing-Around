//
//  IrishRailDataManager.h
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Train.h"

@protocol IrishRailDataManagerDelegate <NSObject>
@optional
- (void)receivedStationData:(NSArray *)stationsArray;
- (void)receivedJourneyData:(NSArray *)journeysArray;
- (void)receivedTrainData:(Train *)trainData;
- (void)receivedStopsData:(NSArray *)stopsArray;
@end


@interface IrishRailDataManager : NSObject

@property (nonatomic, weak) id <IrishRailDataManagerDelegate> delegate;

- (void)fetchAllStations;
- (void)fetchAllJourneysForStation:(NSString *)stationCode;
- (void)fetchDataForTrain:(NSString *)trainCode;
- (void)fetchAllRouteStopsForTrain:(NSString *)trainCode onDate:(NSString *)trainDate;

@end

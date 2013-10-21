//
//  Journey.m
//  DARTingAround
//
//  Created by Barry Scott on 15/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "Journey.h"

@implementation Journey

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Must use initWithJourneyDictionary:"
                                 userInfo:nil];
}

- (id)initWithJourneyDictionary:(NSDictionary *)journeyDict {
    LogIt(@"initWithJourneyDictionary :: journeyDict: %@", journeyDict);
    if ((self = [super init])) {
        _journeyTrainCode = journeyDict[@"journeyTrainCode"];
        _journeyTrainType = journeyDict[@"journeyTrainType"];
        _journeyTrainDate = journeyDict[@"journeyTrainDate"];
        _journeyStationCode = journeyDict[@"journeyStationCode"];
        _journeyStationFullName = journeyDict[@"journeyStationFullName"];
        _journeyOrigin = journeyDict[@"journeyOrigin"];
        _journeyOriginTime = journeyDict[@"journeyOriginTime"];
        _journeyDirection = journeyDict[@"journeyDirection"];
        _journeyDestination = journeyDict[@"journeyDestination"];
        _journeyDestinationTime = journeyDict[@"journeyDestinationTime"];
        _journeyStatus = journeyDict[@"journeyStatus"];
        _journeyLastLocation = journeyDict[@"journeyLastLocation"];
        _journeyDueIn = journeyDict[@"journeyDueIn"];
        _journeyLate = journeyDict[@"journeyLate"];
        _journeyScharrival = journeyDict[@"journeyScharrival"];
        _journeyExparrival = journeyDict[@"journeyExparrival"];
        _journeySchdepart = journeyDict[@"journeySchdepart"];
        _journeyExpdepart = journeyDict[@"journeyExpdepart"];
        _journeyQueryTime = journeyDict[@"journeyQueryTime"];
    }
    return self;
}

@end

//
//  Journey.h
//  DARTingAround
//
//  Created by Barry Scott on 15/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Journey : NSObject

@property (readonly) NSString *journeyTrainCode;
@property (readonly) NSString *journeyTrainType;
@property (readonly) NSString *journeyTrainDate;
@property (readonly) NSString *journeyStationCode;
@property (readonly) NSString *journeyStationFullName;

@property (readonly) NSString *journeyOrigin;
@property (readonly) NSString *journeyOriginTime;
@property (readonly) NSString *journeyDirection;
@property (readonly) NSString *journeyDestination;
@property (readonly) NSString *journeyDestinationTime;
@property (readonly) NSString *journeyStatus;
@property (readonly) NSString *journeyLastLocation;
@property (readonly) NSNumber *journeyDueIn;
@property (readonly) NSNumber *journeyLate;

@property (readonly) NSString *journeyScharrival;
@property (readonly) NSString *journeyExparrival;
@property (readonly) NSString *journeySchdepart;
@property (readonly) NSString *journeyExpdepart;

@property (readonly) NSDate *journeyQueryTime;

- (id)initWithJourneyDictionary:(NSDictionary *)journeyDict;

@end

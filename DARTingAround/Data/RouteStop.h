//
//  RouteStop.h
//  DARTingAround
//
//  Created by Barry Scott on 15/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RouteStop : NSObject

@property (readonly) NSString *stopTrainCode;
@property (readonly) NSString *stopLocationCode;
@property (readonly) NSString *stopLocationFullName;
@property (readonly) NSNumber *stopLocationOrder;
@property (readonly) NSString *stopLocationType; // O = Origin, S = Stop, T = TimingPoint (non stopping location) D = Destination
@property (readonly) NSString *stopOrigin;
@property (readonly) NSString *stopDestination;
@property (readonly) NSString *stopStopType; // C = Current N = Next

- (id)initStopWithDictionary:(NSDictionary *)stopDict;

@end

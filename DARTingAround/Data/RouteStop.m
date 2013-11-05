//
//  RouteStop.m
//  DARTingAround
//
//  Created by Barry Scott on 15/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "RouteStop.h"

@implementation RouteStop

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Must use initStopWithDictionary:"
                                 userInfo:nil];
}

- (id)initStopWithDictionary:(NSDictionary *)stopDict {
    LogIt(@"initStopWithDictionary :: stopDict: %@", stopDict);
    if ((self = [super init])) {
        _stopTrainCode = stopDict[@"stopTrainCode"];
        _stopLocationCode = stopDict[@"stopLocationCode"];
        _stopLocationFullName = stopDict[@"stopLocationFullName"];
        _stopLocationOrder = stopDict[@"stopLocationOrder"];
        _stopLocationType = stopDict[@"stopLocationType"];
        _stopOrigin = stopDict[@"stopOrigin"];
        _stopDestination = stopDict[@"stopDestination"];
        _stopStopType = stopDict[@"stopStopType"];
    }
    return self;
}

@end

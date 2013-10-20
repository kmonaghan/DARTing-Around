//
//  Station.h
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Station : NSObject

@property (readonly) NSString *stationDesc;
@property (readonly) NSString *stationCode;
@property (readonly) NSNumber *stationId;
@property (readonly) CLLocation *stationLocation;

- (id)initWithStationCode:(NSString *)code description:(NSString *)description id:(NSNumber *)theId lat:(CLLocationDegrees)lat lng:(CLLocationDegrees)lng;

@end

//
//  Station.m
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "Station.h"

@interface Station ()

@property (readonly) CLLocationDegrees stationLatitude;
@property (readonly) CLLocationDegrees stationLongitude;

@end


@implementation Station

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Must use initWithStationCode::"
                                 userInfo:nil];
}

- (id)initWithStationCode:(NSString *)code
              description:(NSString *)description
                       id:(NSNumber *)theId
                      lat:(CLLocationDegrees)lat
                      lng:(CLLocationDegrees)lng
{
    LogIt(@"initWithStationCode... :: code: %@", code);
    if ((self = [super init])) {
        _stationDesc = description;
        _stationCode = code;
        _stationId = theId;
        _stationLatitude  = lat;
        _stationLongitude = lng;
        _stationLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    LogIt(@"encodeWithCoder");
    [encoder encodeObject:self.stationDesc forKey:@"stationDesc"];
    [encoder encodeObject:self.stationCode forKey:@"stationCode"];
    [encoder encodeObject:self.stationId forKey:@"stationId"];
    [encoder encodeObject:@(self.stationLatitude) forKey:@"stationLatitude"];
    [encoder encodeObject:@(self.stationLongitude) forKey:@"stationLongitude"];
    [encoder encodeObject:self.stationLocation forKey:@"stationLocation"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    LogIt(@"initWithCoder");
    if (self = [super init]) {
        _stationDesc = [decoder decodeObjectForKey:@"stationDesc"];
        _stationCode = [decoder decodeObjectForKey:@"stationCode"];
        _stationId = [decoder decodeObjectForKey:@"stationId"];
        _stationLatitude = [[decoder decodeObjectForKey:@"stationLatitude"] doubleValue];
        _stationLongitude = [[decoder decodeObjectForKey:@"stationLongitude"] doubleValue];
        _stationLocation = [decoder decodeObjectForKey:@"stationLocation"];
    }
    return self;
}

@end

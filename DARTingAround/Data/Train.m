//
//  Train.m
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import "Train.h"

@interface Train ()

@property (readonly) CLLocationDegrees trainLatitude;
@property (readonly) CLLocationDegrees trainLongitude;

@end


@implementation Train

- (id)initWithTrainCode:(NSString *)code
                 status:(NSString *)status
                message:(NSString *)message
              direction:(NSString *)direction
                    lat:(CLLocationDegrees)lat
                    lng:(CLLocationDegrees)lng {
    LogIt(@"initWithTrainCode... :: code: %@", code);
    if ((self = [super init])) {
        _trainCode = code;
        _trainStatus = status;
        _trainPublicMessage = message;
        _trainDirection  = direction;
        _trainLatitude = lat;
        _trainLongitude = lng;
        _trainLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    }
    return self;
    
}

@end

//
//  Train.h
//  DARTingAround
//
//  Created by Barry Scott on 14/10/2013.
//  Copyright (c) 2013 Vote For Baz Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Train : NSObject

@property (readonly) NSString *trainCode;
@property (readonly) NSString *trainStatus;
@property (readonly) NSString *trainPublicMessage;
@property (readonly) NSString *trainDirection;
@property (readonly) CLLocation *trainLocation;

- (id)initWithTrainCode:(NSString *)code status:(NSString *)status message:(NSString *)message direction:(NSString *)direction lat:(CLLocationDegrees)lat lng:(CLLocationDegrees)lng;

@end

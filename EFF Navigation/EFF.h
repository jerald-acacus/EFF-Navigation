//
//  EFF.h
//  EFF Navigation
//
//  Created by Jerald Abille on 11/23/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EFF : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *flightIdentifier;
@property (nonatomic, strong) NSString *departureAirport;
@property (nonatomic, strong) NSString *arrivalAirport;
@property (nonatomic, strong) NSString *aircraftRegistration;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) BOOL isDownloaded;

@end

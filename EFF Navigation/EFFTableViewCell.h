//
//  EFFTableViewCell.h
//  EFF Navigation
//
//  Created by Jerald Abille on 11/23/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EFFTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *flightIdentifier;
@property (nonatomic, strong) IBOutlet UILabel *departureAirport;
@property (nonatomic, strong) IBOutlet UILabel *arrivalAirport;
@property (nonatomic, strong) IBOutlet UILabel *aircraftRegistration;
@property (nonatomic, strong) IBOutlet UILabel *date;

@end

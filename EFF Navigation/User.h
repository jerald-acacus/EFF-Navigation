//
//  User.h
//  EFF Navigation
//
//  Created by Jerald Abille on 11/29/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

+ (id)sharedInstance;

@property (nonatomic, strong) NSDictionary *EFF;

@end

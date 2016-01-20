//
//  User.h
//  EFF Navigation
//
//  Created by Jerald Abille on 11/29/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EFF.h"

@interface User : NSObject

+ (id)sharedInstance;

@property (nonatomic, strong) EFF *eff;
@property (nonatomic, strong) NSMutableArray *EFFArray;

@end

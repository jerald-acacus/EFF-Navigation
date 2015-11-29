//
//  User.m
//  EFF Navigation
//
//  Created by Jerald Abille on 11/29/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import "User.h"

@implementation User

+ (id)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

@end

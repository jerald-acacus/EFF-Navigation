//
//  Topic.h
//  EFF Navigation
//
//  Created by Jerald Abille on 11/25/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Topic : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *documents;

@end

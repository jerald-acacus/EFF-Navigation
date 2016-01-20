//
//  EFFDocument.h
//  EFF Navigation
//
//  Created by Jerald Abille on 11/29/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EFFDocument : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *file;
@property (nonatomic, strong) NSString *topic;
@property (nonatomic, strong) NSString *type;

@end

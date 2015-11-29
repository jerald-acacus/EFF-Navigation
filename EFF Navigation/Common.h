//
//  Common.h
//  EFF Navigation
//
//  Created by Jerald Abille on 11/24/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

+ (NSString *)documentsPath;
+ (NSString *)effFolderPath;
+ (NSString *)renameFile:(NSString *)file;
+ (void)extractFile:(NSString *)file success:(void (^)(NSArray *files))successBlock failure:(void (^)(NSError *error))failureBlock;

+ (NSDictionary *)test;

@end

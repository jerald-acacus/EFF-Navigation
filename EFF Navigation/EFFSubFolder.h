//
//  EFFSubFolder.h
//  EFF Navigation
//
//  Created by Jerald Abille on 11/29/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EFFSubFolder : NSObject

@property (nonatomic, strong) NSString *folder;
@property (nonatomic, strong) NSMutableArray *topics; // array of EFFTopic
@property (nonatomic, strong) NSMutableArray *subFolders; // array of EFFSubFolder

@end

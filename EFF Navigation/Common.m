//
//  Common.m
//  EFF Navigation
//
//  Created by Jerald Abille on 11/24/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import "Common.h"
#import "SSZipArchive.h"

@implementation Common

+ (NSString *)documentsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths firstObject];
}

+ (NSString *)effFolderPath {
    return [[Common documentsPath] stringByAppendingPathComponent:@"EFFs"];
}

+ (NSString *)renameFile:(NSString *)file {
    NSError *error;
    
    NSString *src = [NSString stringWithFormat:@"%@/%@",[Common effFolderPath], file];
    NSString *dest = [NSString stringWithFormat:@"%@/%@.zip",[Common effFolderPath], [file stringByDeletingPathExtension]];
    
    NSLog(@"RENAME SRC %@",src);
    NSLog(@"RENAME DEST %@",dest);
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:src]) {
        if ([manager moveItemAtPath:src toPath:dest error:&error]) {
            if (error) {
                if (error.code == 516) {
                    NSLog(@"Error 516 %@",error.localizedDescription);
                    return dest;
                }
                else {
                    NSLog(@"Error renaming file. %@",error.localizedDescription);
                    // ????: Delete file if failed?
                }
            }
            return dest;
        }
        else {
            NSLog(@"Error moving item.");
            return nil;
        }
        
    }
    else {
        NSLog(@"File being renamed does not exist.");
        return dest;
    }
    return nil;
}

+ (void)extractFile:(NSString *)file success:(void (^)(NSArray *files))successBlock failure:(void (^)(NSError *error))failureBlock {
    NSString *dest = [NSString stringWithFormat:@"%@/%@", [Common effFolderPath], [[file lastPathComponent] stringByDeletingPathExtension]];
    NSError *err;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:dest]) {
        [manager createDirectoryAtPath:dest withIntermediateDirectories:NO attributes:nil error:&err];
    }
    NSLog(@"EXTRACT SRC %@",file);
    NSLog(@"EXTRACT DEST %@",dest);

    [SSZipArchive unzipFileAtPath:file toDestination:dest progressHandler:^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total) {
        
    } completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
        if (!error) {
            [manager removeItemAtPath:file error:&error];
            successBlock(nil);
        }
        else {
            NSLog(@"%@",error.localizedDescription);
            failureBlock(error);
        }
    }];
}

/*
+ (NSDictionary *)test { // ETD1111R
    return @{
             @"subfolders":@[
                     @{
                         @"name":@"NOTAMS",
                         @"topics":@[
                                 @"NOTAM/6.0 Crew Additional Info",
                                 @"NOTAM/0.0 NOTAMS Validity",
                                 @"NOTAM/1.0 Dep",
                                 @"NOTAM/2.0 Dest",
                                 @"NOTAM/2.1 Dest Alt",
                                 @"NOTAM/3.0 ETOPS Suitable",
                                 @"NOTAM/4.0 Enroute Airports",
                                 @"NOTAM/0.1 Crew Alert",
                                 @"NOTAM/0.2 Crew Bulletin"
                                 ],
                         @"documents":@[
                                 @{@"file":@"CrewAdditionalInfo.txt",
                                   @"topic":@"NOTAM/6.0 Crew Additonal Info"
                                   },
                                 @{@"file":@"NOTAM Validity.txt",
                                   @"topic":@"NOTAM/0.0 NOTAMS Validity"
                                   },
                                 @{@"file":@"Departure NOTAM OMAA.txt",
                                   @"topic":@"NOTAM/1.0 Dep"
                                   },
                                 @{@"file":@"Destination NOTAM YBBN.txt",
                                   @"topic":@"NOTAM/2.0 Dest"
                                   },
                                 @{@"file":@"Altn NOTAM YBCG.txt",
                                   @"topic":@"NOTAM/2.1 Dest Alt"
                                   },
                                 @{@"file":@"Altn NOTAM YMML.txt",
                                   @"topic":@"NOTAM/2.1 Dest Alt"
                                   },
                                 @{@"file":@"Altn NOTAM YPAD.txt",
                                   @"topic":@"NOTAM/2.1 Dest Alt"
                                   },
                                 @{@"file":@"Altn NOTAM YSSY.txt",
                                   @"topic":@"NOTAM/2.1 Dep Alt"
                                   },
                                 @{@"file":@"ETOPS Enroute Suitable NOTAM.txt",
                                   @"topic":@"NOTAM/3.0 ETOPS Suitable"
                                   },
                                 @{@"file":@"enRoute NOTAM.txt",
                                   @"topic":@"NOTAM/4.0 Enroute Airports"
                                   },
                                 @{@"file":@"CrewAlert.txt",
                                   @"topic":@"NOTAM/0.1 Crew Alert"
                                   },
                                 @{@"file":@"CrewBulletin.txt",
                                   @"topic":@"NOTAM/0.2 Crew Bulletin"
                                   },
                                 ]
                       },
                     @{@"name":@"METEO"},
                     @{@"name":@"Flight Plan"},
                     @{@"name":@"Paper Flight Plan"},
                     @{@"name":@"Loadsheet"},
                     @{@"name":@"NOTOC"},
                     ]
             };
}
 */

#define topic   @"topic"
#define docs    @"documents"


+ (NSDictionary *)test { // ETD1111R
    return @{
             @"subfolders":@[
                     @{
                         @"name":@"NOTAMS",
                         @"topics":@[
                                 @{topic:@"NOTAM/6.0 Crew Additional Info",
                                   docs:@[@"CrewAdditionalInfo.txt"]
                                   },
                                 @{topic:@"NOTAM/0.0 NOTAMS Validity",
                                   docs:@[@"NOTAM Validity.txt"]
                                   },
                                 @{topic:@"NOTAM/1.0 Dep",
                                   docs:@[@"Departure NOTAM OMAA.txt"]
                                   },
                                 @{topic:@"NOTAM/2.0 Dest",
                                   docs:@[@"Destination NOTAM YBBN.txt"]
                                   },
                                 @{topic:@"NOTAM/2.1 Dest Alt",
                                   docs:@[@"Altn NOTAM YBCG.txt",
                                          @"Altn NOTAM YMML.txt",
                                          @"Altn NOTAM YPAD",
                                          @"Altn NOTAM YSSY.txt",
                                          ]
                                   },
                                 @{topic:@"NOTAM/3.0 ETOPS Suitable",
                                   docs:@[@"ETOPS Enroute Suitable NOTAM.txt"]
                                   },
                                 @{topic:@"NOTAM/4.0 Enroute Airports",
                                   docs:@[@"NOTAM/4.0 Enroute Airports"]
                                   },
                                 @{topic:@"NOTAM/0.1 Crew Alert",
                                   docs:@[@"NOTAM/0.1 Crew Alert"]
                                   },
                                 @{topic:@"NOTAM/0.2 Crew Bulletin",
                                   docs:@[@"CrewBulletin.txt"]
                                   }
                                 ],
                         },
                     @{@"name":@"METEO"},
                     @{@"name":@"Flight Plan"},
                     @{@"name":@"Paper Flight Plan"},
                     @{@"name":@"Loadsheet"},
                     @{@"name":@"NOTOC"},
                     ]
             };
}

+ (NSString *)effJSON {
    // return @"http://www.json-generator.com/api/json/get/bUGcijsmWa?indent=2";
    return @"http://192.168.0.117/~jeraldabille/subfolder.json";
}

@end

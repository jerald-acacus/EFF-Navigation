//
//  ViewController.m
//  EFF Navigation
//
//  Created by Jerald Abille on 11/23/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "EFF.h"
#import "EFFTableViewCell.h"
#import "SSZipArchive.h"
#import "EFFReaderViewController.h"
#import "Common.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [_filesTableView registerNib:[UINib nibWithNibName:@"EFFTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"cell"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileDir = [[paths firstObject] stringByAppendingPathComponent:@"EFFs"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    effArray = [[NSMutableArray alloc] init];
    
    [SVProgressHUD show];
    NSString *url = @"http://www.json-generator.com/api/json/get/cwrWsGKfEy?indent=2"; //@"http://www.json-generator.com/api/json/get/ckICuAnYia?indent=2";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"File list successfully loaded."];
        NSLog(@"%@",responseObject);
        for (NSString *str in responseObject[@"files"]) {
            if ([[str pathExtension] isEqualToString:@"eff"]) {
                EFF *eff = [[EFF alloc] init];
                eff.name = str;
                NSArray *words = [str componentsSeparatedByString:@"_"];
                eff.flightIdentifier = words[1];
                eff.departureAirport = words[3];
                eff.arrivalAirport = words[4];
                eff.aircraftRegistration = words[0];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-M-d"];
                NSString *d = [words[2] substringWithRange:NSMakeRange(4, 2)];
                NSString *m = [words[2] substringWithRange:NSMakeRange(2, 2)];
                NSString *y = [NSString stringWithFormat:@"20%@",[words[2] substringWithRange:NSMakeRange(0, 2)]];
                eff.date = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",y,m,d]];
                [effArray addObject:eff];
            }
        }
        [_filesTableView reloadData];
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        NSLog(@"Error %@",error.localizedDescription);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    EFFTableViewCell *cell = (EFFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    EFF *eff = effArray[indexPath.row];
    cell.name.text = [NSString stringWithFormat:@"%@ / %@", eff.departureAirport, eff.arrivalAirport];
    cell.aircraftRegistration.text = eff.aircraftRegistration;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM-dd-yyyy"];
    cell.date.text = [formatter stringFromDate:eff.date];
    
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [Common effFolderPath], [eff.name stringByDeletingPathExtension]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return effArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EFF *eff = effArray[indexPath.row];
    
    // If file already exists locally, we open it.
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [Common effFolderPath], [eff.name stringByDeletingPathExtension]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        EFFReaderViewController *readerVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EFFReaderViewController"];
        readerVC.currentEFF = eff;
        [self.navigationController pushViewController:readerVC animated:YES];
        
        return;
    }
    
    // If file is not yet in our directory, we download it.
    NSString *url = [NSString stringWithFormat:@"http://192.168.0.106/~jeraldabille/EFF/%@",eff.name];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [SVProgressHUD show];
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSError *error;
        NSURL *documentsDir = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }
        return [documentsDir URLByAppendingPathComponent:[NSString stringWithFormat:@"EFFs/%@", [response suggestedFilename]]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [self extractFile:[self renameFile:[filePath lastPathComponent]] success:^(NSArray *files) {
            NSString *datFile = [NSString stringWithFormat:@"%@/%@.dat",
                                 [[filePath lastPathComponent] stringByDeletingPathExtension],
                                 [[filePath lastPathComponent] stringByDeletingPathExtension]];
            [self extractFile:[self renameFile:datFile] success:^(NSArray *files) {
                [SVProgressHUD showSuccessWithStatus:@"File downloaded successfully."];
                eff.isDownloaded = YES;
                [_filesTableView reloadData];
                
            } failure:^(NSString *error) {
                
            }];
            
        } failure:^(NSString *error) {
            NSLog(@"%@",error);
        }];
    }];
    
    [task resume];
}

#pragma mark - File operations

- (NSString *)renameFile:(NSString *)file {
    NSError *error;
    
    NSString *src = [NSString stringWithFormat:@"%@/%@", [Common effFolderPath], file];
    NSString *dest = [NSString stringWithFormat:@"%@/%@.zip", [Common effFolderPath], [file stringByDeletingPathExtension]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:src]) {
        [fileManager moveItemAtPath:src toPath:dest error:&error];
        if (error.code == 516) {
            return dest;
        }
        return dest;
    } else {
        return dest;
    }
    
    return nil;
}

- (void)extractFile:(NSString *)file success:(void (^)(NSArray *files))successBlock failure:(void (^)(NSString *error))failureBlock {
    NSString *dest = [NSString stringWithFormat:@"%@/%@", [Common effFolderPath], [[file lastPathComponent] stringByDeletingPathExtension]];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dest]) {
        [fileManager createDirectoryAtPath:dest withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    [SSZipArchive unzipFileAtPath:file toDestination:dest progressHandler:^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total) {
        
    } completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
        if (!error) {
            [fileManager removeItemAtPath:file error:&error];
            successBlock(nil);
        } else {
            NSLog(@"%@",error.localizedDescription);
        }
    }];
}

@end

//
//  EFFFileListTableViewController.m
//  EFF Navigation
//
//  Created by Jerald Abille on 11/26/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import "EFFFileListTableViewController.h"
#import "EFFTableViewCell.h"
#import "Common.h"
#import "AFNetworking.h"
#import "EFF.h"
#import "SVProgressHUD.h"

@interface EFFFileListTableViewController ()

@end

@implementation EFFFileListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [_tableView registerNib:[UINib nibWithNibName:@"EFFTableViewCell"
                                           bundle:[NSBundle mainBundle]]
                           forCellReuseIdentifier:@"cell"];
    
    [_segmentedControl addTarget:self action:@selector(didChangeFileList) forControlEvents:UIControlEventValueChanged];
    
    // TODO: Create this folder somewhere before this part of the app.
    NSError *error;
    NSString *fileDir = [Common effFolderPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    filesArray = [[NSMutableArray alloc] init];
    
    [self didChangeFileList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getFilesOnline {
    NSString *url = @"http://www.json-generator.com/api/json/get/cwrWsGKfEy?indent=2";
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        [filesArray removeAllObjects];
        for (NSString *file in responseObject[@"files"]) {
            if ([[file pathExtension] isEqualToString:@"eff"]) {
                EFF *eff = [[EFF alloc] init];
                eff.name = file;
                NSArray *words = [file componentsSeparatedByString:@"_"];
                eff.flightIdentifier = words[1];
                eff.departureAirport = words[3];
                eff.arrivalAirport = words[4];
                eff.aircraftRegistration = words[0];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-M-d"];
                NSString *d = [words[2] substringWithRange:NSMakeRange(4, 2)];
                NSString *m = [words[2] substringWithRange:NSMakeRange(2, 2)];
                NSString *y = [words[2] substringWithRange:NSMakeRange(0, 2)];
                y = [@"20" stringByAppendingString:y];
                eff.date = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",y,m,d]];
                [filesArray addObject:eff];
            }
        }
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortedArray = [filesArray sortedArrayUsingDescriptors:@[descriptor]];
        filesArray = [sortedArray mutableCopy];
        [_tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"Oops! Something went wrong. %@", error.localizedDescription);
        
    }];
}

- (void)getLocalFiles {
    [filesArray removeAllObjects];
    NSString *filePath = [Common effFolderPath];
    NSError *error;
    NSArray *localFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&error];
    for (NSString *file in localFiles) {
        NSString *fileName = [file stringByAppendingPathExtension:@"eff"];
        EFF *eff = [[EFF alloc] init];
        eff.name = fileName;
        NSArray *words = [file componentsSeparatedByString:@"_"];
        eff.flightIdentifier = words[1];
        eff.departureAirport = words[3];
        eff.arrivalAirport = words[4];
        eff.aircraftRegistration = words[0];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-M-d"];
        NSString *d = [words[2] substringWithRange:NSMakeRange(4, 2)];
        NSString *m = [words[2] substringWithRange:NSMakeRange(2, 2)];
        NSString *y = [words[2] substringWithRange:NSMakeRange(0, 2)];
        y = [@"20" stringByAppendingString:y];
        eff.date = [formatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",y,m,d]];
        [filesArray addObject:eff];
    }
    [_tableView reloadData];
}

- (void)didChangeFileList {
    if (_segmentedControl.selectedSegmentIndex == 0) {
        [self getFilesOnline];
        currentFileSource = 0;
        [_tableView reloadData];
    }
    else {
        [self getLocalFiles];
        currentFileSource = 1;
        [_tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
}

#pragma mark - Table view delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return filesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    EFFTableViewCell *cell = (EFFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    EFF *eff = [filesArray objectAtIndex:indexPath.row];
    cell.name.text = eff.name;
    cell.aircraftRegistration.text = eff.aircraftRegistration;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM-dd-yyyy"];
    cell.date.text = [formatter stringFromDate:eff.date];
    
    BOOL isDir = NO;
    NSString *filePath = [[[Common effFolderPath] stringByAppendingString:@"/"] stringByAppendingString:[eff.name stringByDeletingPathExtension]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDir]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EFF *eff = [filesArray objectAtIndex:indexPath.row];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", [Common effFolderPath], [eff.name stringByDeletingPathExtension]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        // Set the selected EFF to be current EFF.
        NSLog(@"Set the selected EFF to be current EFF.");
        return;
    }
    
    if (_segmentedControl.selectedSegmentIndex == 0) { // online, we download it.
        [SVProgressHUD showWithStatus:@"Downloading..."];
        NSString *url = [@"http://192.168.0.106/~jeraldabille/EFF/" stringByAppendingString:eff.name];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        NSURLSessionTask *task = [manager downloadTaskWithRequest:req progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            NSError *error;
            NSURL *urlForDirectory = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
            return [urlForDirectory URLByAppendingPathComponent:[@"EFFs/" stringByAppendingString:[response suggestedFilename]]];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            [Common extractFile:[Common renameFile:[filePath lastPathComponent]] success:^(NSArray *files) {
               // TODO: .dat file is not always <fileName>.dat, sometimes it can be myEFF.dat. So we just get the file with the .dat file extension.
                NSString *dat = [NSString stringWithFormat:@"%@/%@.dat",
                                 [[filePath lastPathComponent] stringByDeletingPathExtension],
                                 [[filePath lastPathComponent] stringByDeletingPathExtension]];
                [Common extractFile:[Common renameFile:dat] success:^(NSArray *files) {
                   
                    eff.isDownloaded = YES;
                    [_tableView reloadData];
                    [SVProgressHUD showSuccessWithStatus:@"File downloaded."];
                } failure:^(NSError *error) {
                    NSLog(@"Error extracting .dat file. %@",error.localizedDescription);
                }];
                
            } failure:^(NSError *error) {
                NSLog(@"Error extracting .eff file. %@",error.localizedDescription);
            }];
            
        }];
        [task resume];
    }
    else { // local.
        
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

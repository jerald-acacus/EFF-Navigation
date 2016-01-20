//
//  EFFFileListTableViewController.h
//  EFF Navigation
//
//  Created by Jerald Abille on 11/26/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EFF.h"

@protocol EFFFileListDelegate <NSObject>

@optional
- (void)setCurrentEFF:(EFF *)eff;

@end

@interface EFFFileListTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *filesArray;
    NSInteger currentFileSource;
}

@property (nonatomic, weak) id<EFFFileListDelegate>delegate;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;

@end

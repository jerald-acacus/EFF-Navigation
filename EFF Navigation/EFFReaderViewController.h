//
//  EFFReaderViewController.h
//  EFF Navigation
//
//  Created by Jerald Abille on 11/24/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EFF.h"
#import "User.h"

@interface EFFReaderViewController : UIViewController <NSXMLParserDelegate>
{
    User *user;
    
    NSMutableArray *subFolderButtons;
    NSMutableArray *subFolders;
    NSMutableArray *weatherArray;
    NSMutableArray *notamsArray;
    NSMutableArray *flightPlanArray;
    NSMutableArray *loadsheetArray;
    NSMutableArray *notocArray;
    NSMutableArray *paperFlightPlanArray;
    
    NSString *currentSubFolder;
    NSString *currentTopic;
    NSString *currentFile;

    UIBarButtonItem *effListButtonItem;
}

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) EFF *currentEFF;

@end

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
#import "EFFFileListTableViewController.h"
#import "EFFDocument.h"
#import "EFFTopic.h"
#import "EFFSubFolder.h"

@interface EFFReaderViewController : UIViewController <NSXMLParserDelegate, EFFFileListDelegate, UIPopoverPresentationControllerDelegate>
{
    // XML Parsing
    NSString *xmlElement;
    NSDictionary *xmlAttrib;
    EFFSubFolder *xmlSubFolder;
    NSMutableArray *xmlSubFolderTopics;
    EFFTopic *xmlTopic;
    EFFDocument *xmlDocument;
    NSMutableArray *tempTopicsArray;
    BOOL isSubFolder;
    
    NSString *currentTitle;
    NSString *currentSubFolder;
    EFFSubFolder *secondLevelSubFolder;
    
    User *user;
    
    NSMutableArray *subFolderButtons;
    
//    NSMutableArray *subFolders;
//    NSString *currentTitle;
//    NSMutableDictionary *subFolder;
//    NSMutableDictionary *topicDict;
    
    NSMutableArray *weatherArray;
    NSMutableArray *notamsArray;
    NSMutableArray *flightPlanArray;
    NSMutableArray *loadsheetArray;
    NSMutableArray *notocArray;
    NSMutableArray *paperFlightPlanArray;
    
    NSString *currentTopic;
    NSString *currentFile;

    UIBarButtonItem *effListButtonItem;
}

@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;

@property (nonatomic, strong) EFF *currentEFF;

@end

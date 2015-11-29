//
//  ViewController.h
//  EFF Navigation
//
//  Created by Jerald Abille on 11/23/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate>
{
    NSMutableArray *effArray;
}

@property (nonatomic, strong) IBOutlet UITableView *filesTableView;

@end


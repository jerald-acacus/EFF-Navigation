//
//  EFFReaderViewController.m
//  EFF Navigation
//
//  Created by Jerald Abille on 11/24/15.
//  Copyright © 2015 Jerald Abille. All rights reserved.
//

#import "EFFReaderViewController.h"
#import "Common.h"
#import "SVProgressHUD.h"
#import "EFFListTableViewController.h"
#import "Topic.h"
#import "EFFFileListTableViewController.h"
#import "User.h"

@interface EFFReaderViewController ()

@end

@implementation EFFReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
    NSString *effXMLPath = [[Common effFolderPath] stringByAppendingPathComponent:[_currentEFF.name stringByDeletingPathExtension]];
    effXMLPath = [effXMLPath stringByAppendingPathComponent:@"eff.xml"];
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:effXMLPath isDirectory:&isDir]) {
        [self parseXML:effXMLPath];
    }
     */
    
    user = [User sharedInstance];
    
    UIButton *sortButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sortButton setTitle:@"Sort by File Name" forState:UIControlStateNormal];
    self.navigationItem.titleView = sortButton;
    
    effListButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eff-list"] style:UIBarButtonItemStyleDone target:self action:@selector(showEFFFilesList)];
    self.navigationItem.leftBarButtonItem = effListButtonItem;

    subFolders = [[NSMutableArray alloc] initWithArray:[Common test][@"subfolders"]];
    [_segmentedControl removeSegmentAtIndex:1 animated:NO];
    [_segmentedControl removeSegmentAtIndex:0 animated:NO];
    subFolderButtons = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    for (NSDictionary *dict in subFolders) {
        [_segmentedControl insertSegmentWithTitle:dict[@"name"] atIndex:[subFolders indexOfObject:dict] animated:NO];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        float btnX = ([subFolders indexOfObject:dict] * (CGRectGetWidth(_segmentedControl.frame) / [subFolders count])) + CGRectGetMinX(_segmentedControl.frame);
        btn.frame = CGRectMake(btnX,
                               CGRectGetHeight(self.view.frame) - CGRectGetHeight(_segmentedControl.frame) - 8,
                               CGRectGetWidth(_segmentedControl.frame) / [subFolders count],
                               CGRectGetHeight(_segmentedControl.frame));
        [btn setTitle:dict[@"name"] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
//        btn.backgroundColor = [UIColor greenColor];
//        btn.layer.borderColor = [UIColor redColor].CGColor;
//        btn.layer.borderWidth = 1;
        [btn addTarget:self action:@selector(didTapSubfolder:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [subFolderButtons addObject:btn];
    }
}

- (void)showEFFFilesList {
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EFFFileListNav"];
    // EFFFileListTableViewController *vc = [[nav viewControllers] firstObject];
    nav.modalPresentationStyle = UIModalPresentationOverFullScreen;
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    nav.preferredContentSize = CGSizeMake(400, 300);
    UIPopoverPresentationController *pc = [nav popoverPresentationController];
    pc.barButtonItem = effListButtonItem;
    pc.sourceRect = CGRectZero;
    // pc.sourceRect = CGRectMake(CGRectGetWidth(self.navigationItem.titleView.frame)/2, CGRectGetMaxY(self.navigationItem.titleView.frame), 0, 0);
    // pc.sourceView = self.navigationItem.titleView;
    pc.permittedArrowDirections = UIPopoverArrowDirectionUp;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didTapSubfolder:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSLog(@"%f",btn.frame.origin.x);
    long index = [subFolderButtons indexOfObject:btn];
    [_segmentedControl setSelectedSegmentIndex:index];
    
    
    
    EFFListTableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EFFListTableViewController"];
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vc.preferredContentSize = CGSizeMake(400, 300);
    NSArray *topics = [Common test][@"subfolders"][index][@"topics"];
    NSMutableArray *topicsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict  in topics) {
        NSLog(@"%@",dict[@"topic"]);
        NSLog(@"%@",dict[@"documents"]);
        Topic *topic = [[Topic alloc] init];
        topic.name = dict[@"topic"];
        topic.documents = dict[@"documents"];
        [topicsArray addObject:topic];
    }
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortedArray = [topicsArray sortedArrayUsingDescriptors:@[descriptor]];
    vc.listArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    
    UIPopoverPresentationController *pc = [vc popoverPresentationController];
    pc.sourceRect = btn.frame; // CGRectMake(CGRectGetWidth(btn.frame)/2, CGRectGetMinY(btn.frame), CGRectGetWidth(btn.frame), CGRectGetHeight(btn.frame));
    pc.sourceView = self.view;
    pc.canOverlapSourceViewRect = YES;
    pc.permittedArrowDirections = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)parseXML:(NSString *)file {
    NSData *data = [NSData dataWithContentsOfFile:file];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    parser.shouldResolveExternalEntities = NO;
    parser.shouldProcessNamespaces = YES;
    [parser parse];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
    NSString *title = attributeDict[@"title"];
    
    // Determine subfolder
    if ([title isEqualToString:@"METEO"] || [title isEqualToString:@"Weather"]) {
        currentSubFolder = title;
        weatherArray = [[NSMutableArray alloc] init];
        return;
    }
    
    // Determine document
    if ([elementName isEqualToString:@"Document"]) {
        currentFile = attributeDict[@"file"];
        return;
    }
    
    // Determine topic
    if ([elementName isEqualToString:@"Topic"]) {
        currentTopic = attributeDict[@"name"];
        return;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    [SVProgressHUD showWithStatus:@"Parsing XML..."];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [SVProgressHUD showSuccessWithStatus:@"Parsing Done."];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

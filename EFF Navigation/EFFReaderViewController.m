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
#import "AFNetworking.h"
#import "EFFSubFolder.h"
#import "EFFTopic.h"
#import "EFFDocument.h"
#import "XMLReader.h"

@interface EFFReaderViewController ()

@end

@implementation EFFReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"did load");
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    [mgr GET:@"http://localhost/~jeraldabille/EFF/list.php" parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSLog(@"response %@",responseObject);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error.localizedDescription);
    }];
    
    
//    NSString *effXMLPath = [[Common effFolderPath] stringByAppendingPathComponent:[_currentEFF.name stringByDeletingPathExtension]];
//    effXMLPath = [effXMLPath stringByAppendingPathComponent:@"eff.xml"];
//    BOOL isDir = NO;
//    if ([[NSFileManager defaultManager] fileExistsAtPath:effXMLPath isDirectory:&isDir]) {
//        [self parseXML:effXMLPath];
//    }
    
    
    /*AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    [mgr GET:[Common effJSON] parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        user = [[User alloc] init];
        user = [User sharedInstance];
        user.EFFArray = [[NSMutableArray alloc] init];
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject
                                                           options:0
                                                             error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding];
        NSLog(@"json %@",jsonString);
         // NSLog(@"response %@",responseObject);
        
        NSArray *subFolders = responseObject[@"EFUSUB"][@"SubFolder"][@"SubFolder"];
        
        for (NSDictionary *subFolder in subFolders) {
            EFFSubFolder *sf = [[EFFSubFolder alloc] init];
            sf.folder = subFolder[@"title"];
            
            
            for (NSDictionary *data in subFolder[@"Topic"]) {
                // NSLog(@"%@",data);
                // NSDictionary *dict = (NSDictionary *)data;
                NSLog(@"%@",data[@"name"]);
            }
            
            [user.EFFArray addObject:sf];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@",error.localizedDescription);
    }];
     */
    
    
    UIButton *sortButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [sortButton setTitle:@"Sort by File Name" forState:UIControlStateNormal];
    self.navigationItem.titleView = sortButton;
    
    effListButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eff-list"] style:UIBarButtonItemStyleDone target:self action:@selector(showEFFFilesList)];
    self.navigationItem.leftBarButtonItem = effListButtonItem;

    // subFolders = [[NSMutableArray alloc] initWithArray:user.EFF[@"subfolders"]];
    [_segmentedControl removeSegmentAtIndex:1 animated:NO];
    [_segmentedControl removeSegmentAtIndex:0 animated:NO];
    subFolderButtons = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)initSegmentedControl {
    for (EFFSubFolder *sf in user.EFFArray) {
        [_segmentedControl insertSegmentWithTitle:sf.folder atIndex:[user.EFFArray indexOfObject:sf] animated:NO];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        float btnX = ([user.EFFArray indexOfObject:sf] * (CGRectGetWidth(_segmentedControl.frame) / [user.EFFArray count])) + CGRectGetMinX(_segmentedControl.frame);
        btn.frame = CGRectMake(btnX,
                               CGRectGetHeight(self.view.frame) - CGRectGetHeight(_segmentedControl.frame) - 8,
                               CGRectGetWidth(_segmentedControl.frame) / [user.EFFArray count],
                               CGRectGetHeight(_segmentedControl.frame));
        [btn setTitle:sf.folder forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(didTapSubfolder:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [subFolderButtons addObject:btn];
    }
}

- (void)showEFFFilesList {
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EFFFileListNav"];
    EFFFileListTableViewController *vc = [[nav viewControllers] firstObject];
    vc.delegate = self;
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

- (void)setCurrentEFF:(EFF *)eff {
    user.eff = eff;
    // Read eff.xml from this EFF
    // Parse XML
    // Create EFF dictionary from XML
    // Construct the UI
    NSString *effXMLPath = [[Common effFolderPath] stringByAppendingPathComponent:[eff.name stringByDeletingPathExtension]];
    effXMLPath = [effXMLPath stringByAppendingPathComponent:@"eff.xml"];
    BOOL isDir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:effXMLPath isDirectory:&isDir]) {
        [self parseXML:effXMLPath];
    }
}

- (void)didTapSubfolder:(id)sender {
    UIButton *btn = (UIButton *)sender;
    long index = [subFolderButtons indexOfObject:btn];
    [_segmentedControl setSelectedSegmentIndex:index];
    
    EFFListTableViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EFFListTableViewController"];
    vc.modalPresentationStyle = UIModalPresentationPopover;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vc.preferredContentSize = CGSizeMake(400, 300);
    // NSArray *topics = user.EFF[@"subfolders"][index][@"topics"];
    NSMutableArray *topicsArray = [[NSMutableArray alloc] init];
//    for (NSString *str  in user.EFFArray[]) {
//        Topic *topic = [[Topic alloc] init];
//        topic.name = str;
//        
//        
//        [topicsArray addObject:topic];
//    }
    
    EFFSubFolder *sf = [user.EFFArray objectAtIndex:index];
    topicsArray = [[NSMutableArray alloc] initWithArray:sf.topics];
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSArray *sortedArray = [topicsArray sortedArrayUsingDescriptors:@[descriptor]];
    vc.listArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    
    UIPopoverPresentationController *pc = [vc popoverPresentationController];
    pc.sourceRect = btn.frame; // CGRectMake(CGRectGetWidth(btn.frame)/2, CGRectGetMinY(btn.frame), CGRectGetWidth(btn.frame), CGRectGetHeight(btn.frame));
    pc.sourceView = self.view;
    pc.canOverlapSourceViewRect = YES;
    pc.permittedArrowDirections = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
    pc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing  _Nonnull *)view {
    // TODO: Use autolayout instead of a fix like this.
//    UIButton *btn = [subFolderButtons objectAtIndex:_segmentedControl.selectedSegmentIndex];
//    float btnX = (_segmentedControl.selectedSegmentIndex * (CGRectGetWidth(_segmentedControl.frame) / [user.EFF[@"subfolders"] count])) + CGRectGetMinX(_segmentedControl.frame);
//    btn.frame = CGRectMake(btnX,
//                           CGRectGetHeight(self.view.frame) - CGRectGetHeight(_segmentedControl.frame) - 8,
//                           CGRectGetWidth(_segmentedControl.frame) / [user.EFF[@"subfolders"] count],
//                           CGRectGetHeight(_segmentedControl.frame));
//    NSLog(@"%f %f %f %f", CGRectGetWidth(btn.frame), CGRectGetHeight(btn.frame), btn.frame.origin.x, btn.frame.origin.y);
////    CGRect rectInView = [btn convertRect:btn.frame toView:self.view];
////    *rect = CGRectMake(CGRectGetMidX(rectInView), CGRectGetMaxY(rectInView), 1, 1);
////    *view = self.view;
//    *rect = btn.frame;
//    *view = self.view;
}
// get root_folder
// get all subfolders under root_folder - create each as array object
// get topic for a subfolder,
// get docs for a subfolder, set as dict item as array


- (void)parseXML:(NSString *)file {
    NSData *data = [NSData dataWithContentsOfFile:file];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    parser.shouldResolveExternalEntities = NO;
    parser.shouldProcessNamespaces = YES;
    // [parser parse];
    
    
    NSString *string = [[NSString alloc] initWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *xml = [XMLReader dictionaryForXMLData:data error:nil]; //[XMLReader dictionaryForXMLString:string error:nil];
    // NSLog(@"DICTIONARY %@",xml);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:xml options:NSJSONWritingPrettyPrinted error:nil];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"json %@",str);
    
    NSArray *subFolders = xml[@"EFUSUB"][@"SubFolder"][@"SubFolder"];
    NSLog(@"countr %lu",(unsigned long)subFolders.count);
    for (NSDictionary *sf in subFolders) {
        // NSLog(@"subFolder %@",sf[@"title"]);
        
        NSArray *topics = sf[@"Topic"];
        for (NSDictionary *dict in topics) {
           //  NSLog(@"got a dict %@",[dict objectForKey:@"name"]);
        }
        
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
    // NSLog(@"element %@", elementName);
    // NSLog(@"attribs %@", attributeDict);
    
    NSString *title = attributeDict[@"title"];
    
    xmlElement = elementName;
    xmlAttrib = attributeDict;
    
    // _Root_Folder
    if ([xmlElement isEqualToString:@"SubFolder"] && [title isEqualToString:@"_Root_Folder_"]) {
        isSubFolder = NO;
        user.EFFArray = [[NSMutableArray alloc] init];
        tempTopicsArray = [[NSMutableArray alloc] init];
    }
    
    /*
    // _Root_Folder > SubFolder
    if ([xmlElement isEqualToString:@"SubFolder"] && attributeDict[@"title"] && ![attributeDict[@"title"] isEqualToString:@"_Root_Folder_"]) {
        currentTitle = title;
        currentSubFolder = nil;
        if ([self isEFFSubFolder:title])
        {
            currentSubFolder = currentTitle;
            // This is a level 0 sub folder
            NSLog(@"SF %@",title);
            
            isSubFolder = YES;
            xmlSubFolder = [[EFFSubFolder alloc] init];
            xmlSubFolder.folder = attributeDict[@"title"];
            xmlSubFolder.topics = [[NSMutableArray alloc] init];
            
            [tempTopicsArray removeAllObjects];
            
            xmlSubFolder.subFolders = [[NSMutableArray alloc] init];
        }
        else {
            NSLog(@"SF2 %@",title);
            secondLevelSubFolder = [[EFFSubFolder alloc] init];
            secondLevelSubFolder.folder = attributeDict[@"title"];
            secondLevelSubFolder.topics = [[NSMutableArray alloc] init];
            
        }
    }
    */
    
    /*
     if we get a subfolder, check if title belongs to subfolder list
     if yes, it is a top level sf
     if not, it is a 2nd level sf
     */
    
    if ([xmlElement isEqualToString:@"SubFolder"] && ![title isEqualToString:@"_Root_Folder_"]) { // top level
        isSubFolder = YES;
        if ([self isEFFSubFolder:title]) {
            NSLog(@"SF %@",title);
            
            xmlSubFolder = [[EFFSubFolder alloc] init];
            xmlSubFolder.folder = attributeDict[@"title"];
            xmlSubFolder.topics = [[NSMutableArray alloc] init];
            
            [tempTopicsArray removeAllObjects];
            
            xmlSubFolder.subFolders = [[NSMutableArray alloc] init];
        }
        else {
            NSLog(@"SF2 %@",title);
        }
    }
    
    // _Root_Folder > SubFolder > Topic
    if ([xmlElement isEqualToString:@"Topic"] && attributeDict[@"name"] && xmlDocument == nil) {
        xmlTopic = [[EFFTopic alloc] init];
        xmlTopic.name = attributeDict[@"name"];
        xmlTopic.documents = [[NSMutableArray alloc] init];
        [xmlSubFolder.topics addObject:xmlTopic];
        
        [tempTopicsArray addObject:attributeDict[@"name"]];
    }
    
    // _Root_Folder > SubFolder > SubFolder
    
    
    // _Root_Folder > SubFolder > Document
    if ([xmlElement isEqualToString:@"Document"] && attributeDict[@"file"]) {
        xmlDocument = [[EFFDocument alloc] init];
        xmlDocument.title = attributeDict[@"title"];
        xmlDocument.file = attributeDict[@"file"];
        xmlDocument.type = attributeDict[@"type"];
        
    }
    
    // _Root_Folder > SubFolder > Document > Topic
    if ([xmlElement isEqualToString:@"Topic"] && attributeDict[@"name"] && xmlDocument != nil) {
        NSString *topicName = attributeDict[@"name"];
        NSInteger index;
        if ([tempTopicsArray containsObject:topicName]) {
            index = [tempTopicsArray indexOfObject:topicName];
            EFFTopic *topic = (EFFTopic *)[xmlSubFolder.topics objectAtIndex:index];
            [topic.documents addObject:xmlDocument];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"SubFolder"] && isSubFolder) {
        
        [user.EFFArray addObject:xmlSubFolder];
        isSubFolder = NO;
    
        // clear variables
        xmlDocument = nil;
        xmlTopic = nil;
        [tempTopicsArray removeAllObjects];
    }
}

- (BOOL)isEFFSubFolder:(NSString *)string {
    if ([string isEqualToString:@"Crew Info"] ||
        [string isEqualToString:@"NOTAM"] ||
        [string isEqualToString:@"NOTAMS"] ||
        [string isEqualToString:@"METEO"] ||
        [string isEqualToString:@"Weather"] ||
        [string isEqualToString:@"Flight Plan"] ||
        [string isEqualToString:@"Paper Flight Plan"]) {
        return YES;
    }
    return NO;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    [SVProgressHUD showWithStatus:@"Parsing XML..."];
    
    user = [[User alloc] init];
    user = [User sharedInstance];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [SVProgressHUD showSuccessWithStatus:@"Parsing Done."];
    
    [tempTopicsArray removeAllObjects];
    tempTopicsArray = nil;
    xmlElement = nil;
    xmlAttrib = nil;
    xmlSubFolder = nil;
    [xmlSubFolderTopics removeAllObjects];
    xmlSubFolderTopics = nil;
    xmlTopic = nil;
    xmlDocument = nil;
    isSubFolder = nil;
    
    NSLog(@"%@",user.EFFArray);
    
    return;
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

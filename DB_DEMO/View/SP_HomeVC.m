//
//  SP_HomeVC.m
//  Sploops
//
//  Created by Mac009 on 8/17/15.
//  Copyright (c) 2015 Tatva. All rights reserved.
//

//#import "SP_HomeVC.h"
//#import "SP_SharedActionSheet.h"
//#import "SIAlertView.h"
//#import "SP_RantCell.h"
//#import "SP_RantInfoModel.h"
//#import "TSMessageView.h"
//#import <AVFoundation/AVFoundation.h>
//#import "UIImageView+WebCache.h"
//#import "UIButton+WebCache.h"
//#import "DownloadManager.h"
//#import "YIFullScreenScroll.h"
//#import "UIViewController+YIFullScreenScroll.h"
//#import "SP_ChooseTeamVC.h"
//#import "UIImageView+WebCache.h"
//#import "VideoSublayerView.h"
//
//#define MAX_COUNT_RANT 20
//
//@interface SP_HomeVC ()<UITextViewDelegate,UITableViewDataSource,UITableViewDelegate,ChooseTeam>
//{
//    //Ws
//    NSUInteger pageLatest,pageFollowing,pagePopular,pageMyteams;
//    BOOL isCallingService;
//    BOOL isAllData_Latest,isAllData_Following,isAllData_Popular,isAllData_Myteams;
//    NSArray *arrVideos;
//    
//    //Avplayer things
////    AVPlayer *player;
////    AVPlayerLayer *playerLayer;
////    AVAsset *asset;
////    AVPlayerItem *playerItem;
//    VideoSublayerView *videoView;
//    
//    NSUInteger curPlayingCell;
//    NSMutableArray *arrFilteredId;
//}
//@end
//
//@implementation SP_HomeVC
//@synthesize arrRantFollowing,arrRantLatest,arrRantMyteams,arrRantPopular;
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    [self setEdgesForExtendedLayout:UIRectEdgeAll];
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.extendedLayoutIncludesOpaqueBars = NO;
//    self.navigationController.navigationBar.translucent = YES;
//    curPlayingCell = -1;
//    arrVideos = @[@"1441360447.829546_324_",@"1441621990.043273_320_",@"1441622293.094094_320_",@"1441623426.630412_320_",@"1441623041.550612_320_"];//.mp4
//    // Do any additional setup after loading the view.
//    self.navigationItem.rightBarButtonItem = [self createRightButton_withVC:self withText:nil withSelector:@selector(btnFilterPressed)];
//    
//    self.navigationItem.leftBarButtonItem = [CommonMethods leftMenuButton:self WithImageName:@"add_friends" withSelector:@selector(friendsBtnPressed)];
//    
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sploops_logo"]];
//    
//    arrRantFollowing = [[NSMutableArray alloc]init];
//    arrRantLatest = [[NSMutableArray alloc]init];
//    arrRantMyteams = [[NSMutableArray alloc]init];
//    arrRantPopular = [[NSMutableArray alloc]init];
//    arrFilteredId = [[NSMutableArray alloc]init];
//    lblNoRants.alpha = 0.0;
//    [CommonMethods addSegmentControlAttributes:segmentHome];
//    segmentHome.sectionTitles = @[@" LATEST ",@" FOLLOWING ",@" POPULAR ",@" MY TEAMS "];
//    segmentHome.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0,10, 0, 10);
//    segmentHome.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
//    
//    [CommonMethods registerNibToTable:tblView WithName:@"SP_RantCell"];
//
//    isCallingService = NO;
//    isAllData_Latest =isAllData_Following=isAllData_Popular=isAllData_Myteams = NO;
//    
//    [tblView.refreshControl addTarget:self action:@selector(refreshControlRefresh:) forControlEvents:UIControlEventValueChanged];
//    
//    kApplicationData.isUpdate_Home = NO;
//    self.curViewType = RANT_LATEST;
//    pageLatest = pageFollowing = pagePopular = pageMyteams=1;
//    [self getData:YES];
//    
//    __weak SP_HomeVC *weakSelf = self;
//    segmentHome.indexChangeBlock = ^(NSInteger index){
//        if (index==RANT_FOLLOWING || index==RANT_MYTEAMS) {
//            [kApplicationData checkIfUserLoggedIN:weakSelf Completion:^(BOOL success, id result, BOOL cancel) {
//                weakSelf.curViewType = (int)index;
//                [weakSelf  reloadAndShowHide];
//            }];
//        }
//        else{
//            weakSelf.curViewType = (int)index;
//            [weakSelf  reloadAndShowHide];
//        }
//    };
//    
//    appDel.mainTabBar =(SP_MainTabbarController*) self.tabBarController;
//   // tblView.contentInset = UIEdgeInsetsZero;
//    tblView.contentInset = UIEdgeInsetsMake(104, 0, 49, 0);
//    
//    //tblView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
//    tblView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, tblView.bounds.size.width, 0.01f)];
//    
//    self.fullScreenScroll = [[YIFullScreenScroll alloc] initWithViewController:self scrollView:tblView style:YIFullScreenScrollStyleFacebook];
//    self.fullScreenScroll.additionalOffsetYToStartHiding = 64.0;
//    self.fullScreenScroll.additionalOffsetYToStartShowing = 64.0;
//    self.fullScreenScroll.shouldHideUIBarsWhenNotDragging = YES;
//    self.fullScreenScroll.shouldHideTabBarOnScroll = NO;
//    self.fullScreenScroll.showHideAnimationDuration = 0.3;
//    self.fullScreenScroll.shouldShowUIBarsOnScrollUp = NO;
//    self.fullScreenScroll.sectionView = viewSegment;
//    viewSegment.hidden = NO;
//    
//    [[self.tabBarController.tabBar.items objectAtIndex:3] setMyAppCustomBadgeValue:BADGECOUNT];
//
//}
//
//-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [[DownloadManager sharedManager]resumeDownload];
//    if (kApplicationData.isUpdate_Home) {
//        [self refreshAndReloadAllData];
//        kApplicationData.isUpdate_Home = NO;
//    }
//    [tblView reloadData];
//}
//
//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    [[DownloadManager sharedManager]pauseDownload];
//    [self stopPlayer];
//}
//
//-(void)refreshAndReloadAllData{
//    [arrFilteredId removeAllObjects];
//    filterButton.selected = NO;
//    pageLatest = 1;
//    isAllData_Latest = NO;
//    pageFollowing = 1;
//    isAllData_Following = NO;
//    pagePopular = 1;
//    isAllData_Popular = NO;
//    pageMyteams = 1;
//    isAllData_Myteams = NO;
//    [self getData:YES];
//}
//
//
//-(void)reloadAndShowHide{
//    tblView.dataSource = nil;
//    tblView.delegate = nil;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        switch (self.curViewType) {
//            case RANT_LATEST:
//            {
//                tblView.dataSource = self;
//                tblView.delegate = self;
//                if ((arrRantLatest.count==0 && isAllData_Latest==NO)){
//                    [self getData:YES];
//                }
//                else{
//                    [tblView reloadData];
//                    lblNoRants.alpha = (arrRantLatest.count==0) ? 1 : 0;
//                }
//            }
//                break;
//            case RANT_FOLLOWING:
//            {
//                tblView.dataSource = self;
//                tblView.delegate = self;
//                if ((arrRantFollowing.count==0 && isAllData_Following==NO)){
//                    [self getData:YES];
//                }
//                else{
//                    [tblView reloadData];
//                    lblNoRants.alpha = (arrRantFollowing.count==0) ? 1 : 0;
//                }
//            }
//                break;
//            case RANT_POPULAR:
//            {
//                tblView.dataSource = self;
//                tblView.delegate = self;
//                if ((arrRantPopular.count==0 && isAllData_Popular==NO)){
//                    [self getData:YES];
//                }
//                else{
//                    [tblView reloadData];
//                    lblNoRants.alpha = (arrRantPopular.count==0) ? 1 : 0;
//                }
//            }
//                break;
//            case RANT_MYTEAMS:
//            {
//                tblView.dataSource = self;
//                tblView.delegate = self;
//                if ((arrRantMyteams.count==0 && isAllData_Myteams==NO)){
//                    [self getData:YES];
//                }
//                else{
//                    [tblView reloadData];
//                    lblNoRants.alpha = (arrRantMyteams.count==0) ? 1 : 0;
//                }
//            }
//                break;
//                
//            default:
//                break;
//        }
//        [self downloadVideosInBackground];
//        [self stopPlayer];
//    });
//}
//
//#pragma mark - GetData
//
//-(void)refreshControlRefresh:(BOOL)isShowHud
//{
//    switch (self.curViewType) {
//        case RANT_LATEST:
//        {
//            pageLatest = 1;
//            isAllData_Latest = NO;
//        }
//            break;
//        case RANT_FOLLOWING:
//        {
//            pageFollowing = 1;
//            isAllData_Following = NO;
//        }
//            break;
//        case RANT_POPULAR:
//        {
//            pagePopular = 1;
//            isAllData_Popular = NO;
//        }
//            break;
//        case RANT_MYTEAMS:
//        {
//            pageMyteams = 1;
//            isAllData_Myteams = NO;
//        }
//            break;
//            
//        default:
//            break;
//    }
//    
//    isCallingService = YES;
//    if (!isShowHud) {
//        [tblView.refreshControl beginRefreshing];
//    }
//    [self getData:isShowHud];
//}
//
//-(void)getData:(BOOL)isShowHud{
//    isCallingService = YES;
//    [[DownloadManager sharedManager]pauseAmazonRequest];
//    [kAFAPIClient cancelOperationsWithURL:CANCEL_PATH(Web_POST_RANTS)];
//    switch (self.curViewType) {
//        case RANT_LATEST:
//        {
//            if (pageLatest != 1) {
//                [tblView.viewFooter.indicator startAnimating];
//                tblView.tableFooterView = tblView.viewFooter;
//            }
//            if (isShowHud) {
//                showHUD;
//            }
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                NSDictionary *dict = @{@"filter":[NSString stringWithFormat:@"%lu",(unsigned long)self.curViewType],@"page":[NSString stringWithFormat:@"%lu",(unsigned long)pageLatest],@"Teams":arrFilteredId};
//                [self getRants:dict PageNum:pageLatest ForType:self.curViewType];
//
//            });
//        }
//            break;
//        case RANT_FOLLOWING:
//        {
//            if (pageFollowing != 1) {
//                [tblView.viewFooter.indicator startAnimating];
//                tblView.tableFooterView = tblView.viewFooter;
//            }
//            if (isShowHud) {
//                showHUD;
//            }
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                NSDictionary *dict = @{@"filter":[NSString stringWithFormat:@"%lu",(unsigned long)self.curViewType],@"page":[NSString stringWithFormat:@"%lu",(unsigned long)pageFollowing],@"Teams":arrFilteredId};
//                [self getRants:dict PageNum:pageFollowing ForType:self.curViewType];
//
//            });
//        }
//            break;
//        case RANT_POPULAR:
//        {
//            if (pagePopular != 1) {
//                [tblView.viewFooter.indicator startAnimating];
//                tblView.tableFooterView = tblView.viewFooter;
//            }
//            if (isShowHud) {
//                showHUD;
//            }
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                NSDictionary *dict = @{@"filter":[NSString stringWithFormat:@"%lu",(unsigned long)self.curViewType],@"page":[NSString stringWithFormat:@"%lu",(unsigned long)pagePopular],@"Teams":arrFilteredId};
//                [self getRants:dict PageNum:pagePopular ForType:self.curViewType];
//
//            });
//        }
//            break;
//        case RANT_MYTEAMS:
//        {
//            if (pageMyteams != 1) {
//                [tblView.viewFooter.indicator startAnimating];
//                tblView.tableFooterView = tblView.viewFooter;
//            }
//            if (isShowHud) {
//                showHUD;
//            }
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                NSDictionary *dict = @{@"filter":[NSString stringWithFormat:@"%lu",(unsigned long)self.curViewType],@"page":[NSString stringWithFormat:@"%lu",(unsigned long)pageMyteams],@"Teams":arrFilteredId};
//                [self getRants:dict PageNum:pageMyteams ForType:self.curViewType];
//            });
//        }
//            break;
//
//        default:
//            break;
//    }
//}
//
//-(void)getRants:(NSDictionary*)params PageNum:(NSUInteger)pageNumber ForType:(NSUInteger)type{
//    //NSLog(@"%ld",(unsigned long)pageNumber);
//    isCallingService = YES;
//    [kAFAPIClient POST:Web_POST_RANTS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        hideHUD
//        NSUInteger totalCount=0;
//        tblView.alpha = 1.0;
//        [tblView removeFooterView];
//        //NSLog(@"%@",responseObject);
//        if (pageNumber == 1) {
//            //[arrPeople removeAllObjects];
//            switch (type) {
//                case RANT_LATEST:
//                {
//                    [arrRantLatest removeAllObjects];
//                }
//                    break;
//                case RANT_FOLLOWING:
//                {
//                    [arrRantFollowing removeAllObjects];
//                }
//                    break;
//                case RANT_POPULAR:
//                {
//                    [arrRantPopular removeAllObjects];
//                }
//                    break;
//                case RANT_MYTEAMS:
//                {
//                    [arrRantMyteams removeAllObjects];
//                }
//                    break;
//                    
//                default:
//                    break;
//            }
//            
//        }
//        else{
//            [self showUIbars:YES Compulsary:YES];
//        }
//        if ([responseObject isKindOfClass:[NSDictionary class]])
//        {
//
//            if ([[responseObject objectForKey:@"Rants"] isKindOfClass:[NSArray class]])
//            {
//                NSArray *arrAll = [responseObject objectForKey:@"Rants"];
//                BOOL isALLData = NO;
//                NSMutableArray *arrRants = [[NSMutableArray alloc]init];
//                [arrAll enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                    SP_RantInfoModel *model  = [[SP_RantInfoModel alloc]initWithDictionary:obj];
////                    model.videoIndex = arc4random()%arrVideos.count;
////                    NSString *str = create_AmazonURL([arrVideos[model.videoIndex] stringByAppendingString:@"thumb.png"]);
////                    model.ThumbnailURL = str;
////                    NSString *strVideo = create_AmazonURL([arrVideos[model.videoIndex] stringByAppendingString:@".mp4"]);
////                    model.VideoURL = strVideo;
//                    [arrRants addObject:model];
//                   // NSLog(@"%@",model.ID.stringValue);
//                }];
//                
////                [self setData:arrAll withHandler:^(NSMutableArray *dataArray){
////                    
////                }];
////                
//                if (arrAll.count==0) {
//                    isALLData = YES;
//                }
//                switch (type) {
//                    case RANT_LATEST:
//                    {
//                        isAllData_Latest = isALLData;
//                        if(pageNumber!=1){
//                            [self updateArrayAndTable:arrRantLatest NewArrData:arrRants];
//                            totalCount = arrRantLatest.count;
//                        }
//                        else{
//                            [arrRantLatest addObjectsFromArray:arrRants];
//                            totalCount = arrRantLatest.count;
//                        }
//                    }
//                        break;
//                    case RANT_FOLLOWING:
//                    {
//                        isAllData_Following = isALLData;
//                        if(pageNumber!=1){
//                            [self updateArrayAndTable:arrRantFollowing NewArrData:arrRants];
//                            totalCount = arrRantFollowing.count;
//                        }
//                        else{
//                            [arrRantFollowing addObjectsFromArray:arrRants];
//                            totalCount = arrRantFollowing.count;
//                        }
//                    }
//                        break;
//                    case RANT_POPULAR:
//                    {
//                        isAllData_Popular = isALLData;
//                        if(pageNumber!=1){
//                            [self updateArrayAndTable:arrRantPopular NewArrData:arrRants];
//                            totalCount = arrRantPopular.count;
//                        }
//                        else{
//                            [arrRantPopular addObjectsFromArray:arrRants];
//                            totalCount = arrRantPopular.count;
//                        }
//                    }
//                        break;
//                    case RANT_MYTEAMS:
//                    {
//                        isAllData_Myteams = isALLData;
//                        if(pageNumber!=1){
//                            [self updateArrayAndTable:arrRantMyteams NewArrData:arrRants];
//                            totalCount = arrRantMyteams.count;
//                        }
//                        else{
//                            [arrRantMyteams addObjectsFromArray:arrRants];
//                            totalCount = arrRantMyteams.count;
//                        }
//                    }
//                        break;
//                        
//                    default:
//                        break;
//                }
//
//                
//            }
//        }
//        
//        if (pageNumber==1) {
//            [tblView reloadData];
//            [tblView.refreshControl endRefreshing];
//            lblNoRants.alpha = totalCount==0?1:0;
//            isCallingService = NO;
//            [self downloadVideosInBackground];
//            [self startCurrentVideoPlay:tblView];
//        }
//        else{
////            NSMutableArray *arrPaths = [[NSMutableArray alloc]init];
////            for (NSUInteger i=lastIndex; i<totalCount; i++) {
////                [arrPaths addObject:[NSIndexPath indexPathForRow:0 inSection:i]];
////            }
////            [tblView beginUpdates];
////            //[tblView insertRowsAtIndexPaths:arrPaths withRowAnimation:UITableViewRowAnimationBottom];
////            [tblView insertSections:[NSIndexSet indexSetWithIndexesInRange:] withRowAnimation:<#(UITableViewRowAnimation)#>
////            [tblView endUpdates];
//            [[DownloadManager sharedManager]resumeAmazonRequest];
//            [self.fullScreenScroll showUIBarsAnimated:YES];
//            
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        hideHUD
//        [tblView.viewFooter.indicator stopAnimating];
//        tblView.tableFooterView = nil;
//        //[CommonMethods removeFooterView:tblView];
//        [tblView.refreshControl endRefreshing];
//        //isCallingService = NO;
//        tblView.alpha = 1.0;
//        [tblView reloadData];
//        [CommonMethods handleErrorOperation:operation withError:error];
//        [self.fullScreenScroll showUIBarsAnimated:YES];
//    }];
//}
//
//
//-(void)updateArrayAndTable:(NSMutableArray*)arr NewArrData:(NSArray*)arrRants{
//    NSInteger lastIndex = arr.count;
//    NSInteger totalCount = arrRants.count+lastIndex;
//    NSMutableIndexSet *set = [[NSMutableIndexSet alloc]init];
//    
//    for (NSUInteger i = lastIndex; i < totalCount; i++) {
//        
//        [set addIndex:i];
//    }
//    [arr addObjectsFromArray:arrRants];
//    [tblView beginUpdates];
//    [tblView insertSections:set
//           withRowAnimation:UITableViewRowAnimationBottom];
//    [tblView endUpdates];
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [tblView.refreshControl endRefreshing];
//        lblNoRants.alpha = arr==0?1:0;
//        isCallingService = NO;
//    });
//}
//
//-(void)setData:(NSArray *)arrTemp withHandler:(void (^)(NSMutableArray*))completionBlock{
//    @try {
//        NSMutableArray *arrAdd = [[NSMutableArray alloc]init];
//            for (int j = 0; j<arrTemp.count; j++)
//            {
//                SP_RantInfoModel *model  = [[SP_RantInfoModel alloc]initWithDictionary:arrTemp[j]];
//                [arrAdd addObject:model];
//            }
//             completionBlock(arrAdd);
//        
//    }
//    @catch (NSException *exception) {
//        
//    }
//    @finally {
//        
//    }
//}
//
//-(void)getDataAndUpdateTbl{
//    showIndicator;
//    NSDictionary *dict = @{@"filter":[NSString stringWithFormat:@"%lu",(unsigned long)self.curViewType],@"page":[NSString stringWithFormat:@"1"],@"Teams":arrFilteredId};
//    [kAFAPIClient POST:Web_POST_RANTS parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if ([responseObject isKindOfClass:[NSDictionary class]])
//        {
//            
//            if ([[responseObject objectForKey:@"Rants"] isKindOfClass:[NSArray class]])
//            {
//                NSArray *arrAll = [responseObject objectForKey:@"Rants"];
//                NSMutableArray *arrRants = [[NSMutableArray alloc]init];
//                [arrAll enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                    SP_RantInfoModel *model  = [[SP_RantInfoModel alloc]initWithDictionary:obj];
//                    [arrRants addObject:model];
//                }];
//                
//                NSArray *arrID = [arrRants valueForKey:@"ID"];
//                NSMutableArray *curArray = [[NSMutableArray alloc]initWithArray:[self getLatestArray]];
//                NSArray *arrID1 = [curArray valueForKey:@"ID"];
//                
//                NSMutableSet *intersection = [NSMutableSet setWithArray:arrID];
//                [intersection intersectSet:[NSSet setWithArray:arrID1]];
//
//                NSArray *array4 = [intersection allObjects];
//                [array4 enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
//                    NSArray *newId = [arrRants filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ID == %@",obj]];
//                    if (newId.count>0) {
//                        [curArray insertObject:newId[0] atIndex:0];
//                        [arrRants removeObject:newId[0]];
//                    }
//
//                }];
////                NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
////                for (NSString *key in arrID) {
////                    [subPredicates addObject:[NSPredicate predicateWithFormat:@"ID == %@",key]];
////                }
////                NSPredicate *matchAttributes = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
////                NSArray *newItems = [[self getLatestArray] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ID NOT IN "]];
//            }
//        }
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
//}
//
//-(NSUInteger)addObjectIfNotAvailableRant:(NSMutableArray*)arrRants OldArray:(NSMutableArray*)old{
//     NSUInteger oldCount=old.count;
//     NSUInteger newId=0;
//    
//        for (SP_RantInfoModel *obj in arrRants) {
//            NSArray *newId = [old filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ID == %@",obj]];
//            if (newId.count>0) {
//                NSUInteger index = [old indexOfObject:newId[0]];
//                [old replaceObjectAtIndex:index withObject:obj];
//            }
//            else{
//                [old insertObject:newId[0] atIndex:0];
//            }
//        }
//    newId = oldCount- arrRants.count;
//    return newId;
//}
//
//
//#pragma mark - Buttonclicks
//- (UIBarButtonItem*)createRightButton_withVC:(UIViewController *)vc withText:(NSString *)strText withSelector:(SEL)mySelector
//{
//        UIImage *buttonImage = [UIImage imageNamed:@"filter"];
//        UIImage *buttonImageSelected = [UIImage imageNamed:@"filter_selected"];
//        filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [filterButton setImage:buttonImage forState:UIControlStateNormal];
//        [filterButton setImage:buttonImageSelected forState:UIControlStateSelected];
//        [filterButton setImage:buttonImageSelected forState:UIControlStateHighlighted];
//        filterButton.frame = CGRectMake(0, 0, buttonImage.size.width , buttonImage.size.height);
//        [filterButton addTarget:vc action:mySelector forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
//    
//    return retVal;
//}
//
//
//-(void)sortPressed{
////    [TSMessage showNotificationInViewController:self
////                                          title:nil
////                                       subtitle:nil
////                                          image:nil
////                                           type:TSMessageNotificationTypeMessage
////                                       duration:TSMessageNotificationDurationEndless
////                                       callback:nil
////                                    buttonTitle:NSLocalizedString(@"1 new Rant", nil)
////                                 buttonCallback:^{
////                                     [TSMessage dismissActiveNotification];
////                                 }
////                                     atPosition:TSMessageNotificationPositionTop
////                           canBeDismissedByUser:YES];
//}
//
//-(void)friendsBtnPressed{
////    SP_ChooseTeamVC *chooseTeam = (SP_ChooseTeamVC*)[self.storyboard instantiateViewControllerWithIdentifier:ID_CHOOSE_TEAMS];
////    chooseTeam.curViewType = SELECT;
////    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chooseTeam];
////    [self.navigationController presentViewController:nav animated:YES completion:nil];
//}
//
//-(void)btnMorePressed:(UIButton*)moreBtn{
//    [kApplicationData checkIfUserLoggedIN:self Completion:^(BOOL success, id result, BOOL isNewUser) {
//        if (!isNewUser) {
//            //Update all ws and data for already logged in user
//            [self refreshAndReloadAllData];
//            return;
//        }
//        NSInteger index = moreBtn.tag-500;
//        SP_RantInfoModel *model = [self getModelForIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
//        [[SP_SharedActionSheet sharedManager]getShareActionsheetWithVIew:self WitModel:model Completionn:^(BOOL success, BOOL isRemove) {
//            
//        }];
//    }];
//}
//
//-(void)btnCommentPressed:(UIButton*)commentBtn{
//    [kApplicationData checkIfUserLoggedIN:self Completion:^(BOOL success, id result, BOOL isNewUser) {
//        if (!isNewUser) {
//            //Update all ws and data for already logged in user
//            [self refreshAndReloadAllData];
//            return;
//        }
//        NSInteger index = commentBtn.tag-3000;
//        SP_RantInfoModel *model = [self getModelForIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
//        [CommonMethods pushDetailWithRant:model VC:self isAnimated:YES];
//    }];
//}
//
//-(void)btnUpVotePressed:(UIButton*)btnUp{
//    [kApplicationData checkIfUserLoggedIN:self Completion:^(BOOL success, id result, BOOL isNewUser) {
//        if (!isNewUser) {
//            //Update all ws and data for already logged in user
//            [self refreshAndReloadAllData];
//            return;
//        }
//        NSInteger index = btnUp.tag-20000;
//        btnUp.userInteractionEnabled = NO;
//        SP_RantInfoModel *model = [self getModelForIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
//        if(model.HasUserDownVoted){
//            model.NumberOfUpVotes = [NSNumber numberWithInt:model.NumberOfUpVotes.intValue+1];
//            [self upvoteOrDownVoteRant:(int)index value:1];
//        }
//        else if (!model.HasUserUpVoted) {
//            model.NumberOfUpVotes = [NSNumber numberWithInt:model.NumberOfUpVotes.intValue+1];
//            [self upvoteOrDownVoteRant:(int)index value:1];
//        }
//        }];
//}
//
//-(void)btnDownVotePressed:(UIButton*)btnDown{
//    [kApplicationData checkIfUserLoggedIN:self Completion:^(BOOL success, id result, BOOL isNewUser) {
//        if (!isNewUser) {
//            //Update all ws and data for already logged in user
//            [self refreshAndReloadAllData];
//            return;
//        }
//        NSInteger index = btnDown.tag-10000;
//        btnDown.userInteractionEnabled = NO;
//        SP_RantInfoModel *model = [self getModelForIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
//        if(model.HasUserUpVoted){
//            model.NumberOfUpVotes = [NSNumber numberWithInt:model.NumberOfUpVotes.intValue-1];
//            [self upvoteOrDownVoteRant:(int)index value:-1];
//        }
//        else if (!model.HasUserDownVoted) {
//            model.NumberOfDownVotes = [NSNumber numberWithInt:model.NumberOfDownVotes.intValue+1];
//            [self upvoteOrDownVoteRant:(int)index value:-1];
//        }
//    }];
//}
//
//-(void)btnFollowPressed:(UIButton*)btnFollow{
//    [kApplicationData checkIfUserLoggedIN:self Completion:^(BOOL success, id result, BOOL isNewUser) {
//        if (!isNewUser) {
//            //Update all ws and data for already logged in user
//            [self refreshAndReloadAllData];
//            return;
//        }
//        else{
//        NSInteger index = btnFollow.tag-5000;
//        btnFollow.userInteractionEnabled = NO;
//        SP_RantInfoModel *model = [self getModelForIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
//       // [cell.btnFollow setImage:[UIImage imageNamed:cellModel.IsFollowing ? @"tick":@"add_btn"] forState:UIControlStateNormal]
//        ASYNC_MAIN(
//        [kAFAPIClient followUnfollowUser:!model.IsFollowing UserId:model.UserID.stringValue Completion:^(BOOL success1, id result, NSError *error) {
//            hideIndicator
//            btnFollow.userInteractionEnabled = YES;
//            if (success1) {
//                //model.IsFollowing = !model.IsFollowing;
//                [btnFollow setImage:[UIImage imageNamed:model.IsFollowing ? @"tick":@"add_btn"] forState:UIControlStateNormal];
//            }
//        }];);
//        }
//    }];
//}
//
//-(void)btnFilterPressed{
//    SP_ChooseTeamVC *teamVC =[self.storyboard instantiateViewControllerWithIdentifier:ID_CHOOSE_TEAMS];
//    teamVC.curViewType = FILTER;
//    teamVC.delegate = self;
//    if (arrFilteredId.count>0) {
//        teamVC.taggedTeams = [NSMutableArray arrayWithArray:arrFilteredId];
//    }
//    [self.navigationController pushViewController:teamVC animated:NO];
//}
//-(void)selectedTeams:(NSArray*)teams{
//    if (teams.count>0) {
//        NSArray *arrId = [teams valueForKey:@"ID"];
//        arrFilteredId = [NSMutableArray arrayWithArray:arrId];
//        filterButton.selected = YES;
//        pageLatest = 1;
//        isAllData_Latest = NO;
//        pageFollowing = 1;
//        isAllData_Following = NO;
//        pagePopular = 1;
//        isAllData_Popular = NO;
//        pageMyteams = 1;
//        isAllData_Myteams = NO;
//        [self getData:YES];
//    }
//    else{
//        filterButton.selected = NO;
//    }
//}
//
//
//-(void)upvoteOrDownVoteRant:(int)index value:(int)value{
//    showIndicator;
//    SP_RantInfoModel *model = [self getModelForIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
//    [kAFAPIClient POST:WEB_POST_UPDOWNVOTE parameters:@{@"ID":model.ID.stringValue,@"Value":[NSString stringWithFormat:@"%d",value]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        hideIndicator;
//       // ASYNC_MAIN(
//        [model calculateAndUpdateVotes];
//        SP_RantCell *cell = (SP_RantCell*)[tblView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
//        [cell updateUIAfterUpvoteOrDownVote:model value:value];
//        [tblView beginUpdates];
//       [tblView reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationFade];
//        [tblView endUpdates];
//        //[tblView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:index]] withRowAnimation:UITableViewRowAnimationFade];
//        
//        [kApplicationData refreshAllTabbedRant:model];
//            //       );
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        hideIndicator;
//        [CommonMethods handleErrorOperation:operation withError:error];
//    }];
//}
//
//
//#pragma mark - Uitextfield Delegates
//
//- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
//    
//    if ([[URL scheme] isEqualToString:VALUE_TEAMNAME]) {
//        //NSString *userid = [URL host];
//        return NO; // let the system open this URL
//    }
//    return YES;
//}
//
//
//#pragma mark - Avplayer things
//
//-(void)stopPlayer{
//    if (videoView) {
//        [videoView stopPlayer];
//        videoView = nil;
//    }
//}
//
//-(void)playVideoForIndex:(SP_RantCell*)cell{
//    NSIndexPath *path = [tblView indexPathForCell:cell];
//    NSInteger cellIndex = path.section;
//    SP_RantInfoModel *model = [self getLatestArray][cellIndex];
//    if (curPlayingCell!=cellIndex) {
//        //NSUInteger indexTouse = arc4random()%3;
//        //NSFileManager *fm = [NSFileManager defaultManager];
//        NSString *key = [model.VideoURL lastPathComponent];
//        if (key.length==0) {
//            return;
//        }
//        
//        [self stopPlayer];
//        
//        
//    //        else{
//    //        NSString *path = [DocumentsDirectoryPath() stringByAppendingPathComponent:key];
//    //        NSURL *url = [NSURL fileURLWithPath:path];
//
//
////        if (player) {
////            playerLayer.hidden = YES;
////            [player pause];
////            [playerLayer removeFromSuperlayer];
////            playerLayer= nil;
////            player = nil;
////            asset = nil;
////        }
////        if (![fm fileExistsAtPath:[DocumentsDirectoryPath() stringByAppendingPathComponent:key]])
////        {
////            NSURL *url = [NSURL URLWithString:model.VideoURL];
////            playerItem = [AVPlayerItem playerItemWithURL:url];
////            player = [AVPlayer playerWithPlayerItem:playerItem];
////            playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
////            playerLayer.frame = cell.viewVideo.bounds;
////            playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
////            [cell.viewVideo.layer addSublayer:playerLayer];
////            curPlayingCell = cellIndex;
////            player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
////            [self addPlayerObservers];
////        }
////        else{
////        NSString *path = [DocumentsDirectoryPath() stringByAppendingPathComponent:key];
////        NSURL *url = [NSURL fileURLWithPath:path];
////        AVURLAsset *newAsset = [AVURLAsset URLAssetWithURL:url options:nil];
////        playerItem = [AVPlayerItem playerItemWithAsset:newAsset];
////        asset = newAsset;
////        player = [AVPlayer playerWithPlayerItem:playerItem];
////        playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
////        playerLayer.frame = cell.viewVideo.bounds;
////        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
////        [cell.viewVideo.layer addSublayer:playerLayer];
////        curPlayingCell = cellIndex;
////        player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
////        [self addPlayerObservers];
////        }
//       //
//    }
//}
//
////-(void)removePlayerObserver{
////    //[self removeObserver:self forKeyPath:@"status"];
////   // [[NSNotificationCenter defaultCenter]removeObserver:self forKeyPath:AVPlayerItemDidPlayToEndTimeNotification];
////}
//
////-(void)addPlayerObservers{
////    [self removePlayerObserver];
////    [[NSNotificationCenter defaultCenter] addObserver:self
////                                             selector:@selector(playerItemDidReachEnd:)
////                                                 name:AVPlayerItemDidPlayToEndTimeNotification
////                                               object:[player currentItem]];
////   
////    //[player addObserver:self forKeyPath:@"status" options:0 context:nil];
////}
//
////- (void)playerItemDidReachEnd:(NSNotification *)notification {
////    AVPlayerItem *p = [notification object];
////    [p seekToTime:kCMTimeZero];
////}
//
////- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
////    
////    if (object == player && [keyPath isEqualToString:@"status"]) {
////        if (player.status == AVPlayerStatusFailed) {
////            NSLog(@"AVPlayer Failed");
////        } else if (player.status == AVPlayerStatusReadyToPlay) {
////            NSLog(@"AVPlayer Ready to Play");
////        } else if (player.status == AVPlayerItemStatusUnknown) {
////            NSLog(@"AVPlayer Unknown");
////        }
////    }
////}
//
//
//
//#pragma mark - Table View Methods
////- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
////    if(section==0)return viewSegment;
////    else return nil;
////}
////
////- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
////    if(section==0)return segmentHome.frame.size.height;
////    else return 0;
////}
//
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//    @try {
//        switch (self.curViewType) {
//            case RANT_LATEST:
//            {
//                return arrRantLatest.count;
//            }
//                break;
//            case RANT_FOLLOWING:
//            {
//                return  arrRantFollowing.count;
//            }
//                break;
//            case RANT_POPULAR:
//            {
//                return  arrRantPopular.count;
//            }
//                break;
//            case RANT_MYTEAMS:
//            {
//                return  arrRantMyteams.count;
//            }
//                break;
//                
//            default:
//                break;
//        }
//        
//    }
//    @catch (NSException *exception) {
//        
//    }
//    @finally {
//        
//    }
//
//    return 0;
//}
////-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
////    return 0;
////}
////
////- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
////    return 10;
////}
//
////- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
////    UIView *viewFo = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tblView.frame.size.width, 20)];
////    viewFo.backgroundColor = RGBCOLOR(223, 223, 223);
////    return viewFo;
////}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    //NSLog(@"%f",[self heightForBasicCellAtIndexPath:indexPath]);
//    return [self heightForBasicCellAtIndexPath:indexPath];
//}
//
//- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
//    static SP_RantCell *sizingCell = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sizingCell = [tblView dequeueReusableCellWithIdentifier:@"SP_RantCell"];
//    });
//    
//    [self configureBasicCell:sizingCell atIndexPath:indexPath];
//    return [self calculateHeightForConfiguredSizingCell:sizingCell atIndexPath:indexPath];
//}
//
//-(SP_RantInfoModel*)getModelForIndexPath:(NSIndexPath*)indexPath{
//    SP_RantInfoModel *cellModel;
//    @try {
//        switch (self.curViewType) {
//            case RANT_LATEST:
//            {
//                cellModel = arrRantLatest[indexPath.section];
//            }
//                break;
//            case RANT_FOLLOWING:
//            {
//                cellModel = arrRantFollowing[indexPath.section];
//            }
//                break;
//            case RANT_POPULAR:
//            {
//                cellModel = arrRantPopular[indexPath.section];
//            }
//                break;
//            case RANT_MYTEAMS:
//            {
//                cellModel = arrRantMyteams[indexPath.section];
//            }
//                break;
//                
//            default:
//                break;
//        }
//        
//    }
//    @catch (NSException *exception) {
//        
//    }
//    @finally {
//        
//    }
//    return cellModel;
//}
//
//- (CGFloat)calculateHeightForConfiguredSizingCell:(SP_RantCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    SP_RantInfoModel *curModel = [self getModelForIndexPath:indexPath];
//    if (curModel.cellHeight!=0) {
//        return curModel.cellHeight;
//    }
//    
//    CGFloat fixedHeight;
//    if(IS_IPHONE6 || IS_IPHONE6Plus){
//        fixedHeight = kDEV_PROPROTIONAL(520);
//    }
//    else{
//        fixedHeight = 440;
//    }
//    //[sizingCell setNeedsLayout];
//
//    fixedHeight= fixedHeight-44-24;
//    
//    //CGSize heightTeams = [CommonMethods findHeightForText:cell.tvTeams.text havingWidth:cell.tvTeams.frame.size.width andFont:cell.tvTeams.font];
//    CGFloat heightTeams = [self heightForTextview:cell.tvTeams.frame.size.width Attributedtext:curModel.curAttributedString];
//    //cell.tvTeamsHeight.constant
//    float heightTeamsText = MAX(heightTeams, 23);
//    
//    CGSize heighttext = [CommonMethods findHeightForText:cell.lblText.text havingWidth:cell.lblText.frame.size.width andFont:cell.lblText.font];
//    float heightText = MAX(heighttext.height, 44);
//   // cell.lblTextHeight.constant =
//    [cell.tvTeams sizeToFit];
//    [cell.tvTeams layoutIfNeeded];
//    [cell.lblText layoutIfNeeded];
//    [cell layoutIfNeeded];
//    float size = fixedHeight+heightTeamsText+15+heightText;
//    curModel.cellHeight = size + 1.0f;
//    return size + 1.0f; // Add 1.0f for the cell separator height
//
////    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
////    return size.height + 1.0f; // Add 1.0f for the cell separator height
//}
//
//-(CGFloat)heightForTextview:(CGFloat)width Attributedtext:(NSAttributedString*)str{
//    @autoreleasepool {
//        UITextView *textView = [[UITextView alloc] init];
////        textView.contentInset = UIEdgeInsetsMake(-4,0,0,0);
////        textView.textAlignment = NSTextAlignmentLeft;
//        textView.textContainer.lineFragmentPadding = 0;
//        textView.textContainerInset = UIEdgeInsetsZero;
//        [textView setAttributedText:str];
//        CGSize sizeText = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
//        return ceilf(sizeText.height);
//    }
//}
//
////- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
////{
////    if(IS_IPHONE6 || IS_IPHONE6Plus){
////        return kDEV_PROPROTIONAL(552);
////    }
////    else{
////        return 450;
////    }
////    
////}
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 1;
//}
//
//- (SP_RantCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath {
//    SP_RantCell *cell = [tblView dequeueReusableCellWithIdentifier:@"SP_RantCell" forIndexPath:indexPath];
//    [self configureBasicCell:cell atIndexPath:indexPath];
//    return cell;
//}
//
//- (void)configureBasicCell:(SP_RantCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    
//    SP_RantInfoModel *cellModel;
//    @try {
//        switch (self.curViewType) {
//            case RANT_LATEST:
//            {
//                cellModel = arrRantLatest[indexPath.section];
//            }
//                break;
//            case RANT_FOLLOWING:
//            {
//                cellModel = arrRantFollowing[indexPath.section];
//            }
//                break;
//            case RANT_POPULAR:
//            {
//                cellModel = arrRantPopular[indexPath.section];
//            }
//                break;
//            case RANT_MYTEAMS:
//            {
//                cellModel = arrRantMyteams[indexPath.section];
//            }
//                break;
//                
//            default:
//                break;
//        }
//        
//    }
//    @catch (NSException *exception) {
//        
//    }
//    @finally {
//        
//    }
//    
//    cell.lblText.text = cellModel.Text;
//    cell.lblVotes.text = [NSString stringWithFormat:@"%d",abs(cellModel.TotlaVotes.intValue)];
//    [cell.btnComments setTitle:cellModel.NumberOfComments.stringValue forState:UIControlStateNormal];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    //cell.myIndex = indexPath.section;
//    cell.tvTeams.attributedText=cellModel.curAttributedString;
//    cell.tvTeams.delegate =self;
//    
//    [cell configurecell_withIndex:indexPath];
//        
//    [cell.btnDown addTarget:self action:@selector(btnDownVotePressed:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnUp addTarget:self action:@selector(btnUpVotePressed:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [cell.btnMore addTarget:self action:@selector(btnMorePressed:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnCommentHere addTarget:self action:@selector(btnCommentPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnFollow addTarget:self action:@selector(btnFollowPressed:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [cell.ivCoverPic sd_setImageWithURL:[NSURL URLWithString:cellModel.ThumbnailURL] placeholderImage:PLACE_VIDEO];
//    
//    cell.btnDown.selected= cell.btnUp.selected = NO;
//    cell.lblVotes.textColor = cellModel.TotlaVotes.intValue<0 ?[UIColor redColor] : RGBCOLOR(73, 132, 228);
//    
//    if (cellModel.HasUserUpVoted) {
//        cell.btnUp.selected = YES;
//        cell.btnDown.selected = NO;
//    }
//    
//    if (cellModel.HasUserDownVoted) {
//        cell.btnDown.selected = YES;
//        cell.btnUp.selected = NO;
//    }
//    cell.btnFollow.hidden = NO;
//    if (SHARED_USER.UserID.stringValue) {
//        NSString *strUserId = SHARED_USER.UserID.stringValue;
//        if ([cellModel.UserID.stringValue isEqualToString:strUserId]) {
//            cell.btnFollow.hidden = YES;
//        }
//        else{
//            cell.btnFollow.hidden = NO;
//        }
//    }
//    
//    [cell.btnFollow setImage:[UIImage imageNamed:cellModel.IsFollowing ? @"tick":@"add_btn"] forState:UIControlStateNormal];
//
//
//    cell.btnUp.userInteractionEnabled =  cell.btnDown.userInteractionEnabled =YES;
//    cell.lblName.text = cellModel.Username;
//    [cell.ivProfilePic sd_setImageWithURL:[NSURL URLWithString:cellModel.ImageURL] placeholderImage:PLACE_USER];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//        return [self basicCellAtIndexPath:indexPath];;
//}
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
////    SP_RantInfoModel *model = [self getLatestArray][indexPath.section];
////    if (!model.isVideoDownloaded) {
////        //[[DownloadManager sharedManager]cancelAmazonRequest];
////        [self downloadContentWithStreamItem:model];
////    }
////    //if (curPlayingCell!=indexPath.section) {
////        [self playVideoForModel:(SP_RantCell*)[tblView cellForRowAtIndexPath:indexPath]];
////    //}
//    [self playVideoForModel:(SP_RantCell*)[tblView cellForRowAtIndexPath:indexPath]];
//
//}
//
//
//-(void)playVideoForModel:(SP_RantCell*)cell{
//    NSIndexPath *path = [tblView indexPathForCell:cell];
//    NSInteger cellIndex = path.section;
//    SP_RantInfoModel *model = [self getLatestArray][cellIndex];
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSString *key = [model.VideoURL lastPathComponent];
//    if (key.length==0) {
//        return;
//    }
//    if (videoView) {
//        [videoView stopPlayer];
//        videoView =nil;
//    }
//    if (![fm fileExistsAtPath:[DocumentsDirectoryPath() stringByAppendingPathComponent:key]])
//    {
//        NSURL *url = [NSURL URLWithString:model.VideoURL];
//        videoView = [[VideoSublayerView alloc]initWithFrame:cell.viewVideo.bounds];
//        [videoView playWithLiveStreaming:url];
//        [cell.viewVideo addSubview:videoView];
//        curPlayingCell = cellIndex;
//    }
//    else{
//        NSString *path = [DocumentsDirectoryPath() stringByAppendingPathComponent:key];
//        NSURL *url = [NSURL fileURLWithPath:path];
//        videoView = [[VideoSublayerView alloc]initWithFrame:cell.viewVideo.bounds];
//        [videoView playWithDownloadedVideo:url];
//        [cell.viewVideo addSubview:videoView];
//        curPlayingCell = cellIndex;
//    }
//}
//
//
//#pragma mark - Scrollview
//
//- (void)checkVisibilityOfCell:(SP_RantCell *)cell inScrollView:(UIScrollView *)aScrollView {
//    CGRect videoRect = [cell.contentView convertRect:cell.viewImage.frame toView:cell.contentView];
//    CGRect cellRect = [aScrollView convertRect:cell.frame toView:aScrollView.superview];
//    cellRect.origin.y = cellRect.origin.y+videoRect.origin.y;
//    cellRect.size.height = videoRect.size.height;
//
//    if (CGRectContainsRect(aScrollView.frame, cellRect))
//    {
//        //[cell notifyCompletelyVisible];
//        [self playVideoForIndex:cell];
//        //NSLog(@"%@",cell.lblName.text);
//    }
//    else{
//    
//    }
//        //NSLog(@"%@",cell);
//}
//
//-(void)startCurrentVideoPlay:(UIScrollView*)scrollView{
//    NSArray* cells = tblView.visibleCells;
//    
//    NSUInteger cellCount = [cells count];
//    if (cellCount == 0)
//        return;
//    
//    // Check the visibility of the first cell
//    [self checkVisibilityOfCell:[cells firstObject] inScrollView:scrollView];
//    if (cellCount == 1)
//        return;
//    
//    // Check the visibility of the last cell
//    [self checkVisibilityOfCell:[cells lastObject] inScrollView:scrollView];
//    if (cellCount == 2)
//        return;
//}
//
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [self startCurrentVideoPlay:scrollView];
//    
//    // All of the rest of the cells are visible: Loop through the 2nd through n-1 cells
////    for (NSUInteger i = 1; i < cellCount - 1; i++)
////        [[cells objectAtIndex:i] notifyCompletelyVisible];
//    
//    
//    if (!isCallingService)
//    {
//        switch (self.curViewType) {
//            case RANT_LATEST:
//            {
//                if (!isAllData_Latest && !isCallingService)
//                {
//                    
//                    CGFloat offsetY = scrollView.contentOffset.y;
//                    CGFloat contentHeight = scrollView.contentSize.height;
//                    if (offsetY > contentHeight - scrollView.frame.size.height && arrRantLatest.count >= MAX_COUNT_RANT)
//                    {
//                        pageLatest = pageLatest + 1;
//                        [self getData:NO];
//                    }
//                }
//            }
//                break;
//            case RANT_FOLLOWING:
//            {
//                if (!isAllData_Following && !isCallingService)
//                {
//                    
//                    CGFloat offsetY = scrollView.contentOffset.y;
//                    CGFloat contentHeight = scrollView.contentSize.height;
//                    if (offsetY > contentHeight - scrollView.frame.size.height && arrRantFollowing.count >= MAX_COUNT_RANT)
//                    {
//                        pageFollowing = pageFollowing + 1;
//                        [self getData:NO];
//                    }
//                }
//            }
//                break;
//            case RANT_POPULAR:
//            {
//                if (!isAllData_Popular && !isCallingService)
//                {
//                    
//                    CGFloat offsetY = scrollView.contentOffset.y;
//                    CGFloat contentHeight = scrollView.contentSize.height;
//                    if (offsetY > contentHeight - scrollView.frame.size.height && arrRantPopular.count >= MAX_COUNT_RANT)
//                    {
//                        pagePopular = pagePopular + 1;
//                        [self getData:NO];
//                    }
//                }
//            }
//                break;
//            case RANT_MYTEAMS:
//            {
//                if (!isAllData_Myteams && !isCallingService)
//                {
//                    
//                    CGFloat offsetY = scrollView.contentOffset.y;
//                    CGFloat contentHeight = scrollView.contentSize.height;
//                    if (offsetY > contentHeight - scrollView.frame.size.height && arrRantMyteams.count >= MAX_COUNT_RANT)
//                    {
//                        pageMyteams = pageMyteams + 1;
//                        [self getData:NO];
//                    }
//                }
//                
//            }
//                break;
//                
//            default:
//                break;
//        }
//    }
//    
//    
//}
//
//-(void)showUIbars:(BOOL)animated Compulsary:(BOOL)Compulsary{
//    if(Compulsary || !self.fullScreenScroll.areUIBarsAnimating) [self.fullScreenScroll showUIBarsAnimated:animated];
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    //[self showBARs];
//    [self showUIbars:YES Compulsary:NO];
//    
//}
////- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
////{
////    [self scrollingFinish];
////    
////}
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    //NSLog(@"End dragging");
//    //[self showUIbars:YES Compulsary:YES];
//    if (!decelerate) {
//        //[self showBARs];
//        [self showUIbars:YES Compulsary:NO];
//    }
//}
//
//#pragma mark - Download
//
//-(void)checkRemainSpace_withShowAlert:(BOOL)isShow withHandler:(void(^)(BOOL success))handler
//{
//    long long remainingSpaceInIphone = [[CommonMethods freeDiskSpace] longLongValue];
//    if (remainingSpaceInIphone <= REMAIN_IPHONE_SPACE) {
//        hideHUD;
//        //[btnPlay setSelected:NO];
//        /*--- pause Now---*/
//        [[DownloadManager sharedManager]cancel_RequestForTable];
//        if (isShow) {
//            [self alert_Space_withTitle:@"There is no enough space in your device" withMessage:nil withViewController:self];
//            
//        }
//        handler(NO);
//    }
//    else
//        handler(YES);
//}
//
//-(void)downloadContentWithStreamItem:(SP_RantInfoModel*)model{
//    if (model) {
//        NSFileManager *fm = [NSFileManager defaultManager];
//        NSString *key = [model.VideoURL lastPathComponent];
//        if (key.length==0) {
//             [self downloadContentWithStreamItem:[self getLatestContentToDownload]];
//            model.isVideoDownloaded= YES;
//            return;
//        }
//        if (![fm fileExistsAtPath:[DocumentsDirectoryPath() stringByAppendingPathComponent:key]])
//        {
//            BOOL isNewDownload=YES;
//            if ([DownloadManager sharedManager].downloadRequest) {
//                if ([[DownloadManager sharedManager]curDownloadKey]) {
//                    if ([[[DownloadManager sharedManager]curDownloadKey] isEqualToString:key]) {
//                        isNewDownload=NO;
//                    }
//                    else{
//                        [[DownloadManager sharedManager].downloadRequest cancel];
//                        [DownloadManager sharedManager].downloadRequest=nil;
//                    }
//                }
//            }
//            if (isNewDownload) {
//                [[DownloadManager sharedManager]startAmazonDownloadWithKey:model.VideoURL.lastPathComponent handler:^(BOOL success, float progress, NSError *error) {
//                    if (error==nil) {
//                        if (success) {
//                            model.isVideoDownloaded = YES;
//                            [self downloadContentWithStreamItem:[self getLatestContentToDownload]];
//                        }
//                    }
//                }];
//            }
//        }
//        else{
//            model.isVideoDownloaded =YES;
//                [self downloadContentWithStreamItem:[self getLatestContentToDownload]];
//        }
//    }
//}
//
//-(SP_RantInfoModel*)getLatestContentToDownload{
//    NSArray *arrCur = [self.getLatestArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isVideoDownloaded == NO"]];
//    if (arrCur.count>0) {
//        return arrCur[0];
//    }
//    return nil;
//}
//
//-(void)downloadVideosInBackground
//{
//    [self downloadContentWithStreamItem:[self getLatestContentToDownload]];
//}
//
//-(NSMutableArray*)getLatestArray{
//    @try {
//        switch (self.curViewType) {
//            case RANT_LATEST:
//            {
//                return arrRantLatest;
//            }
//                break;
//            case RANT_FOLLOWING:
//            {
//                return  arrRantFollowing;
//            }
//                break;
//            case RANT_POPULAR:
//            {
//                return  arrRantPopular;
//            }
//                break;
//            case RANT_MYTEAMS:
//            {
//                return  arrRantMyteams;
//            }
//                break;
//                
//            default:
//                return nil;
//                break;
//        }
//        
//    }
//    @catch (NSException *exception) {
//        
//    }
//    @finally {
//        
//    }
//}
//#pragma mark - Alert
//- (void)alert_Space_withTitle:(NSString*)title withMessage:(NSString*)msg withViewController:(UIViewController*)viewCtr
//{
//    if (ios8)
//    {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel  handler:^(UIAlertAction * action)
//                                       {
//                                           [alert dismissViewControllerAnimated:YES completion:nil];
//                                           
//                                       }];
//        
//        [alert addAction:cancelAction];
//        [viewCtr presentViewController:alert animated:YES completion:nil];
//    }
//    else
//    {
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
//        alertView.tag = 102;
//        [alertView show];
//    }
//}
//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(alertView.tag == 102)
//    {
//        switch (buttonIndex) {
//            case 0:
//                break;
//                
//            default:
//                break;
//        }
//    }
//}
//
//#pragma mark - Extra things
//
//-(IBAction)actionsheetPressed:(id)sender{
////    [[SP_SharedActionSheet sharedManager]getBlockUserActionsheetWithVIew:self Completionn:^(BOOL success, BOOL isRemove) {
////        
////    }];
//    
//}
//
//- (IBAction)alert2:(id)sender
//{
//    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Hey! You Gotta Log in to do this" andMessage:@"Take 2 seconds to log in and we'll bring you right back to where we were"];
//    
//    [alertView addDoubleLineTitleAlert];
//    
//    [alertView addButtonWithTitle:@"Log In"
//                             type:SIAlertViewButtonTypeCancel
//                          handler:^(SIAlertView *alertView) {
//                              NSLog(@"Cancel Clicked");
//    
//                          }];
//    
//    
//    
////    alertView.willShowHandler = ^(SIAlertView *alertView) {
////        NSLog(@"%@, willShowHandler2", alertView);
////    };
////    alertView.didShowHandler = ^(SIAlertView *alertView) {
////        NSLog(@"%@, didShowHandler2", alertView);
////    };
////    alertView.willDismissHandler = ^(SIAlertView *alertView) {
////        NSLog(@"%@, willDismissHandler2", alertView);
////    };
////    alertView.didDismissHandler = ^(SIAlertView *alertView) {
////        NSLog(@"%@, didDismissHandler2", alertView);
////    };
//    
//    [alertView show];
//}
//
//id observer1,observer2,observer3,observer4;
//
//- (IBAction)alert3:(id)sender
//{
//    
//    //    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Hey! You Gotta Log in to do this" andMessage:@"Take 2 seconds to log in and we'll bring you right back to where we were"];
//    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle: nil
//                                                     andMessage:@"Thank you. We'll review right away!"];
//    [alertView addSimpleAlert];
//    
//    
//    [alertView addButtonWithTitle:@"Log In"
//                             type:SIAlertViewButtonTypeDestructive
//                          handler:^(SIAlertView *alertView) {
//                              NSLog(@"Cancel Clicked");
//                          }];
//    //    [alertView addButtonWithTitle:@"OK"
//    //                             type:SIAlertViewButtonTypeDefault
//    //                          handler:^(SIAlertView *alertView) {
//    //                              NSLog(@"OK Clicked");
//    //
//    ////                              [self alert3:nil];
//    ////                              [self alert3:nil];
//    //                          }];
//    
//    
//    
//    [alertView show];
//    
//}
//
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
// //cell = (SP_RantCell *)[tblView dequeueReusableCellWithIdentifier:@"SP_RantCell"];
// //cell.lblName.text = cellModel.;
// //    /if(cellModel.TaggedTeams)if(cellModel.TaggedTeams.count>0)cell.tvTeams.text = [cellModel.TaggedTeams valueForKey:@"Name"];
// //    if (indexPath.section%2==0) {
// //        cell.lblText.text=cell.tvTeams.text =  @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting";
// //
// //    }
// //    else{
// //         //cell.lblText.text=cell.tvTeams.text  =  @"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown";
// //    }
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
// 
// switch (self.curViewType) {
// case RANT_LATEST:
// {
// 
// }
// break;
// case RANT_FOLLOWING:
// {
// 
// }
// break;
// case RANT_POPULAR:
// {
// 
// }
// break;
// case RANT_MYTEAMS:
// {
// 
// }
// break;
// 
// default:
// break;
// }
//
//}
// [kApplicationData checkIfUserLoggedIN:self Completion:^(BOOL success, id result, BOOL cancel) {
// 
// }];
// 
// To
//*/
//
//@end

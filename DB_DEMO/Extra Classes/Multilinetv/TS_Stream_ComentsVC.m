//
//  TS_Stream_CoomentsVC.m
//  ThrowStream
//
//  Created by Mac009 on 3/16/15.
//  Copyright (c) 2015 tatva. All rights reserved.
//

#import "TS_Stream_ComentsVC.h"
#import "MDMultilineTextView.h"
#import "UITableFooterView.h"
#import "AppConstant.h"
#import "CCell_Comment.h"
#import "CCell_Searchuser.h"
#import "TS_Stream_Comment.h"
#import "UIImageView+WebCache.h"
#import "TS_FeedInfoModel.h"
#import "TS_SearchUser.h"


@interface TS_Stream_ComentsVC ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,SWTableViewCellDelegate>{
    
    IBOutlet  MDMultilineTextView *multiTextView;
    IBOutlet UITableView *tblView;
    IBOutlet UIView *viewChat;
    __weak IBOutlet UIButton *btnSend;
    /*--- Pangesture is used to drag view when drag table ---*/
    id keyboardShowObserver;
    id keyboardHideObserver;
    UIPanGestureRecognizer *panGest;
    __weak IBOutlet UILabel *lblNoComments;
    UITableFooterView *viewFooter;
    NSMutableArray *arrComments,*arrUsers,*arrTaggedUser,*arrHashTags;
    NSInteger pageNum,pageUsers;
    BOOL isCallingService;
    BOOL isAllDataRetrieved,isAllData_Users;
    BOOL isSearch_Users;
    BOOL isErrorReceived_whilePaging;
    BOOL isUserTbl;
    BOOL isWSCalledOnce;
    __weak IBOutlet UILabel *lblNousers;
    int TABHEIGHT;
    __block NSRange newUser_Range;
}
@property (assign, nonatomic) CGFloat originalKeyboardY;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewContainer;
 @property(nonatomic, strong)UIRefreshControl *refreshControl;
@property(nonatomic, strong)NSString *strSearchuser;
@property(nonatomic,strong)CCell_Comment *prototypeCell;
@end

@implementation TS_Stream_ComentsVC
- (BOOL)prefersStatusBarHidden {
    return NO;
}
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SHOW_STATUS_BAR;
    [self setEdgesForExtendedLayout:UIRectEdgeAll];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName :kFONT_OPENSANS_REGULAR(25)}];
    self.navigationItem.title = @"Comments";
    
    isCallingService = NO;
    isAllDataRetrieved = NO;
    isAllData_Users = NO;
    pageUsers = 1;
    newUser_Range = NSMakeRange(NSNotFound, 0);
    //self.extendedLayoutIncludesOpaqueBars = NO;
//     self.edgesForExtendedLayout = UIRectEdgeAll;
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.extendedLayoutIncludesOpaqueBars = NO;
    
    arrComments = [[NSMutableArray alloc]init];
    arrUsers = [[NSMutableArray alloc]init];
    arrTaggedUser = [[NSMutableArray alloc]init];
    arrHashTags = [[NSMutableArray alloc]init];
   
    /*--- add top line to view like separator ---*/
    CALayer* layer = [viewChat layer];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = RGBCOLOR(164.0, 164.0, 167.0).CGColor;
    bottomBorder.borderWidth = 0.5;
    bottomBorder.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0.5);
    [layer addSublayer:bottomBorder];
    
    /*--- default enable = NO ---*/
    btnSend.enabled = NO;
    
    /*--- add pangesture to table ---*/
    panGest = tblView.panGestureRecognizer;
    [panGest addTarget:self action:@selector(handlePanGesture:)];
    
    /*--- get table footer view ---*/
    viewFooter = [[[NSBundle mainBundle]loadNibNamed:@"UITableFooterView" owner:self options:nil] objectAtIndex:0];;
    viewFooter.indicator.color = [UIColor blackColor];
    viewFooter.backgroundColor = [UIColor whiteColor];
    
    /*--- Add code to setup refresh control ---*/
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlRefresh) forControlEvents:UIControlEventValueChanged];
    tblView.alpha = 0.0;
    //[tblView insertSubview:self.refreshControl atIndex:0 ];

    tblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationController.tabBarController.tabBar.hidden = NO;
    
    if (self.tabBarController) {
        TABHEIGHT = 50;
    }
    else{
        TABHEIGHT = 0;
    }
    [self.view bringSubviewToFront:viewChat];
    
    [tblView registerNib:[UINib nibWithNibName:@"CCell_Comment" bundle:nil] forCellReuseIdentifier:@"CCell_Comment"];
    [tblView registerNib:[UINib nibWithNibName:@"CCell_Searchuser" bundle:nil] forCellReuseIdentifier:@"CCell_Searchuser"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[tblView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self refreshControlRefresh];
    });

    multiTextView.keyboardType = UIKeyboardTypeTwitter;
    multiTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    multiTextView.spellCheckingType = UITextSpellCheckingTypeNo;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
//    [self setEdgesForExtendedLayout:UIRectEdgeAll];
//    self.automaticallyAdjustsScrollViewInsets = YES;
//    self.extendedLayoutIncludesOpaqueBars = YES;
    /*--- set notification for keyboard open/close ---*/
    [self keyboardHandling];
//    tblView.delegate = self;
//    tblView.dataSource = self;
    self.navigationItem.leftBarButtonItem = [CommonMethods backBarButtton_Dismiss:self withSelector:@selector(dismissView)];
    if(isWSCalledOnce)[self reloadCommentsTbl:NO];
    SHOW_STATUS_BAR;
}
-(void)dismissView
{
    [multiTextView resignFirstResponder];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    //[self dismissModalViewControllerAnimated:NO ];
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /*--- remove notification ---*/
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:keyboardShowObserver];
    [center removeObserver:keyboardHideObserver];
    
    keyboardShowObserver = nil;
    keyboardHideObserver = nil;
//    tblView.delegate = nil;
//    tblView.dataSource = nil;
}

-(void)viewDidLayoutSubviews{
    [viewChat layoutIfNeeded];
    
}

-(void)reloadCommentsTbl:(BOOL)shouldBottom{
    isUserTbl = NO;
    [tblView reloadData];
    if(shouldBottom)[self scrolltoBottomTable];
    lblNoComments.hidden = arrComments.count>0 ? YES : NO;
    tblView.hidden= !lblNoComments.hidden;
}

#pragma mark GetData

-(void)refreshControlRefresh
{
    pageNum = 1;
    isAllDataRetrieved = NO;
    isCallingService = YES;
    [self.refreshControl beginRefreshing];
    [self getStreamDetail];
}
-(void)getStreamDetail
{
    isCallingService = YES;
    
    if (pageNum != 1) {
        [viewFooter.indicator startAnimating];
        //tblView.tableHeaderView = viewFooter;
    }
    else showHUD;
    [kAFAPIClient getStreamWithID:_strStreamID
                      withPageNum:pageNum
                       Completion:^(BOOL success, id result, NSError *error)
     {
         if (success)
         {
             isWSCalledOnce = YES;
             tblView.alpha = 1.0;

             [viewFooter.indicator stopAnimating];
             [UIView beginAnimations:nil context:NULL];
             [tblView setTableHeaderView:nil];
             [UIView commitAnimations];
             hideHUD;
             TS_Stream_Comment *last_comment;
             NSLog(@"%@",result);
             if (pageNum==1) {
                 [arrComments removeAllObjects];
             }
             else{
                 if (arrComments.count>0) {
                     last_comment = arrComments[0];
                 }
             }
             NSDictionary *dictUserDetails = (NSDictionary *)result;
             if ([dictUserDetails isKindOfClass:[NSDictionary class]])
             {
                 isErrorReceived_whilePaging = NO;
                NSArray *arrT = [[result objectForKey:@"Stream"]objectForKey:@"Comments"];
                 if ([arrT isKindOfClass:[NSArray class]])
                 {
                     
                     if (arrT.count > 0) {
                         
                         [arrT enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                             TS_Stream_Comment *model =[[TS_Stream_Comment alloc]initWithDictionary:obj];
                             [arrComments addObject:model];
                         }];
                         isCallingService = NO;
                         [self.refreshControl endRefreshing];
                         NSSortDescriptor *dateDescriptor = [NSSortDescriptor
                                                             sortDescriptorWithKey:@"Date"
                                                             ascending:YES];
                         NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
                         NSArray *sortedEventArray = [arrComments
                                                      sortedArrayUsingDescriptors:sortDescriptors];
                         arrComments = [NSMutableArray arrayWithArray:sortedEventArray];
                         
                         [tblView reloadData];
                         if (pageNum==1) {
                             [self scrolltoBottomTable];
                         }
                         else{
                             if (last_comment) {

                                 NSUInteger indexComment = [arrComments indexOfObject:last_comment];
                                 if (indexComment<arrComments.count) {
                                     
                                     [tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexComment inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                 }
                             }
                         }
                     }
                     else
                     {
                         [self.refreshControl endRefreshing];
                         
                         isCallingService = NO;
                         isAllDataRetrieved = YES;
                         [tblView reloadData];
                     }
                     
                 }
                 else
                 {
                     isErrorReceived_whilePaging = YES;
                     isCallingService = NO;
                     [self.refreshControl endRefreshing];
                     [CommonMethods displayAlertwithTitle:@"Fail Please try again" withMessage:nil withViewController:self];
                 }
             }
             lblNoComments.hidden = arrComments.count>0 ? YES : NO;
             tblView.hidden= !lblNoComments.hidden;
         }
         else
         {
             NSLog(@"%@",error);
             [viewFooter.indicator stopAnimating];
             tblView.tableHeaderView  = nil;
             
             isErrorReceived_whilePaging = YES;
             [self.refreshControl endRefreshing];
             isCallingService = NO;
         }
     }];
}

-(void)getusersList:(BOOL)isShowHud WithString:(NSString*)strUsername{
    if (pageUsers != 1) {
        [viewFooter.indicator startAnimating];
        tblView.tableFooterView = viewFooter;
    }
//    if (isShowHud) {
//        showHUD_with_Title(@"Getting Users List");
//    }//SearchForFollowingByName?name={name}&page={page}
    isSearch_Users = NO;
    
    [kAFAPIClient cancelOperationsWithURL:@"/BL088.Web/api/Stream/SearchForFollowingByName"];
    
    [kAFAPIClient cancelOperationsWithURL:[NSString stringWithFormat:@"%@name=%@&page=%ld",Web_GET_SEARCH_FOLLOWERS_LIST,[strUsername stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],(long)pageUsers]];
    NSString* postBody = [NSString stringWithFormat:@"%@name=%@&page=%ld",Web_GET_SEARCH_FOLLOWERS_LIST,[strUsername stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],(long)pageUsers];
    [kAFAPIClient GET:postBody parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        hideHUD
        tblView.alpha = 1.0;
        [viewFooter.indicator stopAnimating];
        tblView.tableFooterView = [UIView new];
        if (pageUsers == 1) {
            [arrUsers removeAllObjects];
        }
        if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            
            if ([[responseObject objectForKey:@"Users"] isKindOfClass:[NSArray class]])
            {
                NSArray *arrAll = [responseObject objectForKey:@"Users"];
                [arrAll enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    TS_SearchUser *model  = [[TS_SearchUser alloc]initwithDictionary:obj];
                    [arrUsers addObject:model];
                }];
                if (arrAll.count==0) {
                    isAllData_Users = YES;
                }
            }
        }
        
        [self.refreshControl endRefreshing];
        isCallingService = NO;
        if (arrUsers.count>0) {
            isUserTbl = YES;
            lblNoComments.hidden =  YES;
            tblView.hidden= NO;
            [tblView reloadData];
        }
        else{
            [self reloadCommentsTbl:YES];
        }
        
        //lblNousers.text = NO_USERS;
//        [self.view bringSubviewToFront:lblNoStreams];
//        [lblNoStreams layoutIfNeeded];
//        lblNoStreams.hidden = arrPeople.count>0 ? YES : NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        hideHUD
        [viewFooter.indicator stopAnimating];
        tblView.tableFooterView = [UIView new];
        //[CommonMethods removeFooterView:tblView];
        [self.refreshControl endRefreshing];
        isCallingService = NO;
        tblView.alpha = 1.0;
        [tblView reloadData];
        [CommonMethods handleErrorOperation:operation withError:error];
    }];
}


#pragma mark -
#pragma mark - MultilineText + Hide Text ON Drag



- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    if (!viewChat)
    {
        return;
    }
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height-TABHEIGHT;//Tabbar issue
    
    UIWindow *panWindow = [[UIApplication sharedApplication] keyWindow];
    CGPoint location = [pan locationInView:panWindow];
    CGPoint velocity = [pan velocityInView:panWindow];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            
            self.originalKeyboardY = screenHeight - self.bottomViewContainer.constant;
            break;
        case UIGestureRecognizerStateEnded:
            if(velocity.y > 0 && viewChat.frame.origin.y > self.originalKeyboardY) {
                
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self keyboardWillBeDismissed];
                                 }
                                 completion:^(BOOL finished) {
                                     
                                 }];
            }
            else { // gesture ended with no flick or a flick upwards, snap keyboard back to original position
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self keyboardWillSnapBackToPoint:CGPointMake(0.0f, self.originalKeyboardY)];
                                     
                                 }
                                 completion:^(BOOL finished){
                                 }];
            }
            break;
            
            // gesture is currently panning, match keyboard y to touch y
        default:
            
            if(location.y > viewChat.frame.origin.y || viewChat.frame.origin.y != self.originalKeyboardY) {
                
                CGFloat newKeyboardY = self.originalKeyboardY + (location.y - self.originalKeyboardY);
                newKeyboardY = newKeyboardY < self.originalKeyboardY ? self.originalKeyboardY : newKeyboardY;
                newKeyboardY = newKeyboardY > screenHeight ? screenHeight : newKeyboardY;
                
                viewChat.frame = CGRectMake(0.0f,
                                            newKeyboardY,
                                            viewChat.frame.size.width,
                                            viewChat.frame.size.height);
                
                [self keyboardDidScrollToPoint:CGPointMake(0.0f, newKeyboardY)];
            }
            break;
    }
}

- (void)keyboardWillBeDismissed
{
    self.bottomViewContainer.constant = 0.0;
    [viewChat layoutIfNeeded];
}

- (void)keyboardWillSnapBackToPoint:(CGPoint)pt
{
    CGRect inputViewFrame = viewChat.frame;
    CGPoint keyboardOrigin = [self.view convertPoint:pt fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
    //inputViewFrame.size.height = MAX(inputViewFrame.size.height, 44);
    viewChat.frame = inputViewFrame;
}
- (void)keyboardDidScrollToPoint:(CGPoint)pt
{
    CGRect inputViewFrame = viewChat.frame;
    CGPoint keyboardOrigin = [self.view convertPoint:pt fromView:nil];
    inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height;
    viewChat.frame = inputViewFrame;
}
- (void)keyboardHandling
{
    keyboardShowObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note)
                            {
                                NSDictionary *info = [note userInfo];
                                CGSize kbSize = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
                                //self.bottomLayoutConstraint.constant += kbSize.height;
                                
                                NSTimeInterval duration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
                                self.bottomViewContainer.constant = kbSize.height-TABHEIGHT;
                                [UIView animateWithDuration:duration animations:^{
                                    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, kbSize.height-TABHEIGHT, 0);
                                    [tblView setContentInset:edgeInsets];
                                    [tblView setScrollIndicatorInsets:edgeInsets];
                                }];
                                
                                
                                [UIView beginAnimations:nil context:NULL];
                                [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
                                [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
                                [UIView setAnimationBeginsFromCurrentState:YES];
                                
                                [self.view layoutIfNeeded];
                                [tblView layoutIfNeeded];
                                [UIView commitAnimations];
                                
                                [self scrolltoBottomTable];
                                
                            }];
    
    keyboardHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note)
                            {
                               // NSDictionary *info = [note userInfo];
                                //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                                //self.bottomLayoutConstraint.constant -= kbSize.height;
                                
                                NSTimeInterval duration = [[[note userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
                                self.bottomViewContainer.constant = 0;
                                [UIView animateWithDuration:duration animations:^{
                                    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
                                    [tblView setContentInset:edgeInsets];
                                    [tblView setScrollIndicatorInsets:edgeInsets];
                                }];
                                
                                [UIView beginAnimations:nil context:NULL];
                                
                                [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
                                [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
                                [UIView setAnimationBeginsFromCurrentState:YES];
                                
                                [self.view layoutIfNeeded];
                                [tblView layoutIfNeeded];
                                
                                [UIView commitAnimations];
                                
                            }];
}
#pragma mark - Scroll to bottom And Delegates

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (isUserTbl) {
        if (!isAllData_Users)
        {
            if (!isCallingService)
            {
                CGFloat offsetY = scrollView.contentOffset.y;
                CGFloat contentHeight = scrollView.contentSize.height;
                if (offsetY > contentHeight - scrollView.frame.size.height && arrUsers.count >= MAX_COUNT)
                {
                    pageUsers = pageUsers + 1;
                   
                    [self getusersList:YES WithString:self.strSearchuser];
                    
                }
            }
        }
    }
    else{
    if (!isErrorReceived_whilePaging)
    {
        if (!isAllDataRetrieved)
        {
            if (!isCallingService)
            {
                CGFloat offsetY = scrollView.contentOffset.y;
                //CGFloat contentHeight = scrollView.contentSize.height;
                //NSLog(@"%f %f",contentHeight - scrollView.frame.size.height,offsetY);
                if (offsetY < 0 && arrComments.count >= MAX_COUNT)
                {
                    pageNum = pageNum + 1;
                    [self getStreamDetail];
                }
            }
        }
    }
    }
}


-(void)scrolltoBottomTable
{
    @try
    {
        if (arrComments.count > 0) {
            if([tblView numberOfRowsInSection:0]>=arrComments.count-1)
            [tblView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:arrComments.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
}
#pragma mark - Text View Delegate

-(void)textViewDidBeginEditing:(UITextView *)textView{
    [self scrolltoBottomTable];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0)
    {
        btnSend.enabled = NO;
    }
    else
    {
        btnSend.enabled = YES;
    }
    
    // Tell layout system that size changed
    if (textView.contentSize.height < multiTextView.maxHeight || textView.text.length == 0)
    {
        [textView invalidateIntrinsicContentSize];
    }
    [textView scrollRectToVisible:CGRectMake(0.0, textView.contentSize.height - 1.0f, 1.0, 1.0) animated:NO];
    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *comBinedtext;
    NSUInteger insertionLocation ;
    if([text isEqualToString:@""] && textView.text.length>0){
     comBinedtext = [textView.text substringToIndex:textView.text.length-1];
        insertionLocation = textView.selectedRange.location-1;
    }
    else{
    comBinedtext = [textView.text stringByAppendingString:text];
        insertionLocation = textView.selectedRange.location;
    }
    
    if (comBinedtext.length==0) {
        [arrHashTags removeAllObjects];
        [arrTaggedUser removeAllObjects];
    }
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\b[@#\\w]+\\b" options:NSRegularExpressionUseUnicodeWordBoundaries error:NULL];
    __block NSString *word = nil;
    __block NSRange newRange = NSMakeRange(NSNotFound, 0);
    [regex enumerateMatchesInString:comBinedtext options:0 range:NSMakeRange(0, comBinedtext.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        if (result.range.location <= insertionLocation && result.range.location+result.range.length >= insertionLocation) {
            word = [comBinedtext substringWithRange:result.range];
            newRange = result.range;
            newUser_Range = result.range;
            *stop = YES;
        }
    }];
    
    // if word isn't degenerate
    if (word.length >= 1 && range.location != NSNotFound) {
        NSString *first = [word substringToIndex:1];
        NSString *rest = [word substringFromIndex:1];
        if ([first isEqualToString:@"@"] && word.length >= 2) {
            if (rest.length>0) {
                if ([text isEqualToString:@"@"]){
                    return NO;
                }
                [self callAutocompleteAPI:rest];
                textView.autocorrectionType = UITextAutocorrectionTypeNo;
            }
            //NSLog(@"%@ %@",word,rest);
        }
        else if ([first isEqualToString:@"#"]){
            if (rest.length>0) {
                if ([text isEqualToString:@"#"]){
                    return NO;
                }
                textView.autocorrectionType = UITextAutocorrectionTypeNo;
            }
             //NSLog(@"%@ %@",word,rest);
        }
        else  {
            if(isUserTbl){
                [kAFAPIClient cancelOperationsWithURL:@"/BL088.Web/api/Stream/SearchForFollowingByName"];
                [self reloadCommentsTbl:YES];
                //textView.autocorrectionType = UITextAutocorrectionTypeDefault;
            }
        }
    } else  {
        if(isUserTbl){
            [self reloadCommentsTbl:YES];
        //textView.autocorrectionType = UITextAutocorrectionTypeDefault;
        }
    }

    return YES;
}

-(void)callAutocompleteAPI:(NSString*)word{
    NSString *strCall= [word stringByReplacingOccurrencesOfString:@"@" withString:@""];
    pageUsers = 1;
    isCallingService = YES;
    isAllData_Users = NO;
    self.strSearchuser = [NSString stringWithString:strCall];
    [self getusersList:NO WithString:strCall];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
//    NSUInteger index = textView.tag;
//    if (index<arrComments.count) {
//        TS_FeedInfoModel *model = arrNotifications[index];
//        [self markNotifRead:model];
//    }
    
    if ([[URL scheme] isEqualToString:VALUE_STREAM]) {
        NSString *username = [URL host];
        NSLog(@"%@",username);
        [CommonMethods naviGateStreamDetail:username Viewcontroller:self];
        return NO;
    }
    else if ([[URL scheme] isEqualToString:VALUE_USERNAME]) {
        NSString *username = [URL host];
        NSLog(@"%@",username);
        [CommonMethods naviGateOtherProfileview:username Viewcontroller:self];
        return NO;
    }
    else if ([[URL scheme] isEqualToString:VALUE_HASH]) {
        NSString *hashValue = [URL host];
        NSLog(@"%@",hashValue);
        [CommonMethods naviGateHashTagview:hashValue Viewcontroller:self];
        return NO;
    }
    
    return YES; // let the system open this URL
}


#pragma mark - Table Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isUserTbl) {
        return arrUsers.count;
    }
    return arrComments.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (isUserTbl) {
        return 60;
    }
    else{
    TS_Stream_Comment *model = arrComments[indexPath.row];

    if (!self.prototypeCell)
    {
        self.prototypeCell = [tblView dequeueReusableCellWithIdentifier:@"CCell_Comment"];
    }
   // [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];

//    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    [self.prototypeCell.lblComment layoutIfNeeded];
       // NSString *strText = model.curAttributedString.length >0 ? model.curAttributedString.string : [model getAttributedString:model].string;
        if (model.cellHeight>0) {
            return model.cellHeight;
        }
        CGFloat widthDays = [model.Days getWidth_withFont:DEF_FONT height:21];
        NSMutableAttributedString *attrStr = model.curAttributedString.length >0 ? model.curAttributedString : [model getAttributedString:model];
        //18.0
    CGFloat heigtS = 11.0 +32.0 +[self heightForTextview:tblView.frame.size.width -MAX(widthDays, 35) -60.0 Attributedtext:attrStr];
        //[CommonMethods findheightForAttributedText:attrStr havingWidth:tblView.frame.size.width -MAX(widthDays, 52) -60.0]
        //[strText getHeight_withFont:DEF_FONT widht:tblView.frame.size.width -MAX(widthDays, 52) -60.0]
        model.cellHeight = MAX(60, heigtS);
    return MAX(60, heigtS);
    }
}

-(CGFloat)heightForTextview:(CGFloat)width Attributedtext:(NSAttributedString*)str{
    @autoreleasepool {
        UITextView *textView = [[UITextView alloc] init];
        textView.textContainerInset = UIEdgeInsetsZero;
        textView.textContainer.lineFragmentPadding = 0;
        textView.textContainerInset = UIEdgeInsetsZero;
        [textView setAttributedText:str];
        CGSize sizeText = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
        return ceilf(sizeText.height);
    }
}

//-(void)getHeightFortext:(NSString*)text FromWidth:(CGFloat)width{
//    CGRect textRect = [text boundingRectWithSize:size
//                                         options:NSStringDrawingUsesLineFragmentOrigin
//                                      attributes:@{NSFontAttributeName:FONT}
//                                         context:nil];
//    
//    CGSize size = textRect.size;
//
//}

- (void)configureCell:(CCell_Comment *)cell
    forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    TS_Stream_Comment *model = arrComments[indexPath.row];
    cell.delegate = self;
    
//    if (model.AddedDate) {
//        model.Days = [[CommonMethods relativeDateStringForDate:model.AddedDate]isNull];
//    }

    cell.rightUtilityButtons = model.isAppuserComment ?[CommonMethods rightButtonsComment]:[CommonMethods rightButtons];
    if (model.ThumbURL.length>0) {
        [cell.imgVUserPic sd_setImageWithURL:[NSURL URLWithString:model.ThumbURL] placeholderImage:PLACE_USER];
    }
    else{
        cell.imgVUserPic.image = PLACE_USER;
    }
    cell.lblName.text = model.Username;
    cell.textComment.attributedText = model.curAttributedString.length>0 ? model.curAttributedString : [model getAttributedString:model];
    cell.lblTimeStamp.text = model.Days;
    cell.textComment.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textComment.linkTextAttributes = [model getExtra_Link_Attributes];
    cell.textComment.tag = indexPath.row;
    //cell.lblTimeStamp.textColor = NOTIF_TIME;
    cell.lblTimeStamp.font = DEF_FONT;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITapGestureRecognizer *gestTitle = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureUsernameRecognized:)];
    gestTitle.numberOfTapsRequired = 1;
    [cell.lblName addGestureRecognizer:gestTitle];
    cell.lblName.tag = indexPath.row;
    cell.lblName.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gestIV = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gestureUsernameRecognized:)];
    gestIV.numberOfTapsRequired = 1;
    [cell.imgVUserPic addGestureRecognizer:gestIV];
    cell.imgVUserPic.tag = indexPath.row;
    cell.imgVUserPic.userInteractionEnabled = YES;
    
    //[cell.textComment textViewDidChange:cell.textComment];
}


-(void)gestureUsernameRecognized:(UITapGestureRecognizer *)gestR{
    TS_Stream_Comment *user = arrComments[gestR.view.tag];
    [CommonMethods naviGateOtherProfileview:user.UserID.stringValue Viewcontroller:self];
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isUserTbl) {
        TS_SearchUser *model = arrUsers[indexPath.row];
        CCell_Searchuser *cell = (CCell_Searchuser *)[tblView dequeueReusableCellWithIdentifier:@"CCell_Searchuser"];
        cell.lblUserName.text =  model.Username;
        cell.const_width_btn.constant =0 ;
        cell.const_leading_view.constant = 8;
        if (model.ThumbURL.length>0) {
            [cell.ivUserImage sd_setImageWithURL:[NSURL URLWithString:model.ThumbURL] placeholderImage:PLACE_USER];
        }
        else{
            cell.ivUserImage.image = PLACE_USER;
        }
         if ([model.UserID isEqualToString:myUserModelGlobal.UserID]) {
            cell.btnFollowUser.hidden = YES;
        }else cell.btnFollowUser.hidden = NO;
        
        cell.lblUserName.tag = indexPath.row;
        cell.lblUserName.userInteractionEnabled = YES;
        cell.lblName.text = model.Fullname;
        return cell;
    }
    else{
    CCell_Comment *cell = (CCell_Comment *)[tblView dequeueReusableCellWithIdentifier:@"CCell_Comment"];
    cell.const_leading_view.constant = 8;
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isUserTbl) {
        [kAFAPIClient cancelOperationsWithURL:@"/BL088.Web/api/Stream/SearchForFollowingByName"];
        TS_SearchUser *user = arrUsers[indexPath.row];
        multiTextView.text = [multiTextView.text stringByReplacingCharactersInRange:newUser_Range withString:[NSString stringWithFormat:@"@%@ ",user.Username]];
        [arrTaggedUser addObject:user];
        [self reloadCommentsTbl:YES];
    }
}

#pragma mark - SWTableViewDelegate


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
        {
            NSIndexPath *index = [tblView indexPathForCell:cell];
            if(index){
                
                TS_Stream_Comment *model = arrComments[index.row];
                if (model.isAppuserComment) {
                    [kAFAPIClient deleteComment:model.CommentID.stringValue withHandler:^(BOOL success, id result, NSError *error) {
                        if (success) {
                            [arrComments removeObjectAtIndex:index.row];
                            [tblView deleteRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationLeft];
                            [tblView reloadData];
                            [appDel refreshViewsAfterComment];
                        }
                    }];
                }
                else{
                [kAFAPIClient flagCommentWithId:model.CommentID.stringValue withHandler:^(BOOL success, id result, NSError *error) {
                    [cell hideUtilityButtonsAnimated:YES];
                }];
                }
            }
            break;
        }
        default:
            break;
    }
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

#pragma mark - Text View Delegate
//- (void)textViewDidChange:(UITextView *)textView
//{
//    // Tell layout system that size changed
//    if (textView.text.length == 0)
//    {
//        multiTextView.placeholder = @"Add a comment";
//    }
//    else
//    {
//        multiTextView.placeholder = @"";
//        btnSend.enabled = YES;
//        btnSend.alpha = 1.0;
//    }
//    if (textView.contentSize.height < multiTextView.maxHeight || textView.text.length == 0)
//    {
//        [textView invalidateIntrinsicContentSize];
//    }
//    [textView scrollRectToVisible:CGRectMake(0.0, textView.contentSize.height - 1.0f, 1.0, 1.0) animated:NO];
//}

//Stream/AddComment	POST	{"Comment":"hello from user B","StreamID":974}

- (IBAction)btnSendPressed:(UIButton*)sender {
    if (multiTextView.text.length>0) {
        showIndicator
        NSString *strtext = multiTextView.text;
        NSMutableArray *sendMention = [[NSMutableArray alloc]init];
        NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc]init];
        
        [arrTaggedUser enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            TS_SearchUser *user = (TS_SearchUser*)obj;
            if ([strtext rangeOfString:[NSString stringWithFormat:@"@%@",user.Username]].location == NSNotFound) {
                [indexes addIndex:idx];
            }
        }];
        
        [arrTaggedUser removeObjectsAtIndexes:indexes];
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:NSRegularExpressionUseUnicodeWordBoundaries error:NULL];
        [regex enumerateMatchesInString:strtext options:0 range:NSMakeRange(0, strtext.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
            NSString  *word = [strtext substringWithRange:result.range];
            if (word.length>0) {
                [arrHashTags addObject:word];
            }
        }];
        
        
        //        getUserIdFromUsername
        
        //        {
        //            "StreamID": null,
        //            "UserID": 1670,
        //            "Hashtag": null,
        //            "DisplayText": "@omgbobbyg"
        //        },
        [arrHashTags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *strHash = [NSString stringWithFormat:@"%@",obj];
            NSDictionary *dict = @{@"StreamID":@"",@"Hashtag":strHash,@"UserID":@"",@"DisplayText":strHash};
            [sendMention addObject:dict];
        }];
        
        [arrTaggedUser enumerateObjectsUsingBlock:^(TS_SearchUser *obj, NSUInteger idx, BOOL *stop) {
            NSString *strName = [NSString stringWithFormat:@"@%@",obj.Username];
            NSDictionary *dict = @{@"StreamID":@"",@"Hashtag": @"",@"UserID":obj.UserID,@"DisplayText":allTrim(strName)};
            [sendMention addObject:dict];
        }];
        
        //        NSMutableArray *arrAllNames = [[NSMutableArray alloc]init];
        //        NSRegularExpression *regex1 = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:NSRegularExpressionUseUnicodeWordBoundaries error:NULL];
        //        [regex1 enumerateMatchesInString:strtext options:0 range:NSMakeRange(0, strtext.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        //            NSString  *word = [strtext substringWithRange:result.range];
        //            if (word.length>0) {
        //                [arrAllNames addObject:word];
        //            }
        //        }];
        
        //        NSArray *arrUsersTagged = [sendMention valueForKey:@"DisplayText"];
        //        [arrAllNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //            if (![arrUsersTagged containsObject:obj]) {
        //                NSLog(@"Not tagged:%@",obj);
        //                [kAFAPIClient getUserIdFromUsername:obj Completion:^(BOOL success, id result, NSError *error) {
        //                    if (success && [result isKindOfClass:[NSDictionary class]]) {
        //                        [sendMention addObject:result];
        //                    }
        //                }];
        //            }
        //        }];
        
        
        
        multiTextView.text = @"";
        [self textViewDidChange:multiTextView];
        //[multiTextView resignFirstResponder];
        [multiTextView layoutIfNeeded];
        [viewChat layoutIfNeeded];
        [arrTaggedUser removeAllObjects];
        [arrHashTags removeAllObjects];
        
        
        
        //        [arrComments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //            TS_Stream_Comment *comment = (TS_Stream_Comment*)obj;
        //            NSLog(@"%@ %@",comment.Comment,comment.AddedDate);
        //            if (comment.AddedDate) {
        //                comment.Days = [[CommonMethods relativeDateStringForDate:comment.AddedDate]isNull];
        //            }
        //
        //        }];
        
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = NO;
        [kAFAPIClient POST:Web_POST_STREAM_COMMENT parameters:@{@"Comment":strtext,@"StreamID":self.strStreamID,@"Mentions":sendMention} success:^(AFHTTPRequestOperation *operation, id responseObject) {
            hideIndicator
            
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                TS_Stream_Comment *newComment = [[TS_Stream_Comment alloc]initWithNewCommentDictionary:responseObject];
                [arrComments addObject:newComment];
                __block  TS_Stream_ComentsVC *weakSelf = self;
                [self setTimestampsDataWithDate:[NSDate date] withHandler:^{
                    [weakSelf reloadCommentsTbl:YES];
                    sender.enabled = YES;
                }];
                [appDel refreshViewsAfterComment];
                lblNoComments.hidden = arrComments.count>0 ? YES : NO;
                tblView.hidden= !lblNoComments.hidden;
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            hideIndicator
            sender.enabled = YES;
            [CommonMethods handleErrorOperation:operation withError:error];
            multiTextView.text = strtext;
        }];
        //  });
        
    }
    
}

-(void)setTimestampsDataWithDate:(NSDate*)curDate withHandler:(void(^)())compilation{
    for (int i=0; i<arrComments.count; i++) {
        TS_Stream_Comment *comment = arrComments[i];
        if (comment.AddedDate) {
            comment.Days = [[CommonMethods relativeDateStringForDate:comment.AddedDate FromTime:[NSDate date]]isNull];
            NSLog(@"i==%d From Time:%@ To time:%@  %@ %@",i,comment.AddedDate,[NSDate date],comment.Comment,comment.Days);
        }
        if (i==arrComments.count-1) {
            compilation();
        }
    }

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

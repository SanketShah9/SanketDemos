//
//  SP_TableView.h
//  Sploops
//
//  Created by Mac009 on 8/28/15.
//  Copyright (c) 2015 Tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableFooterView.h"
@interface SP_TableView : UITableView
@property(nonatomic,strong)UITableFooterView *viewFooter;
@property(nonatomic, strong)UIRefreshControl *refreshControl;
-(void)removeFooterView;
@end

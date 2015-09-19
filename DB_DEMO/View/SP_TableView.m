//
//  SP_TableView.m
//  Sploops
//
//  Created by Mac009 on 8/28/15.
//  Copyright (c) 2015 Tatva. All rights reserved.
//

#import "SP_TableView.h"
#import "AppConstant.h"
@implementation SP_TableView
@synthesize viewFooter;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        viewFooter = [CommonMethods getFooterView];
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self insertSubview:self.refreshControl atIndex:0];
        
    }
    return self;
}

-(void)removeFooterView{
    [UIView beginAnimations:nil context:NULL];
    [self setTableFooterView:nil];
    [UIView commitAnimations];
}


@end

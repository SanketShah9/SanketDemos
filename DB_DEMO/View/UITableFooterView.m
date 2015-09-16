//
//  UITableFooterView.m
//  SuperBaby
//
//  Created by MAC107 on 22/01/15.
//  Copyright (c) 2015 tatva. All rights reserved.
//

#import "UITableFooterView.h"

@implementation UITableFooterView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
//        UIView *vSelf = [[[NSBundle mainBundle]loadNibNamed:@"UITableFooterView" owner:self options:nil] objectAtIndex:0];
//        [self addSubview:vSelf];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void) awakeFromNib
{
    //NSLog(@"width of view %f",super.frame.size.width); // Returns 0 as well
}

- (void) setFrame:(CGRect)aFrame
{
    [super setFrame:aFrame]; // Called from initWithCoder by super. Correct frame size.
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

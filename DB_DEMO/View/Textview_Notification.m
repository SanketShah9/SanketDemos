//
//  Textview_Notification.m
//  ThrowStream
//
//  Created by Mac009 on 4/22/15.
//  Copyright (c) 2015 tatva. All rights reserved.
//

#import "Textview_Notification.h"
#import "AppConstant.h"
@implementation Textview_Notification

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
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        self.textContainerInset = UIEdgeInsetsZero;
//        self.contentInset = UIEdgeInsetsMake(-4,-8,0,0);
        self.textAlignment = NSTextAlignmentLeft;
        //[self addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
         self.textAlignment = NSTextAlignmentLeft;
        //[self sizeToFit];
        //self.selectable = NO;
        self.textColor = NOTIF_GREY;
        self.font = kFONT_OPENSANS_REGULAR(15);
        self.scrollEnabled = NO;
        self.editable = NO;
    }
    return self;
}

//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
//    if (action == @selector(paste:) ||
//        action == @selector(cut:) ||
//        action == @selector(copy:) ||
//        action == @selector(select:) ||
//        action == @selector(delete:) ||
//        action == @selector(makeTextWritingDirectionLeftToRight:) ||
//        action == @selector(makeTextWritingDirectionRightToLeft:) ||
//        action == @selector(toggleBoldface:) ||
//        action == @selector(toggleItalics:) ||
//        action == @selector(toggleUnderline:)
//        ) {
//        return NO;
//    }
//    
////    if (action == @selector(_define:))
////    {
//        return NO;
//    //}
//    
//    //return [super canPerformAction:action withSender:sender];
//}

-(void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && gestureRecognizer.delaysTouchesEnded)
    {
        [super addGestureRecognizer:gestureRecognizer];
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height
    - ( textView.contentOffset.y + textView.bounds.size.height
       - textView.contentInset.bottom - textView.contentInset.top );
    if ( overflow > 0 ) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations:^{
            [textView setContentOffset:offset];
        }];
    }
}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    UITextView *tv = object;
//    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
//    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
//    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
//}

@end

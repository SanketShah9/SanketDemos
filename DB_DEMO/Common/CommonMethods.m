//
//  CommonMethods.m
//  MiMedic
//
//  Created by MAC107 on 17/07/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "CommonMethods.h"
#import "AppConstant.h"


#import <AVFoundation/AVFoundation.h>
#import <sys/utsname.h>
#import <EventKit/EventKit.h>

#include <sys/param.h>
#include <sys/mount.h>

#import <mach/mach.h>
#import <mach/mach_host.h>


//#import "T_StreamDetailClass.h"

#define MB (1024*1024)
#define GB (MB*1024)

@implementation CommonMethods
+ (NSString *)memoryFormatter:(long long)diskSpace {
    NSString *formatted;
    double bytes = 1.0 * diskSpace;
    double megabytes = bytes / MB;
//    double gigabytes = bytes / GB;
//    if (gigabytes >= 1.0)
//        formatted = [NSString stringWithFormat:@"%.2f GB", gigabytes];
//    else
    if (megabytes >= 1.0)
        formatted = [NSString stringWithFormat:@"%.2f MB", megabytes];
    else
        formatted = [NSString stringWithFormat:@"%.2f bytes", bytes];
    return formatted;
    
}
+(float) diskSpace {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;
    statfs([[paths lastObject] cString], &tStats);
    float total_space = (float)(tStats.f_bavail * tStats.f_bsize);
    return total_space;
}
#pragma mark - Methods
+ (NSString *)totalDiskSpace {
    long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return [self memoryFormatter:space];
}

+ (NSString *)freeDiskSpace {
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return [self memoryFormatter:freeSpace];
}

+ (NSString *)usedDiskSpace {
    return [self memoryFormatter:[self usedDiskSpaceInBytes]];
}

+ (CGFloat)totalDiskSpaceInBytes {
    long long space = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] longLongValue];
    return space;
}

+ (CGFloat)freeDiskSpaceInBytes {
    long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] longLongValue];
    return freeSpace;
}

+ (CGFloat)usedDiskSpaceInBytes {
    long long usedSpace = [self totalDiskSpaceInBytes] - [self freeDiskSpaceInBytes];
    return usedSpace;
}
+(NSString *)getAppVersionNum
{
    //              NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appVersionNum = [infoDict objectForKey:@"CFBundleShortVersionString"];
    return appVersionNum;

}
+(NSString *)getSystemVersion
{
    //              NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
    return currSysVer;
}
+(NSString *)getDeviceType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSString *deviceString = [NSString stringWithFormat:@"%@ (%@)", [[UIDevice currentDevice] model], code];
    
    return deviceString;
}

#pragma mark - Common Navigations


#pragma mark - Document Directory Path
/*--- Get Document Directory path ---*/
NSString *DocumentsDirectoryPath() {NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);NSString *documentsDirectoryPath = [paths objectAtIndex:0];return documentsDirectoryPath;}

#pragma mark - Do not back up on iCloud

/*--- Do not back up on iCloud ---*/
+ (BOOL)addSkipBackupAttributeToItemAtPath
{
    NSURL *URL = [NSURL fileURLWithPath:DocumentsDirectoryPath()];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                    
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}



+(UIImage *)generatePDFThumbnail:(NSString *)strPath withSize:(CGSize)size
{
    NSURL* pdfFileUrl = [NSURL fileURLWithPath:strPath];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfFileUrl);
    CGPDFPageRef page;
    
    CGRect aRect = CGRectMake(0, 0, size.width, size.height); // thumbnail size
    UIGraphicsBeginImageContext(aRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage* thumbnailImage;
    
    
    //NSUInteger totalNum = CGPDFDocumentGetNumberOfPages(pdf);
    
    for(int i = 0; i < 1; i++ )
    {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0, aRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGContextSetGrayFillColor(context, 1.0, 1.0);
        CGContextFillRect(context, aRect);
        
        
        // Grab the first PDF page
        page = CGPDFDocumentGetPage(pdf, i + 1);
        CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFMediaBox, aRect, 0, true);
        // And apply the transform.
        CGContextConcatCTM(context, pdfTransform);
        
        CGContextDrawPDFPage(context, page);
        
        // Create the new UIImage from the context
        thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
        
        //Use thumbnailImage (e.g. drawing, saving it to a file, etc)
        
        CGContextRestoreGState(context);
        
    }
    UIGraphicsEndImageContext();    
    CGPDFDocumentRelease(pdf);
    
    return thumbnailImage;
}


+(BOOL)isImage:(NSString *)strLastComponent
{
    if ([strLastComponent containsString:@".jpg"] ||
        [strLastComponent containsString:@".jpeg"] ||
        [strLastComponent containsString:@".bmp"] ||
        [strLastComponent containsString:@".gif"] ||
        [strLastComponent containsString:@".png"])
    {
        return YES;
    }
    else
        return NO;
}
+(BOOL)isVideo:(NSString *)strLastComponent
{
    if ([strLastComponent containsString:@".flv"] ||
        [strLastComponent containsString:@".mp4"] ||
        [strLastComponent containsString:@".wmv"])
    {
        return YES;
    }
    else
        return NO;
}
+(BOOL)isPDF:(NSString *)strLastComponent
{
    if ([strLastComponent containsString:@".pdf"])
    {
        return YES;
    }
    else
        return NO;
}

+(void)setAttribText:(UIButton *)btn withText:(NSString *)strText withFontSize:(UIFont *)fonts withColor:(UIColor *)color
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:strText];
    
    NSRange goRange = [[attributedString string] rangeOfString:strText];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:goRange];//TextColor
    [attributedString addAttribute:NSFontAttributeName value:fonts range:goRange];//TextFont
    
    btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    btn.titleLabel.numberOfLines = 0;
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btn setAttributedTitle:attributedString forState:UIControlStateNormal];
    
}


+(void)addEvent_withTitle:(NSString *)strTitle withStartDate:(NSDate *)dateStart withEndData:(NSDate *)dateEnd withHandler:(void(^)(BOOL Success,BOOL granted))compilation
{
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted)
        {
            compilation(NO,NO);
        }
        else
        {
            EKEvent *event = [EKEvent eventWithEventStore:store];
            event.title = strTitle;
            event.startDate = dateStart; //today
            event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  //set 1 hour meeting
            [event setCalendar:[store defaultCalendarForNewEvents]];
            NSError *err = nil;
            [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
            //NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
            compilation(YES,YES);
        }
    }];
}
/*----- no internet alertview -----*/
+ (void)showNoInternetAlertViewwithViewCtr:(UIViewController*)viewCtr
{
    if (ios8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Oops!" message:LSSTRING(@"str_No_Internet") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                        {[alert dismissViewControllerAnimated:YES completion:nil];
                                        }];
        [alert addAction:defaultAction];
        [viewCtr presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:LSSTRING(@"str_No_Internet") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}
/*----- alertview for iOS 7 & 8 -----*/
+ (void)displayAlertwithTitle:(NSString*)title withMessage:(NSString*)msg withViewController:(UIViewController*)viewCtr
{
    if (ios8)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                                        {[alert dismissViewControllerAnimated:YES completion:nil];
                                        }];
        [alert addAction:defaultAction];
        [viewCtr presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];[alertView show];
    }
}

+ (UIBarButtonItem*)leftMenuButton:(UIViewController *)viewC withSelector:(SEL)mySelector
{
    UIImage *buttonImage = [UIImage imageNamed:@"menu-icon"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:viewC action:mySelector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return retVal;
}

/*----- back button with custom image -----*/
+ (UIBarButtonItem*)backBarButtton
{
    UIImage *buttonImage = [UIImage imageNamed:@"back-arrow"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    //[button addTarget:APPDELEGATE.navC action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];

    return retVal;
}

+ (UIBarButtonItem*)backBarButtton:(UIViewController*)VC
{
    UIImage *buttonImage = [UIImage imageNamed:@"back-arrow"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:VC.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];
    if ([VC.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        VC.navigationController.interactivePopGestureRecognizer.enabled = YES;
        VC.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    return retVal;
}


+ (UIBarButtonItem*)backBarButtton_NewNavigation:(UIViewController *)viewC withSelector:(SEL)mySelector
{
    UIImage *buttonImage = [UIImage imageNamed:@"back-arrow"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:viewC action:mySelector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return retVal;
}

+ (UIBarButtonItem*)backBarButtton_Dismiss:(UIViewController *)viewC withSelector:(SEL)mySelector
{
    UIImage *buttonImage = [UIImage imageNamed:@"back-arrow"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:buttonImage forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height);
    [button addTarget:viewC action:mySelector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return retVal;
}
+ (UIBarButtonItem*)createRightButton_withVC:(UIViewController *)vc withText:(NSString *)strText withSelector:(SEL)mySelector
{
//    UIImage *buttonImage = [UIImage imageNamed:@"back_icon"];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [button setTitle:strText forState:UIControlStateNormal];
//    button.titleLabel.tintColor = [UIColor colorWithRed:72/255.0 green:190/255.0 blue:128/255.0 alpha:1.0];
//    button.frame = CGRectMake(0, 0, 64, 64);
//    [button addTarget:vc action:mySelector forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *retVal = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIBarButtonItem *retVal = [[UIBarButtonItem alloc]initWithTitle:strText style:UIBarButtonItemStylePlain target:vc action:mySelector];
    //retVal.tintColor = [UIColor colorWithRed:72/255.0 green:190/255.0 blue:128/255.0 alpha:1.0];

    return retVal;
}


+(NSString *)getMonthName:(NSString *)strMonthNumber
{
    if ([strMonthNumber isEqualToString:@""])
    {
        return @"";
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init] ;
    NSString *monthName = [[df monthSymbols] objectAtIndex:([strMonthNumber integerValue]-1)];
    return monthName;
}
+(NSInteger)getMonthNumber:(NSString *)strMonthName
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"];
    NSDate *aDate = [formatter dateFromString:strMonthName];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:aDate];
    //NSLog(@"Month: %li", (long)[components month]); /* => 7 */
    return [components month];
}




+(NSArray *)getTagArray:(NSString *)strFinal
{
    NSArray *arrTemp = [strFinal componentsSeparatedByString:@","];
    /*--- Remove Blank String ---*/
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id str, NSDictionary *unused) {
        return ![[str isNull] isEqualToString:@""];
    }];
    
    return [arrTemp filteredArrayUsingPredicate:pred];
}

+ (BOOL)NSStringIsValidEmail:(NSString *)checkString {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}



+ (BOOL) isValidateUrl: (NSString *)url {
    NSString *urlRegEx =
    @"((http|https)://)*((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:url];
}



+(void)scrollToCaretInTextView:(UITextView *)textView animated:(BOOL)animated
{
    CGRect rect = [textView caretRectForPosition:textView.selectedTextRange.end];
    rect.size.height += textView.textContainerInset.bottom;
    [textView scrollRectToVisible:rect animated:animated];
}
+(void)addBottomLine_to_Label:(UILabel *)lbl
{
    CALayer* layer = [lbl layer];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = RGBCOLOR_GREY.CGColor;
    bottomBorder.borderWidth = 0.5;
    bottomBorder.frame = CGRectMake(0, layer.frame.size.height-0.5, lbl.frame.size.width, 1);
    [layer addSublayer:bottomBorder];
}

+(void)addTOPLine_to_View:(UIView *)view
{
    CALayer* layer = [view layer];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = RGBCOLOR_GREY.CGColor;
    bottomBorder.borderWidth = 0.5;
    bottomBorder.frame = CGRectMake(0, 0, view.frame.size.width, 0.5);
    [layer addSublayer:bottomBorder];
}
+(void)addBottomLine_to_View:(UIView *)view
{
    CALayer* layer = [view layer];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.borderColor = RGBCOLOR_GREY.CGColor;
    bottomBorder.borderWidth = 0.5;
    bottomBorder.frame = CGRectMake(0, layer.frame.size.height-0.5, view.frame.size.width, 1);
    [layer addSublayer:bottomBorder];
}

+ (NSString*)makeThumbFromOriginalImageString:(NSString*)strPhoto
{
    NSString *retVal = @"";
    if (strPhoto.length > 0)
    {
        NSString *strFileExtension = [strPhoto pathExtension];
        strPhoto = [strPhoto stringByDeletingPathExtension];
        strPhoto = [strPhoto stringByAppendingString:@"_thumb."];
        retVal = [strPhoto stringByAppendingString:strFileExtension];
    }
    else
    {
        retVal = strPhoto;
    }
    
    return retVal;
}

+(NSString*) bv_jsonStringWithPrettyPrint:(BOOL) prettyPrint UsingDictionary:(NSDictionary*)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+(void)setBlackNavBarTitle:(UIViewController*)VC{
    [VC.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:kFONT_REGULAR(23.0),
                                                                    NSForegroundColorAttributeName:[UIColor blackColor]}];
}

+ (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
    //CGFloat result = font.pointSize+4;
    CGSize size;
    if (text) {
        //iOS 7
        CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{ NSFontAttributeName:font }
                                          context:nil];
        size = CGSizeMake(frame.size.width, frame.size.height + 1);
        //result = MAX(size.height, result); //At least one row
    }
    return size;
}

+(CGFloat)findheightForAttributedText:(NSMutableAttributedString*)attributedText havingWidth:(CGFloat)widthValue{
    CGRect paragraphRect =
    [attributedText boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX)
                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                 context:nil];
    return paragraphRect.size.height;
}




+(void)removeFooterView:(UITableView*)table{
    [UIView beginAnimations:nil context:NULL];
    [table setTableFooterView:nil];
    [UIView commitAnimations];
}

+(void)addSubViewWithSameConstraintContainerView:(UIView*)containerView Newview:(UIView*)newSubview{

    newSubview.translatesAutoresizingMaskIntoConstraints = NO;
    //newSubview.backgroundColor = [UIColor lightGrayColor];
    [containerView addSubview:newSubview];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:newSubview
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:newSubview
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:newSubview
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:newSubview
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:containerView
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // the frame is still `CGRectZero` at this point
    
    NSLog(@"newSubview.frame before = %@", NSStringFromCGRect(newSubview.frame));
    
    // if not doing this in `viewDidLoad` (e.g. you're doing this in
    // `viewDidAppear` or later), you can force `layoutIfNeeded` if you want
    // to look at `frame` values. Generally you don't need to do this unless
    // manually inspecting `frame` values or when changing constraints in a
    // `animations` block of `animateWithDuration`.
    
    [containerView layoutIfNeeded];
}

+(UIImage *)compressImage:(UIImage *)image withRatio:(CGFloat)ratio {
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = actualHeight*ratio;
    float maxWidth =actualWidth*ratio;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:imageData];
}

+ (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


//-(BOOL)silenced {
//#if TARGET_IPHONE_SIMULATOR
//    // return NO in simulator. Code causes crashes for some reason.
//    return NO;
//#endif
//    
//    CFStringRef state;
//    UInt32 propertySize = sizeof(CFStringRef);
//    AudioSessionInitialize(NULL, NULL, NULL, NULL);
//    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
//    if(CFStringGetLength(state) > 0)
//        return NO;
//    else
//        return YES;
//    
//}

#pragma mark - Date handling

#define NA @"NA"

//+(NSString *)relativeDateStringForDate:(NSDate *)date FromTime:(NSDate*)curTime
//{
//    
//    if (date==nil) {
//        return NA;
//    }
//    
//    NSCalendarUnit units =    NSYearCalendarUnit ;
//    
//    // if `date` is before "now" (i.e. in the past) then the components will be positive
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
//                                                                   fromDate:date
//                                                                     toDate:curTime
//                                                                    options:0];
//    //    NSDate *todayDate = [NSDate date];
//    //    double ti = [date timeIntervalSinceDate:todayDate];
//    if (components.year > 0) {
//        return components.year==1?[NSString stringWithFormat:@"%ldw", (long)components.year* 52]:[NSString stringWithFormat:@"%ldw", (long)components.year * 52];
//    } else if (components.month > 0) {
//        return components.month==1?[NSString stringWithFormat:@"%ldw", (long)components.month * 4]:[NSString stringWithFormat:@"%ldw", (long)components.month * 4];
//    } else if (components.weekOfYear > 0) {
//        return components.weekOfYear==1?[NSString stringWithFormat:@"%ldw", (long)components.weekOfYear]:[NSString stringWithFormat:@"%ldw", (long)components.weekOfYear];
//    } else if (components.day > 0) {
//        if (components.day > 1) {
//            return [NSString stringWithFormat:@"%ldd", (long)components.day];
//        } else {
//            return @"1d";
//        }
//        //        int diff = round(ti / 60 / 60 / 24);
//        //        if (diff == 1) {
//        //            return @"Yesterday";
//        //        }else {
//        //            return  [NSString stringWithFormat:@"%d days ago", diff];
//        //        }
//    } else {
//        
//        NSTimeInterval _timeInterval = [date timeIntervalSinceDate:curTime];
//        // float f = (float)_timeInterval;
//        NSInteger ti = (NSInteger)_timeInterval;
//        
//        NSInteger _minutes = (ti / 60) % 60;
//        NSInteger _hours = (ti / 3600);
//        NSInteger _seconds = ti % 60;
//        
//        
//        //        NSInteger _hours = floor(f / 60);
//        //        NSInteger _minutes = (NSInteger)round(f / 60);
//        //NSLog(@"Main date:%@",date);
//        //NSLog(@"Cur date:%@",[NSDate date]);
//        // NSLog(@"%02ld:%02ld:%02ld:", (long)_hours, (long)_minutes,(long)_seconds);
//        if (ABS((int)_hours)>0) {
//            return ABS((int)_hours)==1 ?[NSString stringWithFormat:@"%dh",ABS((int)_hours),ABS((int)_minutes)]:[NSString stringWithFormat:@"%dh",ABS((int)_hours),ABS((int)_minutes)];
//        }
//        else if(ABS((int)_minutes)>0){
//            return ABS((int)_minutes)==1 ?[NSString stringWithFormat:@"%dm",ABS((int)_minutes)]:[NSString stringWithFormat:@"%dm",ABS((int)_minutes)];
//        }
//        else{
//            NSLog(@"%@:%d",date,ABS((int)_seconds));
//            if( components.second<0 ||ABS((int)_seconds)==0 || ABS((int)_seconds)==1){
//                return [NSString stringWithFormat:@"1s"];
//            }
//            return ABS((int)_seconds)==0 ?[NSString stringWithFormat:@"1s"]:[NSString stringWithFormat:@"%ds",ABS((int)_seconds)];
//        }
//        return @"";
//        
//        
//        
//    }
//}
//
//+(NSString *)relativeDateStringForDate:(NSDate *)date
//{
//    
//    if (date==nil) {
//        return NA;
//    }
//    
//    NSCalendarUnit units = NSDayCalendarUnit | NSWeekOfYearCalendarUnit |
//    NSMonthCalendarUnit | NSYearCalendarUnit | NSSecondCalendarUnit;
//    
//    // if `date` is before "now" (i.e. in the past) then the components will be positive
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:units
//                                                                   fromDate:date
//                                                                     toDate:[NSDate date]
//                                                                    options:0];
//    //    NSDate *todayDate = [NSDate date];
//    //    double ti = [date timeIntervalSinceDate:todayDate];
//    if (components.year > 0) {
//        return components.year==1?[NSString stringWithFormat:@"%ldw", (long)components.year* 52]:[NSString stringWithFormat:@"%ldw", (long)components.year * 52];
//    } else if (components.month > 0) {
//        return components.month==1?[NSString stringWithFormat:@"%ldw", (long)components.month * 4]:[NSString stringWithFormat:@"%ldw", (long)components.month * 4];
//    } else if (components.weekOfYear > 0) {
//        return components.weekOfYear==1?[NSString stringWithFormat:@"%ldw", (long)components.weekOfYear]:[NSString stringWithFormat:@"%ldw", (long)components.weekOfYear];
//    } else if (components.day > 0) {
//        if (components.day > 1) {
//            return [NSString stringWithFormat:@"%ldd", (long)components.day];
//        } else {
//            return @"1d";
//        }
//        //        int diff = round(ti / 60 / 60 / 24);
//        //        if (diff == 1) {
//        //            return @"Yesterday";
//        //        }else {
//        //            return  [NSString stringWithFormat:@"%d days ago", diff];
//        //        }
//    } else {
//        
//        NSTimeInterval _timeInterval = [date timeIntervalSinceNow];
//        // float f = (float)_timeInterval;
//        NSInteger ti = (NSInteger)_timeInterval;
//        
//        NSInteger _minutes = (ti / 60) % 60;
//        NSInteger _hours = (ti / 3600);
//        NSInteger _seconds = ti % 60;
//        
//        
//        //        NSInteger _hours = floor(f / 60);
//        //        NSInteger _minutes = (NSInteger)round(f / 60);
//        //NSLog(@"Main date:%@",date);
//        //NSLog(@"Cur date:%@",[NSDate date]);
//        // NSLog(@"%02ld:%02ld:%02ld:", (long)_hours, (long)_minutes,(long)_seconds);
//        if (ABS((int)_hours)>0) {
//            return ABS((int)_hours)==1 ?[NSString stringWithFormat:@"%dh",ABS((int)_hours),ABS((int)_minutes)]:[NSString stringWithFormat:@"%dh",ABS((int)_hours),ABS((int)_minutes)];
//        }
//        else if(ABS((int)_minutes)>0){
//            return ABS((int)_minutes)==1 ?[NSString stringWithFormat:@"%dm",ABS((int)_minutes)]:[NSString stringWithFormat:@"%dm",ABS((int)_minutes)];
//        }
//        else{
//            NSLog(@"%@:%d",date,ABS((int)_seconds));
//            if(ABS((int)_seconds)==0 || ABS((int)_seconds)==1){
//                NSLog(@"Calendar:%d",components.second);
//            }
//            return ABS((int)_seconds)==0 ?[NSString stringWithFormat:@"1s"]:[NSString stringWithFormat:@"%ds",ABS((int)_seconds)];
//        }
//        return @"";
//        
//        
//        
//    }
//}



#pragma mark - HandleWsErrors


+(void)showSuccessWithMessage:(NSString*)message{
    showHUD_with_Success(message);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hideHUD;
    });
}


+(void)showErrorWithMessage:(NSString*)message{
    showHUD_with_error(message);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        hideHUD;
    });
}

+ (int)handleFacebookErrorOperation:(AFHTTPRequestOperation *)task withError:(NSError *)error{
    @try {
        id errorBody = [error.userInfo valueForKey:@"body"];
        NSDictionary *dict = errorBody;
        if (dict) {
            int status =  [[dict valueForKey:@"Status"]intValue];
            if (status==101 || status==103 || status==104 || status==105) {
                NSString *str =[dict valueForKey:@"StatusMessage"];
                [CommonMethods showErrorWithMessage:str];
            }
            else if (status==100){
                hideHUD
                SHOW_ALERT(App_Name, @"You have not confirmed with your email address.");
            }
            else if (status==102){
                hideHUD
                SHOW_ALERT(App_Name, @"Please login again as facebook session is expired!");
            }
            else{
                [CommonMethods handleErrorOperation:task withError:error];
            }
            return status;
        }
        else{
            [CommonMethods handleErrorOperation:task withError:error];
            return 0;
        }
    }
    @catch (NSException *exception) {
         NSLog(@"%@",exception.description);
        return 0;
    }
    @finally {
    }
}

+ (void)handleErrorOperation:(AFHTTPRequestOperation *)task withError:(NSError *)error {
    if (![APPDELEGATE checkConnection:nil]) {
        [CommonMethods showErrorWithMessage:@"str_No_Internet"];
        showHUD_with_error(NSLocalizedString(@"str_No_Internet", nil));
        return;
    }
    @try {
        NSRange cancelRange = [[error localizedDescription] rangeOfString:@"cancelled"];
        if (![task isCancelled] && cancelRange.location == NSNotFound) {
            
            //            if(task.response.statusCode==401){
            //                //Authorization failed
            //                [CommonMethods authorizationFailedTransition];
            //                [AFCLIENTSINGLETON.requestSerializer clearAuthorizationHeader];
            //                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //                [defaults removeObjectForKey:LOGINRESPONSE];
            //                return;
            //            }
            
            
            id errorBody = [error.userInfo valueForKey:@"body"];
            NSLog(@"------------++++++++++----------Error Body %@",errorBody);
            if ([errorBody isKindOfClass:[NSArray class]]) {
                errorBody = errorBody[0];
            }
            if (errorBody != nil && [errorBody isKindOfClass:[NSDictionary class]]) {
                //NSString *title = [NSString stringWithFormat:@"%@", [errorBody valueForKey:@"errorCode"]];
                NSString *description = [NSString stringWithFormat:@"%@", [errorBody valueForKey:@"errorMessage"]];
                if ([description isEqualToString:@"(null)"]) {
                    description = errorBody[@"Message"];
                }
                //if ([title isEqualToString:@"(null)"]) {
                //	title = [errorBody valueForKey:@"error"];
                //}
                if ([description isEqualToString:@"(null)"]||description.length==0) {
                    description = errorBody[@"error_description"];
                }
                if (task.response.statusCode != 404) {
                    if (task.response.statusCode==400 || task.response.statusCode==500) {
                        NSDictionary *dict = errorBody;
                        if(dict.count>0){
                            if (![[dict objectForKey:@"Status"]boolValue]) {
                                NSString *str =[dict valueForKey:@"StatusMessage"];
                             if ([dict objectForKey:@"ModelState"]){
                                 NSDictionary *dictModel = [dict objectForKey:@"ModelState"];
                                    NSString *strErrorFinal = @"Unknown Error";
                                    for (NSString *str in [dictModel allKeys])
                                    {
                                        id obj = [dictModel objectForKey:str];
                                        if ([obj isKindOfClass:[NSArray class]])
                                        {
                                            NSArray *arrTemp = obj;
                                            if (arrTemp.count > 0) {
                                                strErrorFinal = arrTemp[0];
                                                break;
                                            }
                                        }
                                        else if([obj isKindOfClass:[NSString class]])
                                        {
                                            strErrorFinal = obj;
                                            break;
                                        }
                                    }
                                    [CommonMethods showErrorWithMessage:strErrorFinal];
                                }
                               else if (str.length>0) {
                                    [CommonMethods showErrorWithMessage:str];
                                }

                                else if (description.length>0){
                                    [CommonMethods showErrorWithMessage:description];
                                }
                                else{
                                    [CommonMethods showErrorWithMessage:@"Unknown Error Occured"];
                                }
                                
                            }
                            else{
                                NSString *str =[dict valueForKey:@"StatusMessage"];
                                if (str!=nil && str.length>0) {
                                    [CommonMethods showErrorWithMessage:str];
                                }
                                else{
                                    [CommonMethods showErrorWithMessage:@"Unknown Error Occured"];
                                }
                            }
                        }
                    }else if(task.response.statusCode==401){
                        //Authorization failed
//                        [APPDELEGATE.navC popToRootViewControllerAnimated:YES];
                        showHUD_with_error(error.localizedDescription);
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            hideHUD;
                        });
                    }
                    else{
                        [CommonMethods showErrorWithMessage:description];
                    }
                    
                } else
                {
                    NSLog(@"-----------------There is 404 or 500 error occured.");
                    [CommonMethods showErrorWithMessage:@"Unknown Error Occured"];
                }
            }
            else {
                //[CommonMethods showErrorWithMessage:@"Unknown Error Occured"];
                [CommonMethods showErrorWithMessage:[error localizedDescription]];
                NSLog(@"-----------------Error %@",error.localizedDescription);
                //Shows if html or not proper error comes
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
        [CommonMethods showErrorWithMessage:@"Unknown Error Occured"];
    }
    @finally {
        
    }
}


#pragma mark - Get Progress
+(void)getVideo_Thumb_With_Time_url:(NSURL *)videoUrl withHandler:(void(^)(UIImage *img,float duration))compilation
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    UIImage *thumb;
    float seconds;
    //int finalroundedDuration;
    @try
    {
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        thumb = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    
    @try
    {
        /*--- Get Time of video ---*/
        CMTime duration = asset.duration;
        seconds = CMTimeGetSeconds(duration);
        //finalroundedDuration = roundf(seconds); ;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
    }
    compilation(thumb,seconds);
}

+(void)generateVideoThumbnail_from_URL_UsingBlock:(NSString *)strVideoURL withHandler:(void(^)(UIImage *imageF))compilation
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:[strVideoURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 2);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
        compilation(one);
    });
    
}
+ (void)setVideoThumbnail:(UIImageView *)imgV withURL:(NSString *)strURL
{
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    BOOL fileExists = [fileMgr fileExistsAtPath:strURL];
    if (fileExists == NO)
    {
        NSLog(@"not exist");
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            __block UIImage *image;
            @autoreleasepool {
                /* obtain the image here */
                
                NSURL *fileUrl = [NSURL fileURLWithPath:strURL];
                
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileUrl options:nil];
                AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                generator.appliesPreferredTrackTransform=TRUE;
                CMTime thumbTime = kCMTimeZero;
                AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
                    if (result != AVAssetImageGeneratorSucceeded)
                    {
                        NSLog(@"couldn't generate thumbnail, error:%@", error);
                        [self setVideoThumbnail:imgV withURL:strURL];
                    }
                    else
                    {
                        image = [UIImage imageWithCGImage:im];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            imgV.image = image;
                        });
                    }
                    
                };
                
                CGSize maxSize = CGSizeMake(imgV.frame.size.width*2, imgV.frame.size.height*2);
                generator.maximumSize = maxSize;
                [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
            }
        });
    }
}
+(void)generateImage:(NSString *)strURL withHandler:(void(^)(UIImage *image))complition
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:[NSURL URLWithString:strURL] options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform=TRUE;
        CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
        
        AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
        {
            if (result != AVAssetImageGeneratorSucceeded) {
                NSLog(@"couldn't generate thumbnail, error:%@", error);
            }
            UIImage *thumbImg=[UIImage imageWithCGImage:im];
            complition(thumbImg);
        };
        
        CGSize maxSize = CGSizeMake(320, 180);
        generator.maximumSize = maxSize;
        [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
    });
}
#pragma mark - Get Profile + Save profile
//+(TS_UserModel *)getMyUser_LoggedIN
//{
//    @try
//    {
//        NSData *myDecodedObject = [UserDefaults objectForKey:USER_INFO];
//        TS_UserModel *myUser = [NSKeyedUnarchiver unarchiveObjectWithData:myDecodedObject];
//        myUser.access_token = [[NSString stringWithFormat:@"%@",[[GSKeychain systemKeychain]secretForKey:USER_TOKEN]]isNull];
//        
//        return myUser;
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%@",exception.description);
//        return nil;
//    }
//    @finally {
//    }
//    return nil;
//}
//+(void)saveMyUser_LoggedIN:(TS_UserModel *)myUser
//{
//    @try
//    {
//        NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:myUser];
//        [UserDefaults setObject:myEncodedObject forKey:USER_INFO];
//        [UserDefaults synchronize];
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%@",exception.description);
//    }
//    @finally {
//    }
//}


@end

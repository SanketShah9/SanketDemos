

#ifndef Demo_AppConstant_h
#define Demo_AppConstant_h
#endif

#import "AppDelegate.h"
#import "DatabaseUtil.h"
#import "FMDatabase.h"
#import "AFAPIClient.h"
#import "WebService.h"
#import "NSObject+Validation.h"

//#import "UIView+Extended.h"
#import "NSString+Validation.h"
#import "NSAttributedString+Validation.h"
//#import "NSMutableAttributedString+Validation.h"



#import "CommonMethods.h"
//#import "NSDate-Utilities.h"
#import "NSDate+Formatting.h"

//#import "UIImage+KTCategory.h"
//#import "UINavigationController+Rotation_IOS6.h"
//#import "DACircularProgressView.h"

#import "SVProgressHUD.h"

//#import "UIImageView+Alpha.h"
//#import <UIImageView+UIActivityIndicatorForSDWebImage.h>

#import <QuartzCore/QuartzCore.h>





// App Name

#define App_Name @"DB_DEMO"


#pragma mark - Extra

#if DEBUG
#include <libgen.h>

#define ZDebug(fmt, args...)  NSLog(@"[%s:%d] %@\n", basename(__FILE__), __LINE__, [NSString stringWithFormat:fmt, ##args])
#else
#define ZDebug(fmt, args...)  ((void)0)
#endif

#define HIDE_STATUS_BAR if(![[UIApplication sharedApplication]isStatusBarHidden])[[UIApplication sharedApplication] setStatusBarHidden:YES]
#define SHOW_STATUS_BAR if([[UIApplication sharedApplication]isStatusBarHidden])[[UIApplication sharedApplication] setStatusBarHidden:NO]



/*-----------------------------------------------------------------------------*/
#define APPDELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define DB APPDELEGATE.db
/*-----------------------------------------------------------------------------*/
#define showIndicator [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
#define hideIndicator [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
/*-----------------------------------------------------------------------------*/

#define screenSize ([[UIScreen mainScreen ] bounds])
/*-----------------------------------------------------------------------------*/
#define MAX_CONTENT_DOWNLOAD 3

/*-----------------------------------------------------------------------------*/

#define LSSTRING(str) NSLocalizedString(str, nil)
#define UserDefaults ([NSUserDefaults standardUserDefaults])
#define kAFAPIClient [AFAPIClient sharedClient]

/*-----------------------------------------------------------------------------*/
#define SHOW_ALERT(TITLE, MSG) [[[UIAlertView alloc] initWithTitle:(TITLE) \
message:(MSG) \
delegate:nil \
cancelButtonTitle:@"OK" \
otherButtonTitles:nil] show]

//Pop
#define popView [self.navigationController popViewControllerAnimated:YES]

#define SHOW_NAV_ANIMATED if(self.navigationController.navigationBar.hidden)[self.navigationController setNavigationBarHidden:NO animated:YES];
#define HIDE_NAV_ANIMATED if(!self.navigationController.navigationBar.hidden)[self.navigationController setNavigationBarHidden:YES animated:YES];
/*-----------------------------------------------------------------------------*/

#pragma mark - Gcd 

//GCD
#define ASYNC_BACK(...) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{ __VA_ARGS__ })
#define ASYNC_MAIN(...) dispatch_async(dispatch_get_main_queue(), ^{ __VA_ARGS__ })



#pragma mark - DeviceCheck

#define iPhone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define IS_DEVICE_iPHONE_5 ((UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) && ([[UIScreen mainScreen ] bounds].size.height>=568.0f))
#define iPhone5ExHeight ((IS_DEVICE_iPHONE_5)?88:0)
#define iPhone5Ex_Half_Height ((IS_DEVICE_iPHONE_5)?88:0)
#define IS_IPHONE6 ([UIScreen mainScreen].bounds.size.height == 667)//750 × 1334
#define IS_IPHONE6Plus ([UIScreen mainScreen].bounds.size.height == 736)//1242 × 2208   414 * 736
#define IS_IPHONE4 ([UIScreen mainScreen].bounds.size.height == 480)//750 × 1334
#define kDEV_PROPROTIONAL(val) ([UIScreen mainScreen].bounds.size.width / 414.0f * val)

//#define iPhone5_ImageSuffix (IS_DEVICE_iPHONE_5)?@"-568h":@""
//#define ImageName(name)([NSString stringWithFormat:@"%@%@",name,iPhone5_ImageSuffix])

#define IS_DEVICE_iPHONE_4 ((UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) && ([[UIScreen mainScreen ] bounds].size.height==480.0f))

#define ios8 (([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)?20:0)

#define createNavBar(title123,titleColor,imageCreated) self.title = title123;[self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:titleColor,NSForegroundColorAttributeName,kFONT_REGULAR(18.0),NSFontAttributeName,nil]];[self.navigationController.navigationBar setShadowImage:imageCreated];
//#define createNavBarImage(r,g,b) CGSize size = CGSizeMake(screenSize.size.width, 0.5);UIGraphicsBeginImageContextWithOptions(size, YES, 0);[[UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f] setFill];UIRectFill(CGRectMake(0, 0, size.width, size.height));UIImage *image = UIGraphicsGetImageFromCurrentImageContext();UIGraphicsEndImageContext();[self.navigationController.navigationBar setShadowImage:image];
/*-----------------------------------------------------------------------------*/
/*
 HelveticaNeue-Italic
 HelveticaNeue-Bold
 HelveticaNeue-UltraLight
 HelveticaNeue-CondensedBlack
 HelveticaNeue-BoldItalic
 HelveticaNeue-CondensedBold
 HelveticaNeue-Medium
 HelveticaNeue-Light
 HelveticaNeue-Thin
 HelveticaNeue-ThinItalic
 HelveticaNeue-LightItalic
 HelveticaNeue-UltraLightItalic
 HelveticaNeue-MediumItalic
 */
#pragma mark - Fonts
//#define kFONT_BOLD(sizeF) [UIFont fontWithName:@"Helvetica-Bold" size:sizeF]
//#define kFONT_THIN(sizeF) [UIFont fontWithName:@"Helvetica-Thin" size:sizeF]
//#define kFONT_ITALIC(sizeF) [UIFont fontWithName:@"Helvetica-Italic" size:sizeF]
//#define kFONT_MEDIUM(sizeF) [UIFont fontWithName:@"Helvetica-Medium" size:sizeF]
//#define kFONT_ITALIC_LIGHT(sizeF) [UIFont fontWithName:@"Helvetica-LightItalic" size:sizeF]

#define kFONT_REGULAR(sizeF) [UIFont fontWithName:@"Helvetica" size:sizeF]
#define kFONT_LIGHT(sizeF) [UIFont fontWithName:@"Helvetica-Light" size:sizeF]
#define kFONT_OPENSANS_REGULAR(sizeF) [UIFont fontWithName:@"OpenSans" size:sizeF]
#define kFONT_OPENSANS_BOLD(sizeF) [UIFont fontWithName:@"OpenSans-Bold" size:sizeF]
#define kFONT_OPENSANS_SEMIBOLD(sizeF) [UIFont fontWithName:@"OpenSans-Semibold" size:sizeF]

#pragma mark- Colors

// Set RGB Color
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1.0f]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]
#define RGBCOLOR_NAVBAR [UIColor colorWithRed:101.0f/255.0f green:211.0f/255.0f blue:227.0f/255.0f alpha:1.0f]

#define RGBCOLOR_GREY [UIColor colorWithRed:205.0/255.0f green:205.0/255.0f blue:205.0/255.0f alpha:1.0f]


#define APP_BLUE  RGBCOLOR(121, 229, 273)
#define NOTIF_GREY RGBCOLOR(147, 147, 147)
#define NOTIF_BLUE RGBCOLOR(88, 162, 236)
#define NOTIF_TIME RGBCOLOR(190, 190, 190)
/*-----------------------------------------------------------------------------*/
#pragma mark - Web Service parameters declaration

#define kURLGet @"GET"
#define kURLPost @"POST"
#define kURLNormal @"NORMAL"
#define kURLFail @"Fail"
#define kTimeOutInterval 60

/*-----------------------------------------------------------------------------*/

#define showHUD [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
#define hideHUD [SVProgressHUD dismiss];

#define showHUD_with_Title(status) [SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeClear];
#define showHUD_with_Progress(progress,status123) [SVProgressHUD showProgress:progress status:status123 maskType:SVProgressHUDMaskTypeClear]

#define showHUD_with_error(errorTitle) [SVProgressHUD showErrorWithStatus:errorTitle];
#define showHUD_with_Success(successTitle) [SVProgressHUD showSuccessWithStatus:successTitle];

/*-----------------------------------------------------------------------------*/

#define kNotification_refresh_HomeView @"refresh_HomeView"
#define kNotification_Update_MessageList @"updateMessageListNotification"

/*-----------------------------------------------------------------------------*/



#pragma mark Placeholders & images

#define PLACE_USER [UIImage imageNamed:@"circlePlaceHolder"]
#define PLACE_STREAM [UIImage imageNamed:@"placeHolderStream"]
#define PLACE_STREAM_BLACK appDel.placeErrorBlack

#define FOLLOW_IMAGE [UIImage imageNamed:@"icon-check"]
#define OPTION_IMAGE [UIImage imageNamed:@"optionBtn"]
#define UNFOLLOW_IMAGE [UIImage imageNamed:@"down-arrow"]

#pragma mark - Default Keys

#define SERVER_FORMAT @"yyyy-MM-dd'T'HH:mm:ss.SSSZ"

#pragma mark - Enums
typedef enum ExploreType
{
    SUGGESTED,
    CATEGORY,
    NEW,
    HASHTAG
} ExploreType;

typedef enum FeedType
{
    NEW_COMMENT=0,//new comment
    INVITE_STREAM,//invite to stream
    CONTENT_ACCEPTED,//content accepted
    NEW_STREAM_BY_FOLLOW,//new stream by someone you follow
    PENDING_CONTENT,//pending content for approval
    NEW_FOLLOWING,// new user is following you
    NEW_CONTENT_STREAM_FOLLOW,//nw content in stream you follow
    MENTION_COMMENT, // Someone mentioned you in comment
    NEW_FOLLOWED_STREAM, // Follwed user has followed new stream
    DEFAULT_NA
} FeedType;


#define DEVICE_TOKEN @"deviceToken"

#define STATUS_CODE @"status"
#define SUCCESS @"success"
#define DATA @"data"
#define MESSAGE @"message"


#define STATUS_PATH @"ResultStatus.Status"
#define STATUS_MESSAGE_PATH @"ResultStatus.StatusMessage"

#define PLEASE_TRY_AGAIN @"Please Try Again"
/*------------------------ APP USAGE -----------------------------------------------------*/

#define CONTENT_TYPE_PNG @"image/png"
#define CONTENT_TYPE_MP4 @"video/mp4"

#define USER_INFO @"userinformation"
#define USER_TOKEN @"access_token"
#define USER_ID @"useridloggedinuser"

/*-----------------------------------------------------------------------------*/
#pragma mark - Shared model and Bools



BOOL isAppBackground;
BOOL is_NewCreateStream; // Navigate to fav view after contribute in new stream
BOOL isUpdate_Fav,isUpdate_Home,isUpdate_Manage,isUpdate_Profile,isUpdate_Notification;//Tabs
BOOL isUpdate_Suggested,isUpdate_People,isUpdate_College,isUpdate_SearchALL;//category
BOOL isUpdate_StreamDetail,isUpdate_OtherProfile,isUpdate_StreamInfo;//Extra


//const NSInteger UIViewContentModeScaleAspectFill = 2;
/*-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------*/
#define ACCEPTABLE_CHARACTERS @" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."
/*-----------------------------------------------------------------------------*/


#define ImageURL(url) [NSString stringWithFormat:@"%@%@",IMAGE_BASE_URL,url]
#define UNAUTHORIZED @"Unauthorized"
#define UNAUTHORIZED_STREAM @"This stream is private.You are not invited or access of this stream."

@interface AppConstant : NSObject

@end

#import <Foundation/Foundation.h>
#import "LocationHelper.h"


@interface ApplicationData : NSObject
{
    NSDateFormatter *dateFormatter;
    
}
@property (nonatomic)NSUInteger appBadgeCount;

@property (nonatomic, strong) LocationHelper *sharedLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@end

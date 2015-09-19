#import "ApplicationData.h"
#import <SystemConfiguration/SystemConfiguration.h>


static ApplicationData *applicationData = nil;

@implementation ApplicationData

- (void)initialize {
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAuthorizationStatus:) name:kAuthorizationUpdateNotification object:nil];
}


+ (ApplicationData *)sharedInstance {
	if (applicationData == nil) {
		applicationData = [[super allocWithZone:NULL] init];
		[applicationData initialize];
	}
	return applicationData;
}

-(CLLocation*)currentLocation{
    return self.sharedLocation.currentLocation;
}



-(BOOL)isValidCurrentLocation{
//    if (AppSingleton.currentLocation!=nil && (AppSingleton.currentLocation.coordinate.latitude!=0 && AppSingleton.currentLocation.coordinate.longitude!=0 )) {
//        if(CLLocationCoordinate2DIsValid(AppSingleton.currentLocation.coordinate)) {
//             return YES;
//        }
//    }
    return NO;
}



#pragma mark - Location Helper DataSource

- (void)locationAuthorizationStatus:(NSNotification *)authorizationStatus {
    NSNumber *granted = authorizationStatus.object;
    if (!granted.boolValue) {
       // [CommonMethods showNoLoactionAlert];
    }
}


@end

//
//  LocationController.m
//  LocationHelperExample
//
//  Created by Jennis on 05/27/13.
//  Copyright 2013 Jennis. All rights reserved.
//  See the file License.txt for copying permission.
//

#import "LocationHelper.h"
#import "AppConstant.h"

@implementation LocationHelper
@synthesize currentLocation;
static LocationHelper *sharedLocationHelper = nil;

+ (LocationHelper *)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    sharedLocationHelper = [[LocationHelper alloc] init];
	});
	return sharedLocationHelper;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		_locationManager = [[CLLocationManager alloc] init];
		_locationManager.delegate = self;
		_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
		_locationManager.distanceFilter = 1.0f;
        if (ios8)
        {
            [self.locationManager requestWhenInUseAuthorization];
            //[self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
	}
	return self;
}

- (void)requestNewLocation {
	if ([self isAuthorized]) {
		[_locationManager startUpdatingLocation];
		return;
	}
	else {
		_locationDenied = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:kAuthorizationUpdateNotification object:@NO userInfo:nil];
	}
}

- (void)stopLocationUpdates {
	[self.locationManager stopUpdatingLocation];
	[self.locationManager setDelegate:nil];
    [self.locationManager stopMonitoringSignificantLocationChanges];
    //NSLog(@"%hhd",[CLLocationManager locationServicesEnabled]);
}

-(void)startLocationUpadtes{
    //[_locationManager startMonitoringSignificantLocationChanges];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    self.locationManager.delegate = self;
    //NSLog(@"%hhd",[CLLocationManager locationServicesEnabled]);
}

#pragma mark - CLLocationManager Delegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	currentLocation = newLocation;
    NSLog(@"New location: %@",currentLocation);
//   if (currentLocation.coordinate.latitude!=0.0 && currentLocation.coordinate.longitude!=0.0) {
//       [AppSingleton saveUserlastLocation];
//   }
//    BOOL isInBackground = NO;
//    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
//    {
//        [[NSNotificationCenter defaultCenter]postNotificationName:BACKGROUNDCONNECTDISCONNECT object:nil userInfo:@{@"shouldCancel":[NSNumber numberWithBool:NO]}];
//    }
    
   // NSLog(@"Updated location %@",newLocation);
	//[[NSNotificationCenter defaultCenter] postNotificationName:kLocationUpdateNotification object:_currentLocation userInfo:nil];
}

//- (void)locationManager:(CLLocationManager *)manager
//     didUpdateLocations:(NSArray *)locations{
//    if (locations.count>0) {
//        currentLocation = locations[0];
//        if (currentLocation.coordinate.latitude!=0.0 && currentLocation.coordinate.longitude!=0.0) {
//            [AppSingleton saveUserlastLocation];
//        }
//    }
//}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if ([error code] == kCLErrorDenied) {
		_locationDenied = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:kAuthorizationUpdateNotification object:@NO userInfo:nil];
        
		return;
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:kLocationUpdateNotification object:error userInfo:nil];
}

//Apple method
- (void)getAddressFromLocation:(CLLocation *)location {
	CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
	[geoCoder reverseGeocodeLocation:currentLocation completionHandler: ^(NSArray *placemarks, NSError *error) {
	    if (error) {
	        NSLog(@"Geocode failed with error: %@", error);
	        return;
		}
	    if (placemarks && placemarks.count > 0) {
	        //Get nearby address
	       // CLPlacemark *placemark = [placemarks objectAtIndex:0];
	        //String to hold address
	        //NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
	        //Print the location to console
	        //NSLog(@"I am currently at %@", locatedAt);
		}
	}];
}


#pragma mark - Authorization methods

- (BOOL)isAuthorized {
	BOOL authorizationStatus = NO;
	if (![CLLocationManager locationServicesEnabled]) {
		return authorizationStatus;
	}
	if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
		return authorizationStatus;
	}

	if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse) {
		authorizationStatus = YES;
		return authorizationStatus;
	}
    
    
	return authorizationStatus;
}

@end

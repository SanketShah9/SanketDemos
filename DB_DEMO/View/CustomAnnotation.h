//
//  Location.h
//  BL085.Prototype
//
//  Created by Bobby Gill on 8/20/14.
//  Copyright (c) 2014 Blue Label Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject <MKAnnotation>
@property float longitude;
@property float latitude;
@property (nonatomic,strong) NSString* userid;
@property (nonatomic, strong) NSString* username;
//@property (nonatomic, strong) OtherUser* userDetails;


@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
- (id)initWithLocation:(CLLocationCoordinate2D)coord;
- (id)initFromJson:(NSDictionary*)jsonDictionary;
//- (id)initFromOtherUser:(OtherUser*)modelUser;
- (void)updateUserLatitude:(float)latitude longitude:(float)longitude;
- (NSDictionary*)toDictionary;
@end

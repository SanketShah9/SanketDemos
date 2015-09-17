//
//  Location.m
//  BL085.Prototype
//
//  Created by Bobby Gill on 8/20/14.
//  Copyright (c) 2014 Blue Label Labs. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation
@synthesize longitude;
@synthesize latitude;
@synthesize coordinate;
@synthesize userid;
@synthesize username;


- (id)initWithLocation:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        coordinate = coord;
        
       
    }
    return self;
}


- (id)initWithLocation:(CLLocationCoordinate2D)coord
             forUserId:(NSString*) userId
          withUsername:(NSString*)userName
          withLatitude:(long)lat
         withLongitude:(float)lon
{
    self = [super init];
    if (self) {
        coordinate = CLLocationCoordinate2DMake(lat,lon);
        self.userid = userId;
        self.username = userName;
    }
    return self;
}


- (NSString*)title
{
    return self.username;
}

- (NSString*)subtitle
{
    return [NSString stringWithFormat:@"%f,%f",self.coordinate.latitude,self.coordinate.longitude];
}

- (id) initFromJson:(NSDictionary *)jsonDictionary
{


    self = [super init];
    if (self)
    {

        NSNumber* latObj = [jsonDictionary valueForKey:@"latitude"];
        NSNumber* lonObj = [jsonDictionary valueForKey:@"longitude"];
        
        float lat = [latObj floatValue];
        float lon = [lonObj floatValue];
        NSString* userId =[jsonDictionary valueForKey:@"userid"];
        NSString* userName =[jsonDictionary valueForKey:@"username"];
        
        self.username = userName;
        self.userid = [NSString stringWithFormat:@"%@",userId];
        self.latitude =  lat;
        self.longitude = lon;
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lon);
        coordinate = coord;
        //self.userDetails = [[OtherUser alloc]initWithJsonDictionary:jsonDictionary];
    }
    return self;
}

//- (id)initFromOtherUser:(OtherUser*)modelUser{
//    self = [super init];
//    if (self)
//    {
//        self.username = modelUser.Username;
//        self.userid = [NSString stringWithFormat:@"%@",modelUser.UserID];
//        
//        CLLocationCoordinate2D coord = modelUser.location.coordinate;
//        coordinate = coord;
//        self.userDetails = modelUser;
//    }
//    return self;
//}

- (void)updateUserLatitude:(float)lat longitude:(float)lon
{
    [self willChangeValueForKey:@"coordinate"];
    CLLocationCoordinate2D newCoord = CLLocationCoordinate2DMake(lat, lon);
    coordinate = newCoord;
    [self didChangeValueForKey:@"coordinate"];
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary* retVal = [[NSMutableDictionary alloc]init];
    
    [retVal setValue:[NSNumber numberWithFloat:self.longitude] forKey:@"longitude"];
    [retVal setValue:[NSNumber numberWithFloat:self.latitude] forKey:@"latitude"];
    return retVal;
}


+ (UIColor*)randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end

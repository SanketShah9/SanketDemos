//
//  AFURLResponseSerializerWithData.h
//  Hubdin
//
//  Created by MAC237 on 5/13/14.
//  Copyright (c) 2014 MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFURLResponseSerialization.h"
/// NSError userInfo key that will contain response data
static NSString * const JSONResponseSerializerWithDataKey = @"body";
static NSString * const JSONResponseSerializerWithBodyKey = @"statusCode";

@interface AFURLResponseSerializerWithData : AFJSONResponseSerializer

@end

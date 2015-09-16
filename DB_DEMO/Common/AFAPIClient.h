//
//  AFAPIClient.h
//  Demo
//
//  Created by MAC107 on 09/05/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "AFURLResponseSerializerWithData.h"

@interface AFAPIClient : AFHTTPRequestOperationManager
+ (instancetype)sharedClient;
typedef void (^APIRequestBlock)(BOOL success, id result, NSError *error);


- (void)cancelOperationsWithURL:(NSString *)path ;
-(void)setMyNewAccessToken;

@end

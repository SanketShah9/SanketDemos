//
//  AFAPIClient.h
//  Demo
//
//  Created by MAC107 on 09/05/14.
//  Copyright (c) 2014 tatva. All rights reserved.
//

#import "AppConstant.h"
#import "AFAPIClient.h"
#define MES_FLAG @"Flagged Inappropriate"
static NSString *const AFAppDotNetAPIBaseURLString = BASE_URL;

NSMutableArray *resumeTasksArray;
BOOL isRefreshing = NO;
AFHTTPRequestOperation *refreshTokenOperation, *getTokenOperation;

@implementation AFAPIClient

+ (instancetype)sharedClient {
	static AFAPIClient *_sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    _sharedClient = [[AFAPIClient alloc] initWithBaseURL:[NSURL URLWithString:AFAppDotNetAPIBaseURLString]];
	    _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedClient.responseSerializer = [AFURLResponseSerializerWithData serializerWithReadingOptions:0];
         _sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        _sharedClient.responseSerializer = [AFURLResponseSerializerWithData serializer];
        _sharedClient.requestSerializer =  [AFJSONRequestSerializer serializer];
        [_sharedClient.requestSerializer setTimeoutInterval:200];
        [_sharedClient.requestSerializer setValue:@"application/json"  forHTTPHeaderField:@"Content-Type"];
        
//        NSString *strToken = [[NSString stringWithFormat:@"%@",myUserModelGlobal.access_token] isNull];
//        if (strToken.length > 0) {
//            [_sharedClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", strToken] forHTTPHeaderField:@"Authorization"];
//        }
        
        _sharedClient.responseSerializer.acceptableContentTypes = [_sharedClient.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"application/x-www-form-urlencoded",@"text/html"]];
	    resumeTasksArray = [[NSMutableArray alloc]initWithCapacity:0];
	});
	return _sharedClient;
}


-(void)setMyNewAccessToken
{
//    NSString *strToken = [[NSString stringWithFormat:@"%@",myUserModelGlobal.access_token] isNull];
//    if (strToken.length > 0) {
//        [self.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", strToken] forHTTPHeaderField:@"Authorization"];
//    }
}
-(void)cancelAllOperation
{
    [self.operationQueue cancelAllOperations];
}
- (void)cancelOperationsWithURL:(NSString *)path {

    //path = [NSString stringWithFormat:@"/BL085.Web/%@",path];
    NSArray *operations = self.operationQueue.operations;
    for (AFHTTPRequestOperation *operation in operations) {
       // NSLog(@"Path:%@",path);
        //NSLog(@"URL:%@",operation.request.URL.path);
        NSString *url = [operation.request.URL path];
        if ([url isEqualToString:path]) {
            NSLog(@"---------------- Cancelled Path %@", path);
            [operation cancel];
        }
    }
}




@end

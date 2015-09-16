//
//  UserDetailsModal.h
//  Dedicaring
//
//  Created by MAC107 on 17/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConstant.h"

#import "AFAPIClient.h"
#import "AFDownloadRequestOperation.h"
typedef void (^DownloadBlock)(BOOL success, float progress, NSError *error);
typedef void (^ProgressBLock)(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);
@interface DownloadManager : NSObject
{
    AFDownloadRequestOperation *operation;
    NSMutableArray *arrURL;
}
@property(nonatomic,readwrite)NSInteger downloadingIndex;
+ (DownloadManager *)sharedManager;
- (void)startDownloadWithURL:(NSString *)downloadUrl handler:(DownloadBlock)completionHandler;
-(void)cancelAllRequest;

-(void)downloadVideo_withArray:(NSArray *)arrURLTemp handler:(DownloadBlock)completionHandler;
-(void)cancel_RequestForTable;

-(void)pauseDownload;
-(void)resumeDownload;
@end

//
//  UserDetailsModal.m
//  Dedicaring
//
//  Created by MAC107 on 17/11/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "DownloadManager.h"

@implementation DownloadManager


#pragma mark - Shared Instance
+ (DownloadManager *)sharedManager
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance initialize];
    });
    return sharedInstance;
}
- (void)initialize {
    arrURL = [[NSMutableArray alloc]init];
    [kAFAPIClient.operationQueue setMaxConcurrentOperationCount:1];
}

#pragma mark - DownLoad Specific Video
- (void)startDownloadWithURL:(NSString *)downloadUrl handler:(DownloadBlock)completionHandler
{
    if (operation) {
        operation = nil;
    }
   if (!operation)
   {
        NSURL *url = [NSURL URLWithString:[downloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
       
        operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:DocumentsDirectoryPath() shouldResume:YES];
       
        operation.shouldOverwrite = YES;
        operation.deleteTempFileOnCancel = NO;
    }
   [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
       //NSLog(@"Done");
       
       completionHandler(YES,100.0,nil);
    
   }failure:^(AFHTTPRequestOperation *operationFail, NSError *error) {
        NSLog(@"Failure");
        operationFail = nil;
        completionHandler(NO,0.0,error);
    }];

    [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToRead)
    {
        float progress = totalBytesRead / (float)totalBytesExpectedToRead;
        //NSLog(@"Prog : %f",progress);
        completionHandler(NO,progress,nil);
    }];
    
     [operation setQueuePriority:NSOperationQueuePriorityVeryLow];
    /*--- If operation is not executing and not finished then Start New Operation ---*/
    if (!operation.isExecuting && !operation.isFinished) {
        [operation start];
    }
    
    
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//    
//    NSURL *URL = [NSURL URLWithString:@"http://example.com/download.zip"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    
//    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        NSLog(@"File downloaded to: %@", filePath);
//    }];
//    [downloadTask resume];
}
-(void)cancelAllRequest
{
    /*--- Cancel Operation ---*/
    [operation cancel];
    operation = nil;
}



#pragma mark - Download Videos Array for Home View
-(void)downloadVideo_withArray:(NSArray *)arrURLTemp handler:(DownloadBlock)completionHandler
{
  //  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self cancel_RequestForTable];
    for (int i = 0; i<arrURLTemp.count; i++)
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:[DocumentsDirectoryPath() stringByAppendingPathComponent:[arrURLTemp[i] lastPathComponent]]])
        {
            /*--- set url and create download request ---*/
            NSURL *url = [NSURL URLWithString:[arrURLTemp[i] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            AFDownloadRequestOperation *ope = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:DocumentsDirectoryPath() shouldResume:YES];
            operation.shouldOverwrite = YES;
            operation.deleteTempFileOnCancel = NO;
        
            /*--- Set progress---*/
            [ope setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                //float progress = totalBytesRead / (float)totalBytesExpectedToRead;
                //completionHandler(NO,progress*100,nil);
                //NSLog(@"Prog : %f",progress);
            }];
            [ope setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                //NSLog(@"Complete");
                /*--- Download specific video if all video download then call handler ---*/
                if (i == arrURLTemp.count-1) {
                    completionHandler(YES,100.0,nil);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                completionHandler(NO,0.0,error);
                
                /*--- If last video fail then call handler ---*/
                if (i == arrURLTemp.count-1) {
                    completionHandler(NO,0.0,error);
                    //return ;
                }
            }];

            [arrURL addObject:ope];
        }
        else
        {
            /*--- File already exist at document directory ---*/
            NSLog(@"File Exist");
            if (i == arrURLTemp.count-1) {
                completionHandler(YES,100.0,nil);
                //return;
            }
        }
    }
    if (arrURL.count > 0)
    {
        /*--- Set maximum concurrent operation 1 and add all operations ---*/
        [kAFAPIClient.operationQueue setMaxConcurrentOperationCount:1];
        [kAFAPIClient.operationQueue addOperations:arrURL waitUntilFinished:NO];
        
        
        /*--- Call when specific operation complete this will remove specific operation when complete ---*/
        [AFDownloadRequestOperation batchOfRequestOperations:kAFAPIClient.operationQueue.operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            NSLog(@"Complete %lu/%lu",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
            //[self removeCompletedOperations];
        } completionBlock:^(NSArray *operations) {
            
        }];
    }
   // });
}
-(void)pauseDownload
{
    for (AFDownloadRequestOperation *operationT in kAFAPIClient.operationQueue.operations) {
        // NSLog(@"Path:%@",path);
        //NSLog(@"URL:%@",operation.request.URL.path);
        NSString *url = [operationT.request.URL path];
        if ([url containsString:@".mp4"]) {
            NSLog(@"---------------- Cancelled Path %@", url);
            [operationT cancel];
        }
    }
}
-(void)resumeDownload
{
    for (AFDownloadRequestOperation *operationT in kAFAPIClient.operationQueue.operations) {
        // NSLog(@"Path:%@",path);
        NSLog(@"URL:%@",operation.request.URL.path);
        NSString *url = [operationT.request.URL path];
        if ([url containsString:@".mp4"]) {
            NSLog(@"---------------- Cancelled Path %@", url);
            [operationT resume];
        }
    }
}
-(void)cancel_RequestForTable
{
    //NSLog(@"Cancel Before : %lu",(unsigned long)kAFApiClient.operationQueue.operations.count);
//    for (AFDownloadRequestOperation *req in kAFAPIClient.operationQueue.operations) {
//        //if (req.isExecuting && !operation.isFinished) {
//        [req cancel];
//        //}
//    }
    
    
    for (AFDownloadRequestOperation *operationT in kAFAPIClient.operationQueue.operations) {
        // NSLog(@"Path:%@",path);
        //NSLog(@"URL:%@",operation.request.URL.path);
        NSString *url = [operationT.request.URL path];
        if ([url containsString:@".mp4"]) {
            NSLog(@"---------------- Cancelled Path %@", url);
            [operationT cancel];
        }
    }
    
    //[kAFAPIClient.operationQueue cancelAllOperations];
    //NSLog(@"Cancel After : %lu",(unsigned long)kAFApiClient.operationQueue.operations.count);
    
    [arrURL removeAllObjects];
}

/*
-(void)removeCompletedOperations
{
    NSLog(@"Running Openration : %lu",(unsigned long)kAFApiClient.operationQueue.operations.count);
    for (AFDownloadRequestOperation *req in kAFApiClient.operationQueue.operations) {
        if (req.isFinished) {
            [req cancel];
        }
    }
    NSLog(@"Now Running Openration : %lu",(unsigned long)kAFApiClient.operationQueue.operations.count);
}
*/

@end

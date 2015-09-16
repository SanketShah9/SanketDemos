//
//  AppDelegate.m
//  DB_DEMO
//
//  Created by Sanket Shah on 13/09/15.
//  Copyright (c) 2015 Sanket Shah. All rights reserved.
//

#import "AppDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>
#define DATABASE   @"Sakila.sqlite"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize db;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        NSError *error;
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    if([fileManager fileExistsAtPath:[self pathForFile:DATABASE]])
    {
        BOOL success = [fileManager removeItemAtPath:[self pathForFile:DATABASE] error:&error];
        
        if (success) {
            NSLog(@"Copy Databse");
            NSString *fromPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE];
            [fileManager copyItemAtPath:fromPath toPath:[self pathForFile:DATABASE] error:nil];
        }
    }

    
    [self openDb];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Connection Check
- (BOOL)checkConnection:(void (^)(void))completion
{
    const char *host_name = "www.google.com";
    BOOL _isDataSourceAvailable = NO;
    Boolean success;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL,host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    _isDataSourceAvailable = success &&
    (flags & kSCNetworkFlagsReachable) &&
    !(flags & kSCNetworkFlagsConnectionRequired);
    
    CFRelease(reachability);
    
    if (completion) {
        completion();
    }
    return _isDataSourceAvailable;
}

#pragma mark - DB setup


- (NSString *)pathForFile:(NSString *)fileName
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
            stringByAppendingPathComponent:fileName];
}

- (void)openDb
{
    db = [FMDatabase databaseWithPath:[self pathForFile:DATABASE]];
    if (![db open])
    {
        NSLog(@"Could not open db.");
    }
}

- (void)closeDb
{
    if([db open])
        [db close];
}



+ (NSString *)dataFilePath:(NSString *)filename {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    return [docDirectory stringByAppendingPathComponent:filename];
}

+ (BOOL)getFileExistence:(NSString *)filename
{
    BOOL IsFileExists = NO;
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *favsFilePath = [documentsDir stringByAppendingPathComponent:filename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check if the database has already been created in the users filesystem
    if ([fileManager fileExistsAtPath:favsFilePath])
    {
        IsFileExists = YES;
    }
    return IsFileExists;
}


@end

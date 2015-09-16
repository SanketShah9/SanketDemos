//
//  AppDelegate.h
//  DB_DEMO
//
//  Created by Sanket Shah on 13/09/15.
//  Copyright (c) 2015 Sanket Shah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) FMDatabase *db;
- (void)openDb;
- (void)closeDb;
- (BOOL)checkConnection:(void (^)(void))completion;

@end


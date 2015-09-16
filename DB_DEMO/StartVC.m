//
//  StartVC.m
//  DB_DEMO
//
//  Created by Sanket Shah on 16/09/15.
//  Copyright (c) 2015 Sanket Shah. All rights reserved.
//

#import "StartVC.h"
#import "AppConstant.h"
@interface StartVC ()

@end

@implementation StartVC

- (void)viewDidLoad {
    [super viewDidLoad];
    FMResultSet *s = [DB executeQuery:@"SELECT * FROM city"];
    NSMutableArray *arrResultDict = [[NSMutableArray alloc] init];
    
    while ([s next]) {
        [arrResultDict addObject:[[NSMutableDictionary alloc] initWithDictionary:[s resultDictionary]]];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

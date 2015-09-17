//
//  StartVC.m
//  DB_DEMO
//
//  Created by Sanket Shah on 16/09/15.
//  Copyright (c) 2015 Sanket Shah. All rights reserved.
//

#import "StartVC.h"
#import "AppConstant.h"
#import "actor.h"
#import "DatabaseUtil.h"
@interface StartVC ()<UITextViewDelegate>

@end

@implementation StartVC

- (void)viewDidLoad {
    [super viewDidLoad];
        textxQuery.delegate=self;
    
//    NSArray *arrNames = @[@"Sanket",@"Kaushal",@"Jay"];
//    [arrNames enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
//        actor *newactor = [[actor alloc]init];
//        newactor.first_name = obj;
//        newactor.last_name = @"Shah";
//        newactor.actor_id = [NSNumber numberWithInt:201+(int)idx];
//        NSLog(@"%@",newactor.dictionaryValue);
//        //int status = [[DatabaseUtil sharedDatabaseInstance]insertDataWithDictionary:[NSMutableDictionary dictionaryWithDictionary:newactor.dictionaryValue] tableName:@"actor"];
//    }];
//    
//    
//    FMResultSet *s = [DB executeQuery:@"SELECT * FROM actor"];
//    NSMutableArray *arrResultDict = [[NSMutableArray alloc] init];
//    
//    while ([s next]) {
//        actor *newactor = [[actor alloc] initWithDictionary:[s resultDictionary] error:nil];
//         NSLog(@"%@",newactor.dictionaryValue);
//        [arrResultDict addObject:newactor];
//        
//    }

}

-(IBAction)donePressed:(id)sender{
     NSMutableArray *arrResultDict = [[NSMutableArray alloc] init];
    if (textxQuery.text.length>0) {
        FMResultSet *s = [DB executeQuery:textxQuery.text];
       
        
        while ([s next]) {
            [arrResultDict addObject:[[NSMutableDictionary alloc] initWithDictionary:[s resultDictionary]]];
        }
    }
    
}

//SELECT distinct title,release_year FROM film where title like '_%t'
//SELECT distinct title,release_year FROM film where title like '_%t' AND rental_duration =7 ORDER BY title DESC
//SELECT * FROM film where title like '_%t' AND rental_duration =7 AND rental_rate<3 ORDER BY title DESC
//SELECT * FROM customer where address_id in(select address_id from customer where first_name like 'A%_' or first_name like 'A%_')
//SELECT DISTINCT film.film_id, film_actor.actor_id, film.title FROM film INNER JOIN film_actor ON film.film_id = film_actor.film_id
//SELECT DISTINCT * FROM film INNER JOIN film_actor ON film.film_id = film_actor.film_id

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
    }
    return YES;
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

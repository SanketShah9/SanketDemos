//
//  actor.h
//  DB_DEMO
//
//  Created by Sanket Shah on 17/09/15.
//  Copyright (c) 2015 Sanket Shah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTLModel.h"
@interface actor : MTLModel
@property(nonatomic,strong)NSNumber *actor_id;
@property(nonatomic,strong)NSString *first_name,*last_name,*last_update;
@end

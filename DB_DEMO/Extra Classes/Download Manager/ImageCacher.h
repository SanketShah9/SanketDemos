//
//  ImageCacher.h
//  ThrowStream
//
//  Created by Mac009 on 5/11/15.
//  Copyright (c) 2015 tatva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageManager.h"
#import "DownloadManager.h"
typedef void (^ImageBlock)(BOOL success, NSError *error);

@interface ImageCacher : NSObject{
    
}
@property(nonatomic,strong)SDWebImageManager *curManager;

-(void)cacheNewImageWithurl:(NSURL*)url Completion:(ImageBlock)completion;

@end

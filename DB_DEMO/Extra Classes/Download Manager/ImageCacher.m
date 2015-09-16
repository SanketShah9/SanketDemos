//
//  ImageCacher.m
//  ThrowStream
//
//  Created by Mac009 on 5/11/15.
//  Copyright (c) 2015 tatva. All rights reserved.
//

#import "ImageCacher.h"
#import "SDWebImageManager.h"
@implementation ImageCacher
-(void)cacheNewImageWithurl:(NSURL*)url Completion:(ImageBlock)completion{
    @autoreleasepool {
        SDWebImageManager *manager = self.curManager ? self.curManager : [SDWebImageManager sharedManager];
        if ([[SDWebImageManager sharedManager]diskImageExistsForURL:url]) {
            completion(YES,nil);
        }
        else{
            
            [manager downloadImageWithURL:url options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (finished && image) {
                    
                    if(self)completion(YES,nil);
                }
                else{
                    if(self)completion(NO,error);
                }
            }];
        }
    }
}

-(void)dealloc{
}



@end

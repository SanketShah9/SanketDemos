//
//  VideoSublayerView.h
//  ThrowStream
//
//  Created by Mac009 on 5/6/15.
//  Copyright (c) 2015 tatva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPVolumeView.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideoSublayerView : UIView
@property(nonatomic,strong)MPMoviePlayerController *moviePlayer;
@property(nonatomic,strong)UIActivityIndicatorView *activityView;
-(void)playWithLiveStreaming:(NSURL*)url;
-(void)playWithDownloadedVideo:(NSURL*)url;
-(void)stopPlayer;
-(void)pauseVideo;
-(void)playVideo;
@end

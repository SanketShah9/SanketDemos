//
//  VideoSublayerView.m
//  ThrowStream
//
//  Created by Mac009 on 5/6/15.
//  Copyright (c) 2015 tatva. All rights reserved.
//

#import "VideoSublayerView.h"
#import "AppConstant.h"

#define UNKNOWN_MES @"Can't play video due to some error."

@interface VideoSublayerView()
{
    BOOL isPaused;
}
@end

@implementation VideoSublayerView
@synthesize moviePlayer;
@synthesize activityView;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

-(void)setup{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:moviePlayer];
    
    if (self.moviePlayer != NULL) {
        [self.moviePlayer.view removeFromSuperview];
        self.moviePlayer = NULL;
    }

    if ([moviePlayer.view isDescendantOfView:self]) {
        [moviePlayer.view removeFromSuperview];
    }
    self.backgroundColor = [UIColor blackColor];
    if (moviePlayer!=nil) {
        //[moviePlayer pause];
        moviePlayer = nil;
    }
    moviePlayer = [[MPMoviePlayerController alloc] init];
    moviePlayer.view.frame = self.frame;
    
    activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.hidesWhenStopped = YES;
    activityView.center = self.center;
    //activityView.tintColor = [UIColor whiteColor];
    //activityView.backgroundColor = [UIColor whiteColor];

    [activityView startAnimating];

    
    moviePlayer.controlStyle = MPMovieControlStyleNone;
    //moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    moviePlayer.view.backgroundColor = [UIColor clearColor];
    
   
//    NSError *error = nil;
//    BOOL success = [[AVAudioSession sharedInstance]
//                    setCategory:AVAudioSessionCategoryPlayback
//                    error:&error];
//    if (!success) {
//        // Handle error here, as appropriate
//    }

    //moviePlayer.useApplicationAudioSession = YES;//Added in ios 8 silent mode functionality
    moviePlayer.view.alpha = 0.0;
    [self addSubview:moviePlayer.view];
    [self addSubview:activityView];
    
}

-(void)addObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self  name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:moviePlayer];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterForground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)playWithLiveStreaming:(NSURL*)url{
    [self removeAllObservers];
    [self addObservers];
    moviePlayer.repeatMode = MPMovieRepeatModeOne;
    moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    moviePlayer.contentURL = url;
    [moviePlayer prepareToPlay];
     moviePlayer.shouldAutoplay=NO;
    moviePlayer.view.alpha = 1.0;
    [moviePlayer play];

}

-(void)playWithDownloadedVideo:(NSURL*)url{
        moviePlayer.view.frame = self.frame;
        [self removeAllObservers];
        [activityView stopAnimating ];
        [self addObservers];
        moviePlayer.repeatMode = MPMovieRepeatModeOne;
        moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        moviePlayer.contentURL = url;
        [moviePlayer prepareToPlay];
        moviePlayer.shouldAutoplay=YES;
        [moviePlayer setFullscreen:NO animated:NO];
        //[NSURL fileURLWithPath:[DocumentsDirectoryPath() stringByAppendingPathComponent:@"1430289161.606228_1527_1197_0.mp4"]]
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [moviePlayer play];
             moviePlayer.view.alpha = 1.0;
        });
    
}

-(void)removeAllObservers{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:moviePlayer];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

}

-(void)stopPlayer{
    [self removeAllObservers];
    if (moviePlayer) {
        [moviePlayer stop];
        moviePlayer.view.alpha = 0.0;
    }
}

-(void)enterBackground
{
     //MPMoviePlaybackState playbackState = moviePlayer.playbackState;
    //isPaused = playbackState==MPMoviePlaybackStatePaused ?YES:NO;
    [self pauseVideo];
}
-(void)enterForground
{
    //if (!isPaused) {
        [self playVideo];
    //}
}


-(void)pauseVideo{
    isPaused = YES;
    if (moviePlayer) {
        [moviePlayer pause];
    }
}

-(void)playVideo{
    isPaused = NO;
    if (moviePlayer) {
        [moviePlayer play];
    }
}

-(void) moviePlayerPlaybackStateDidChange:(NSNotification*)notification {
    
    MPMoviePlayerController *player = notification.object;
    MPMoviePlaybackState playbackState = player.playbackState;
    
    
    if(playbackState == MPMoviePlaybackStatePlaying)
    {
        NSLog(@"Playing Video Now");
        //[activityView stopAnimating];
    }
    else if (playbackState == MPMovieLoadStateUnknown)
    {
        NSLog(@"Start Movie");
        if (![APPDELEGATE checkConnection:nil]) {
            
            //[CommonMethods displayAlertwithTitle:@"Oops!" withMessage:NSLocalizedString(@"str_No_Internet", nil) withViewController:APPDELEGATE.window];
            
            
        }
        [moviePlayer play];
    }
    else if (playbackState == MPMoviePlaybackStateInterrupted)
    {
        if (!isPaused && playbackState != MPMoviePlaybackStatePlaying) {
            [moviePlayer play];
        }
    }

    
//    if (moviePlayer.loadState & MPMovieLoadStateStalled) {
//            [activityView startAnimating];
//            //[moviePlayer pause];
//        }
//    else
        if (moviePlayer.loadState & MPMovieLoadStatePlaythroughOK) {
//        if (!isPaused && playbackState != MPMoviePlaybackStatePlaying) {
//            [moviePlayer play];
//        }
        if (activityView.isAnimating) {
            [activityView stopAnimating];
        }
    }
    else if (moviePlayer.loadState & MPMovieLoadStatePlayable){
        if (!isPaused && playbackState != MPMoviePlaybackStatePlaying) {
            [moviePlayer play];
        }
        //[activityView stopAnimating];
    }
    
   // NSLog(@"%ld  %lu",playbackState,moviePlayer.loadState);
    
    //    else if(playbackState == MPMoviePlaybackStatePaused)
    //    {
    //        ispaused = YES;
    //        //isMoviePlaying = NO;
    //        NSLog(@"PAUSE Video Now");
    //
    //    }
    //    else if(playbackState == MPMoviePlaybackStateInterrupted)
    //    {
    //        ispaused = YES;
    //        //NSLog(@"INTER Video Now");
    //    }
    //    else if(playbackState == MPMoviePlaybackStateSeekingForward)
    //    {
    //        //NSLog(@"MPMoviePlaybackStateSeekingForward");
    //    }
    //    else if(playbackState == MPMoviePlaybackStateSeekingBackward)
    //    {
    //        //NSLog(@"MPMoviePlaybackStateSeekingBackward");
    //    }
    
   // NSLog(@"%ld  %lu",playbackState,moviePlayer.loadState);
}


-(void)myMovieFinishedCallback:(NSNotification *)notif
{
    NSLog(@"movie finish");
    //moviePlayer.view.alpha = 0.0;
    //[moviePlayer play];
    NSNumber *resultValue = [notif.userInfo objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    MPMovieFinishReason reason = [resultValue intValue];
    
    if (reason==MPMovieFinishReasonPlaybackEnded) {
        //[moviePlayer play];
    }
    if (reason == MPMovieFinishReasonPlaybackError)
    {
        NSError *mediaPlayerError = [notif.userInfo objectForKey:@"error"];
        if (mediaPlayerError)
        {
            NSLog(@"playback failed with error description: %@", [mediaPlayerError localizedDescription]);
        }
        else
        {
            NSLog(@"playback failed without any given reason");
        }
        [CommonMethods showErrorWithMessage:[mediaPlayerError localizedDescription]];
    }
}

-(void)dealloc{
        moviePlayer = nil;
        [self removeAllObservers];
}

@end

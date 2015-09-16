//
//  MoviePlayer.m
//  SuperBaby
//
//  Created by MAC107 on 21/01/15.
//  Copyright (c) 2015 tatva. All rights reserved.
//

#import "MoviePlayer.h"
#import "AppConstant.h"

@interface MoviePlayer ()
{
    BOOL isDismissView;
}
@end

@implementation MoviePlayer
- (void)viewDidLoad {
    [super viewDidLoad];
    isDismissView = NO;

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBG) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterFG) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self.moviePlayer setControlStyle:MPMovieControlStyleFullscreen];
    [self.moviePlayer setFullscreen:YES];
    [self.moviePlayer setMovieSourceType:MPMovieSourceTypeStreaming];
    [self.moviePlayer setContentURL:[NSURL URLWithString:[_moviePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    //[self.moviePlayer setContentURL:[NSURL URLWithString:@"https://s3.amazonaws.com/throwstream/1417691354.291999.mp4"]];
    self.moviePlayer.shouldAutoplay = YES;
    [self.moviePlayer prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayerLoadStateChanged:)
                                                 name:MPMoviePlayerLoadStateDidChangeNotification
                                               object:nil];
    // Register to receive a notification when the movie has finished playing.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    SHOW_STATUS_BAR;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    NSLog(@"MOVIE FINISH");
    [super viewWillDisappear:animated];
}
-(void)enterBG
{
    [self.moviePlayer pause];
}
-(void)enterFG
{
    [self.moviePlayer play];
}
#pragma mark - Movie Player Notification
- (void) moviePlayerLoadStateChanged:(NSNotification*)notification
{
    // Unless state is unknown, start playback
    if ([self.moviePlayer loadState] != MPMovieLoadStateUnknown)
    {
        NSLog(@"Start Movie");
        [self.moviePlayer play];
        
        // Remove observer
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playBackStateChange) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    }
}
-(void)playBackStateChange
{
    if (!isDismissView) {
        if (![SVProgressHUD isVisible]) {
            if (![APPDELEGATE checkConnection:nil]) {
                if (self.moviePlayer.currentPlaybackTime < self.moviePlayer.duration) {
                    [CommonMethods displayAlertwithTitle:@"Oops!" withMessage:NSLocalizedString(@"str_No_Internet", nil) withViewController:self];
                }
                
            }
        }
    }
    
    
    
    /*if(playbackState == MPMoviePlaybackStatePlaying)
     {
     NSLog(@"Playing Video Now");
     }
     else if(playbackState == MPMoviePlaybackStatePaused)
     {
     NSLog(@"PAUSE Video Now");
     }
     else if(playbackState == MPMoviePlaybackStateInterrupted)
     {
     NSLog(@"INTER Video Now");
     }
     else if(playbackState == MPMoviePlaybackStateSeekingForward)
     {
     NSLog(@"MPMoviePlaybackStateSeekingForward");
     }
     else if(playbackState == MPMoviePlaybackStateSeekingBackward)
     {
     NSLog(@"MPMoviePlaybackStateSeekingBackward");
     }*/
}
- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    // SHOW_STATUS_BAR;
    
    isDismissView = YES;
    [[NSNotificationCenter 	defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//            [self dismissViewControllerAnimated:YES completion:nil];
//            
//        });
    // Remove observer
}

#pragma mark - Extra
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIInterfaceOrientation
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
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

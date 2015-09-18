//
//  MoocIphoneCourseShow.m
//  MOOC@Beihang
//
//  Created by 周萱 on 14/11/19.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MoocIphoneCourseShow.h"
#import "MOOCConnection.h"


@interface MoocIphoneCourseShow ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) NSTimer *subtitleTimer;
@end

@implementation MoocIphoneCourseShow
@synthesize isHiddenStatusBar;

-(id)initWithUrl:(NSURL *)url
{
    self = [super init];
    if(self){
        _movie_url=url;
        self.view.autoresizesSubviews=YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    mpWidth = [UIScreen mainScreen].bounds.size.width*6.0/6.0;
    mpHeight=[UIScreen mainScreen].bounds.size.height;
    [self playMovieWithURL];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    if (_recvStr)
    {
        NSLog(@"receive_str:%@",_recvStr);
        NSURL *url = [NSURL URLWithString:_recvStr];
        _recvStr = nil;
        [self playMovieWithURL];
        
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_player && !_player.fullscreen)
    {
        [_player stop];
        [_player.view removeFromSuperview];
        _player = nil;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    
//    if(!prog.isStop){
//        [prog stop];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//palyer
- (void)playMovieWithURL
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mpWillEnterFullScreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mpEnterFullscreen:) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mpWillExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mpExitFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mpplaybackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationWillChange:)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mpplayStateChanged:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mpActivityDidload:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] init];
    mp.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    [mp.moviePlayer setContentURL:_movie_url];
    CGSize c = self.view.frame.size;
    mp.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    mp.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    [mp.moviePlayer prepareToPlay];
    [mp.moviePlayer openSRTFileAtPath:_subtitleUrl completion:^(BOOL finished) {[mp.moviePlayer showSubtitles];} failure:^(NSError *err){NSLog(@"%@",err);}];
    [mp.view setFrame:CGRectMake((c.width-mpWidth)/2.0, (c.height-mpWidth*9/16.0)/2.0, mpWidth, mpWidth*9/16.0)];
    CGRect progViewProg=CGRectMake(mp.view.frame.size.width/2.0-15, mp.view.frame.size.height/2.0-15, 30, 30);
    progView=[[UIView alloc]initWithFrame:progViewProg];
    [progView setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
    prog = [[UIActivityIndicatorView alloc] init];
    [prog setFrame:CGRectMake(mp.view.frame.size.width/2.0-10, mp.view.frame.size.height/2.0-10, 20, 20)];
    [mp.view addSubview:prog];
    [mp.view addSubview:progView];
    [prog startAnimating];
    if (_player)
    {
        [_player stop];
        [_player.view removeFromSuperview];
        _player = nil;
    }
    _player = mp.moviePlayer;
    [self.view addSubview:_player.view];
    @try
    {
        //NSLog(@"stop");
        [_player play];
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*5);
        dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (!_player.readyForDisplay)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (_player)
                    {
                        [_player stop];
                        [_player.view removeFromSuperview];
                        _player = nil;
                        //uialertview
                    }
                });
            }
        });
        
        
        
    }
    @catch (NSException *e)
    {
        NSLog(@"Error When Loading MP: %@",e.description);
        if (_player)
        {
            [_player stop];
            [_player.view removeFromSuperview];
            _player = nil;
        }
        //uialertview
    }
}

-(void)mpWillEnterFullScreen:(NSNotification *)noti
{
    [self.subtitleLabel removeFromSuperview];
}

- (void)mpEnterFullscreen:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_player)
        {
            [_player pause];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (!window)
            {
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            }
            CGSize c = self.view.frame.size;
            [_player.view setFrame:CGRectMake(0, 0, c.width, c.height)];
            _player.controlStyle = MPMovieControlStyleFullscreen;
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"这是一段测试性文字测试宽度"];
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(100, 250.0)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                context:nil];
            [_subtitleLabel setFrame:CGRectMake(0, 0, window.frame.size.width, rect.size.height)];
            self.subtitleLabel.center = CGPointMake(window.frame.size.width/2.0,window.frame.size.height-15.0);
            [window addSubview:_subtitleLabel];
            [_player play];
        }
    });
}

- (void)mpWillExitFullscreen:(NSNotification *)noti
{
    [self.subtitleLabel removeFromSuperview];
}

- (void)mpExitFullscreen:(NSNotification *)noti
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_player)
        {
            [_player pause];
            CGSize c = self.view.frame.size;
            [_player.view setFrame:CGRectMake((c.width-mpWidth)/2.0, (c.height-mpWidth*9/16.0)/2.0, mpWidth, mpWidth*9/16.0)];
            _player.controlStyle = MPMovieControlStyleDefault;
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"这是一段测试性文字测试宽度"];
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(100, 250.0)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                context:nil];
            [_subtitleLabel setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(_player.view.bounds), rect.size.height)];
            UIDeviceOrientation orientation=[UIDevice currentDevice].orientation;
            if(orientation==UIDeviceOrientationLandscapeLeft||orientation==UIDeviceOrientationLandscapeRight){
                self.subtitleLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(self.view.bounds)-rect.size.height/2.0);
            }
            else{
                self.subtitleLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, (CGRectGetHeight(self.view.bounds)+CGRectGetHeight(_player.view.bounds))/2.0-rect.size.height/2.0);
            }
            [self.view addSubview:self.subtitleLabel];
            [_player play];
        }
    });
}

-(void)mpplayStateChanged:(NSNotification *)noti
{
    switch (_player.playbackState) {
            
        case MPMoviePlaybackStateStopped: {
            
            // Stop
            if (self.subtitleTimer.isValid) {
                [self.subtitleTimer invalidate];
            }
            
            break;
        }
            
        case MPMoviePlaybackStatePlaying: {
            
            // Start timer
            self.subtitleTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                  target:self
                                                                selector:@selector(getSubtitleText)
                                                                userInfo:nil
                                                                 repeats:YES];
            [self.subtitleTimer fire];
            
            
            // Add label
            if (!self.subtitleLabel) {
                
                // Add label
                CGFloat fontSize = 0.0;
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    fontSize = 20.0;
                } else {
                    fontSize = 10.0;
                }
                NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"这是一段测试性文字测试宽度"];
                CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(100, 250.0)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                    context:nil];
                //CGRect *test=[@"nininini" boundingRectWithSize:CGSizeMake(100.0, 100.0) options:NSStringDrawingTruncatesLastVisibleLine  attributes:nil context:nil].size;
                self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(_player.view.bounds), rect.size.height)];
                self.subtitleLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(_player.view.bounds)+(CGRectGetHeight(self.view.bounds)-CGRectGetHeight(_player.view.bounds))/2.0- (CGRectGetHeight(self.subtitleLabel.bounds) / 2.0));
                //self.subtitleLabel.center=CGPointMake(CGRectGetWidth(self.view.bounds)/2.0,)
                self.subtitleLabel.backgroundColor=[UIColor clearColor];
                self.subtitleLabel.font = [UIFont boldSystemFontOfSize:fontSize];
                self.subtitleLabel.textColor = [UIColor whiteColor];
                self.subtitleLabel.numberOfLines = 0;
                self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
                self.subtitleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
                self.subtitleLabel.layer.shadowOffset = CGSizeMake(6.0, 6.0);
                self.subtitleLabel.layer.shadowOpacity = 0.9;
                self.subtitleLabel.layer.shadowRadius = 4.0;
                self.subtitleLabel.layer.shouldRasterize = YES;
                self.subtitleLabel.layer.rasterizationScale = [[UIScreen mainScreen] scale];
                [self.view addSubview:self.subtitleLabel];
            }
            
            break;
        }
            
        default: {
            
            break;
        }
            
    }
}

-(void)mpplaybackDidFinish:(NSNotification *)noti
{
    [_subtitleLabel removeFromSuperview];
}

- (void)orientationWillChange:(NSNotification *)notification {
    [_subtitleLabel removeFromSuperview];
}

- (void)orientationDidChange:(NSNotification *)notification {
    if(_player.fullscreen){
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window)
        {
            window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        }
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"这是一段测试性文字测试宽度"];
        CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(100, 250.0)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil];
        [_subtitleLabel setFrame:CGRectMake(0, 0, window.frame.size.width, rect.size.height)];
        self.subtitleLabel.center = CGPointMake(window.frame.size.width/2.0,window.frame.size.height-rect.size.height/2.0);
        [window addSubview:_subtitleLabel];
    }
    else{
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"这是一段测试性文字测试宽度"];
        CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(100, 250.0)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
        [_subtitleLabel setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(_player.view.bounds), rect.size.height)];
        self.subtitleLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, self.view.bounds.size.height-rect.size.height/2.0);
        [self.view addSubview:self.subtitleLabel];
    }
    
}

- (void)mpActivityDidload:(NSNotification *)noti
{
    NSLog(@"start playing movie");
    if(prog&&progView){
        [prog stopAnimating];
        [prog removeFromSuperview];
        [progView removeFromSuperview];
    }
    //[prog stop];
}

-(void)getSubtitleText
{
    self.subtitleLabel.text=_player.subtitleLabel;
}

- (void)receiveNotification:(NSNotification *)noti
{
    //NSLog(@"%@",noti.name);
}

-(void)setUpUrl:(NSURL *)url
{
    _movie_url=url;
}

- (IBAction)movieEnded:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return isHiddenStatusBar;
}

-(void)showStatusBar
{
    isHiddenStatusBar = NO;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)hideStatusBar
{
    isHiddenStatusBar = YES;
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)viewDidLayoutSubviews
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((orientation == UIInterfaceOrientationLandscapeLeft) || (orientation == UIInterfaceOrientationLandscapeRight))
    {
        [_aNavigationControllerBar setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        if(_player){
            [_player.view setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-([UIScreen mainScreen].bounds.size.height-44)*16.0/9.0)/2.0, 44, ([UIScreen mainScreen].bounds.size.height-44)*16.0/9.0, [UIScreen mainScreen].bounds.size.height-44)];
        }
    }
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UIDeviceOrientation orientation=[UIDevice currentDevice].orientation;
    if(orientation==UIDeviceOrientationLandscapeLeft||orientation==UIDeviceOrientationLandscapeRight){
        if(!_player.fullscreen){
            [_player pause];
            [_player.view setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-[UIScreen mainScreen].bounds.size.height*16.0/9.0)/2.0, 0, [UIScreen mainScreen].bounds.size.height*16.0/9.0, [UIScreen mainScreen].bounds.size.height)];
            [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerWillExitFullscreenNotification object:_player];
            _player.controlStyle = MPMovieControlStyleEmbedded;
        }
    }
    else{
        if(!_player.fullscreen){
            [_player.view setFrame:CGRectMake(0, ([UIScreen mainScreen].bounds.size.height-[UIScreen mainScreen].bounds.size.width*9.0/16.0)/2.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9.0/16.0)];
            [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerWillExitFullscreenNotification object:_player];
            _player.controlStyle = MPMovieControlStyleEmbedded;
        }
    }
}

-(void) getSubtitles:(NSNotification *)noti
{
    if([[noti.userInfo objectForKey:@"status"] boolValue]){
        _subtitleUrl=[noti.userInfo objectForKey:@"url"];
    }
    else{
        _subtitleUrl=@"";
    }
    //[self playMovieWithURL];
}


@end

//
//  MOOCMyCourseShow.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-13.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCMyCourseShow.h"
#import "MOOCConnection.h"

@interface MOOCMyCourseShow ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) NSTimer *subtitleTimer;
- (void)configureView;
@end

@implementation MOOCMyCourseShow

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_recvStr)
    {
        NSLog(@"%@",_recvStr);
        
        NSURL *url = [NSURL URLWithString:_recvStr];
        _recvStr = nil;
        [self playMovieWithURL:url];
        //[self playmoovie];
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

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem)
    {
        //self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mpWidth = [UIScreen mainScreen].bounds.size.width*5.0/6.0;
  
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    //nslog(@"%@",barButtonItem);
    barButtonItem.title = @"课程列表";
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    self.masterPopoverController = popoverController;
    //_popover = nil;
    _btn = barButtonItem;
    //NSLog(@"%@",viewController);
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
    //NSLog(@"%@",viewController);
}

//横屏隐藏master
-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}

- (void)playMovieWithURL:(NSURL *)url
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSubtitles:) name:sMOOCGetSubtitles object:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[MOOCConnection sharedInstance] MOOCGetSubtitles:_subtitlesUrl];
    });
    MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] init];
    mp.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    [mp.moviePlayer setContentURL:url];
    CGSize c = self.view.frame.size;
    mp.moviePlayer.controlStyle = MPMovieControlStyleDefault;
    mp.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
#warning 2014.11.27
    [mp.moviePlayer openSRTFileAtPath:_subtitlesUrl completion:^(BOOL finished) {[mp.moviePlayer showSubtitles];} failure:^(NSError *err){NSLog(@"%@",err);}];
    [mp.moviePlayer.view setFrame:CGRectMake((c.width-mpWidth)/2.0, (c.height-mpWidth*9/16.0)/2.0, mpWidth, mpWidth*9/16.0)];
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
            _player.controlStyle = MPMovieControlStyleFullscreen;
            [_subtitleLabel setFrame:CGRectMake(0, 0, window.frame.size.width-30.0, 100)];
            self.subtitleLabel.center = CGPointMake(window.frame.size.width/2.0,window.frame.size.height-30.0);
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
            _player.controlStyle = MPMovieControlStyleDefault;
            [_subtitleLabel setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(_player.view.bounds) - 30.0, 100.0)];
            self.subtitleLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(_player.view.bounds)+(CGRectGetHeight(self.view.bounds)-CGRectGetHeight(_player.view.bounds))/2.0- (CGRectGetHeight(self.subtitleLabel.bounds) / 2.0) - 10.0);
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
                self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(_player.view.bounds) - 30.0, 100.0)];
                self.subtitleLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(_player.view.bounds)+(CGRectGetHeight(self.view.bounds)-CGRectGetHeight(_player.view.bounds))/2.0- (CGRectGetHeight(self.subtitleLabel.bounds) / 2.0) - 10.0);
                self.subtitleLabel.backgroundColor = [UIColor clearColor];
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
        [_subtitleLabel setFrame:CGRectMake(0, 0, window.frame.size.width-30.0, 100)];
        self.subtitleLabel.center = CGPointMake(window.frame.size.width/2.0,window.frame.size.height-30.0);
        [window addSubview:_subtitleLabel];
    }
    else{
        [_subtitleLabel setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(_player.view.bounds) - 30.0, 100.0)];
        self.subtitleLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(_player.view.bounds)+(CGRectGetHeight(self.view.bounds)-CGRectGetHeight(_player.view.bounds))/2.0- (CGRectGetHeight(self.subtitleLabel.bounds) / 2.0) - 10.0);
        [self.view addSubview:self.subtitleLabel];
    }
    
}

-(void)getSubtitleText
{
    self.subtitleLabel.text=_player.subtitleLabel;
}

- (void)viewDidLayoutSubviews
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if ((orientation == UIInterfaceOrientationLandscapeLeft) || (orientation == UIInterfaceOrientationLandscapeRight))
        {
            [_lbl setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-408)/2.0, ([UIScreen mainScreen].bounds.size.height-54)/2.0, 408, 54)];
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            if (!window)
            {
                window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            }
            if(_player){
                [_player.view setFrame:CGRectMake(0,0,window.frame.size.width*3.0/4.0,window.frame.size.width*27.0/64.0)];
                _player.view.center=CGPointMake(window.frame.size.width/2.0, window.frame.size.height/2.0);
                if(_subtitleLabel){
                    [_subtitleLabel setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(_player.view.bounds) - 30.0, 100.0)];
                    self.subtitleLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(_player.view.bounds)+(CGRectGetHeight(self.view.bounds)-CGRectGetHeight(_player.view.bounds))/2.0- (CGRectGetHeight(self.subtitleLabel.bounds) / 2.0) - 10.0);
                }
            }
        }
        else
        {
            [_lbl setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-408)/2.0, ([UIScreen mainScreen].bounds.size.height-54)/2.0, 408, 54)];
            if(_player){
                CGSize c = self.view.frame.size;
                [_player.view setFrame:CGRectMake((c.width-mpWidth)/2.0, (c.height-mpWidth*9/16.0)/2.0, mpWidth, mpWidth*9/16.0)];
                if(_subtitleLabel){
                    [_subtitleLabel setFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(_player.view.bounds) - 30.0, 100.0)];
                    self.subtitleLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0, CGRectGetHeight(_player.view.bounds)+(CGRectGetHeight(self.view.bounds)-CGRectGetHeight(_player.view.bounds))/2.0- (CGRectGetHeight(self.subtitleLabel.bounds) / 2.0) - 10.0);
                }
            }
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight))
        {
            [_lbl setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-408)/2.0, ([UIScreen mainScreen].bounds.size.height-54)/2.0, 408, 54)];
            if(!_player.fullscreen){
                [_player pause];
                [_player.view setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-[UIScreen mainScreen].bounds.size.height*16.0/9.0)/2.0, 0, [UIScreen mainScreen].bounds.size.height*16.0/9.0, [UIScreen mainScreen].bounds.size.height)];
                [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerWillExitFullscreenNotification object:_player];
                _player.controlStyle = MPMovieControlStyleEmbedded;
            }
        }
        if ((toInterfaceOrientation == UIInterfaceOrientationPortrait) || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
        {
            [_lbl setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-408)/2.0, ([UIScreen mainScreen].bounds.size.height-54)/2.0, 408, 54)];
        }
        if (_player)
        {
            if (_player.fullscreen)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerWillEnterFullscreenNotification object:_player];
                _player.controlStyle = MPMovieControlStyleFullscreen;
            }
            else
            {
                [_player pause];
                [_player.view setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-[UIScreen mainScreen].bounds.size.height*16.0/9.0)/2.0, 0, [UIScreen mainScreen].bounds.size.height*16.0/9.0, [UIScreen mainScreen].bounds.size.height)];
                [[NSNotificationCenter defaultCenter] postNotificationName:MPMoviePlayerWillExitFullscreenNotification object:_player];
                _player.controlStyle = MPMovieControlStyleEmbedded;
            }
        }
    }
    else{
        if ((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight))
        {
            [_lbl setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-408)/2.0, ([UIScreen mainScreen].bounds.size.height-54)/2.0, 408, 54)];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id dest = segue.destinationViewController;
    if ([dest isKindOfClass:[MOOCQRCodeView class]])
    {
        MOOCQRCodeView *view = (MOOCQRCodeView *)dest;
        view.sourceView = self;
        //_popoverView = [(UIStoryboardPopoverSegue *)segue popoverController];
    }
}

-(void) getSubtitles:(NSNotification *)noti
{
    if([[noti.userInfo objectForKey:@"status"] boolValue]){
       _subtitlesUrl=[noti.userInfo objectForKey:@"url"];
    }
    else{
        _subtitlesUrl=@"";
    }
}

@end

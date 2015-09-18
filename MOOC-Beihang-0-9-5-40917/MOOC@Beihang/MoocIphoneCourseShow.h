//
//  MoocIphoneCourseShow.h
//  MOOC@Beihang
//
//  Created by 周萱 on 14/11/19.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MPMoviePlayerController+Subtitles.h"

@interface MoocIphoneCourseShow : UIViewController
{
    float mpWidth;
    float mpHeight;
    //MoocVideoActivityIndicator *prog;
    UIActivityIndicatorView *prog;
    UIView *progView;
    //BOOL *isReadyToPlay = false;
}
@property(nonatomic,assign)BOOL isHiddenStatusBar;
@property MPMoviePlayerController *player;
@property (nonatomic,strong) NSURL *movie_url;
@property NSString *recvStr;
@property (weak, nonatomic) IBOutlet UINavigationBar *aNavigationControllerBar;
@property NSString *subtitleUrl;

-(id)initWithUrl:(NSURL *)url;
-(void) playMovieWithUrl;
- (void)mpEnterFullscreen:(NSNotification *)noti;
- (void)mpExitFullscreen:(NSNotification *)noti;
- (void)receiveNotification:(NSNotification *)noti;
-(void)setUpUrl:(NSURL *)url;
- (IBAction)movieEnded:(id)sender;
@end

//
//  MOOCMyCourseShow.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-13.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MOOCQRCodeView.h"
#import "MPMoviePlayerController+Subtitles.h"


@interface MOOCMyCourseShow : UIViewController <UISplitViewControllerDelegate>
{
    float mpWidth;
}

//@property (strong, nonatomic) UIPopoverController *popover;
//@property (weak) UIPopoverController *popoverView;
@property (weak, nonatomic) IBOutlet UILabel *lbl;
@property (strong, nonatomic) id detailItem;
@property MPMoviePlayerController *player;
@property UIBarButtonItem *btn;
@property NSString *recvStr;
@property (strong,nonatomic) NSString *subtitlesUrl;

- (void)playMovieWithURL:(NSURL *)url;
- (void)mpEnterFullscreen:(NSNotification *)noti;
- (void)mpExitFullscreen:(NSNotification *)noti;
- (void)receiveNotification:(NSNotification *)noti;
- (void)drawSubtitle:(NSString *)sutitleText;
@end

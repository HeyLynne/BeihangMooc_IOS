//
//  MoocVideoActivityIndicator.m
//  MOOC@Beihang
//
//  Created by AdmireBeihang on 14/12/22.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MoocVideoActivityIndicator.h"

@implementation MoocVideoActivityIndicator
@synthesize isStop;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)init
{
    self = [super init];
    if (self)
    {
        self.isStop=FALSE;
        mpWidth=[UIScreen mainScreen].bounds.size.width*6.0/6.0;
        mpHeight=[UIScreen mainScreen].bounds.size.height;
        [self.view setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
        //[self.view ]
        prog = [[UIActivityIndicatorView alloc] init];
        prog.hidden = YES;
        prog.hidesWhenStopped = YES;
        [self.view addSubview:prog];
    }
    return self;
}

- (void)start
{
    //NSLog(@"start");
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
    prog.hidden = NO;
    [prog startAnimating];
}

- (void)stop
{
    self.isStop=TRUE;
    [self.view removeFromSuperview];
    [prog stopAnimating];
}

- (CGRect)_activityIndicatorView
{
    return CGRectMake(5, 5, 20, 20);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //CGRect bound = [UIScreen mainScreen].bounds;
    //[self.view setFrame:bound];
    [self.view setFrame:CGRectMake(mpWidth/2.0-15, mpHeight/2.0-15, 30, 30)];
    [prog setFrame:[self _activityIndicatorView]];
}

@end

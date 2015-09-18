//
//  MOOCActivityIndicator.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-24.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCActivityIndicator.h"

@implementation MOOCActivityIndicator

- (id)init
{
    self = [super init];
    if (self)
    {
        [self.view setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
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
    [self.view removeFromSuperview];
    [prog stopAnimating];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect bound = [UIScreen mainScreen].bounds;
    [self.view setFrame:bound];
    [prog setFrame:self.view.frame];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect bound = [UIScreen mainScreen].bounds;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [self.view setFrame:CGRectMake(0, 0, CGRectGetHeight(bound), CGRectGetWidth(bound))];
        
    }
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        [self.view setFrame:bound];
    }
    [prog setFrame:self.view.frame];
}
@end

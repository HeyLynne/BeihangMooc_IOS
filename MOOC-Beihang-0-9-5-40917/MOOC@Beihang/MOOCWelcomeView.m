//
//  MOOCWelcomeView.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-2.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCWelcomeView.h"

@interface MOOCWelcomeView ()
- (void)receiveNotification:(NSNotification *)noti;
@end

@implementation MOOCWelcomeView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isReceived = NO;
    [_prog startAnimating];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:sMOOCInitNotification object:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*0.5), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[MOOCConnection sharedInstance] MOOCInit];
    });
    /*
    [_label_title setText:@"北    航    学    堂"];
    [_label_title.font fontWithSize:80];
    [_btn.titleLabel.font fontWithSize:20];
    [_label_addr.font fontWithSize:20];
    [_label_bhsyssj.font fontWithSize:20];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            [_logo setFrame:CGRectMake(337, 37, 350, 350)];
            [_label_title setFrame:CGRectMake(232, 430, 560, 104)];
            [_prog setFrame:CGRectMake(502, 554, 20, 20)];
            [_label_bhsyssj setFrame:CGRectMake(329, 622, 206, 21)];
            [_btn setFrame:CGRectMake(607, 623, 88, 21)];
            [_label_addr setFrame:CGRectMake(213, 689, 599, 32)];
        
        }
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            [_logo setFrame:CGRectMake(184, 150, 400, 400)];
            [_label_title setFrame:CGRectMake(107, 650, 560, 104)];
            [_prog setFrame:CGRectMake(374, 810, 20, 20)];
            [_label_bhsyssj setFrame:CGRectMake(188, 887, 206, 21)];
            [_btn setFrame:CGRectMake(469, 888, 88, 21)];
            [_label_addr setFrame:CGRectMake(88, 942, 599, 32)];
        
        }
    }
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:duration];
            [_logo setFrame:CGRectMake(337, 37, 350, 350)];
            [_label_title setFrame:CGRectMake(232, 430, 560, 104)];
            [_prog setFrame:CGRectMake(502, 554, 20, 20)];
            [_label_bhsyssj setFrame:CGRectMake(329, 622, 206, 21)];
            [_btn setFrame:CGRectMake(607, 623, 88, 21)];
            [_label_addr setFrame:CGRectMake(213, 689, 599, 32)];
            [UIView commitAnimations];
        }
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:duration];
            [_logo setFrame:CGRectMake(184, 150, 400, 400)];
            [_label_title setFrame:CGRectMake(107, 650, 560, 104)];
            [_prog setFrame:CGRectMake(374, 810, 20, 20)];
            [_label_bhsyssj setFrame:CGRectMake(232, 887, 192, 21)];
            [_btn setFrame:CGRectMake(443, 889, 88, 21)];
            [_label_addr setFrame:CGRectMake(116, 942, 537, 32)];
            [UIView commitAnimations];
        }
    }
}

- (IBAction)aboutUs:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mooc.buaa.edu.cn/about"]];
}

- (void)receiveNotification:(NSNotification *)noti
{
    NSDate *date = [NSDate date];

    isReceived = YES;
    NSDictionary *recv = noti.userInfo;
    BOOL status = [[recv objectForKey:@"status"] boolValue];
    if (status)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_prog stopAnimating];
            [self performSegueWithIdentifier:@"welcometoLogin" sender:nil];
        });
    }
    else
    {
        NSLog(@"ErrorCode:%@ Error:%@",[recv objectForKey:@"statusCode"],[recv objectForKey:@"error"]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"网络错误" message:@"请检查网络后重新进入程序。" delegate:self cancelButtonTitle:@"重试" otherButtonTitles:nil] show];
        });
        
    }
    NSLog(@"Notification @MOOCWelcomeView complete, Elapsed Time: %f",[[NSDate date] timeIntervalSinceDate:date]);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[MOOCConnection sharedInstance] MOOCInit];
    });
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end

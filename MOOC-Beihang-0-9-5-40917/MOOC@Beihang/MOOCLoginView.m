//
//  MOOCLoginView.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-2.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCLoginView.h"
#import "MOOCActivityIndicator.h"

@interface MOOCLoginView ()
{
    MOOCConnection *conn;
    MOOCActivityIndicator *prog;
    NSUserDefaults *save;
    //UIView *grayview;
}
- (void)login;
- (void)startEditing;
- (void)endEditing;
- (void)receiveNotification:(NSNotification *)noti;
@end

@implementation MOOCLoginView

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
    conn = [[MOOCConnection alloc] init];
    prog = [[MOOCActivityIndicator alloc] init];
    save = [NSUserDefaults standardUserDefaults];
    fromInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    isEditing = NO;
    _txtPass.text = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:sMOOCLoginNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)anonyLogin:(id)sender
{
    [save setObject:@"0" forKey:@"isLogin"];
    [save synchronize];
    [self performSegueWithIdentifier:@"logintoMain" sender:self];
}

- (IBAction)regAccount:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mooc.buaa.edu.cn/register"]];
}


- (IBAction)exitPass:(id)sender
{
    [self resignFirstResponder];
    [self login];
}

- (IBAction)beginPass:(id)sender
{
    [self startEditing];
}

- (IBAction)endUser:(id)sender
{
    [_txtPass becomeFirstResponder];
}

- (IBAction)endPass:(id)sender
{
    [self endEditing];
}

- (IBAction)beginUser:(id)sender
{
    [self startEditing];
}

- (IBAction)exitUser:(id)sender
{
    [self endEditing];
}

- (IBAction)backTap:(id)sender
{
    [_txtUser resignFirstResponder];
    [_txtPass resignFirstResponder];
    [self endEditing];
}

- (IBAction)resign_txt:(id)sender {
    [self.txtPass resignFirstResponder];
    [self.txtUser resignFirstResponder];
    [self endEditing];
}

//下面两个应用至iPhone时需要更改

- (void)startEditing
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    fromInterfaceOrientation = orientation;
    isEditing = YES;
    if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
            if (self.view.frame.origin.x == 0)
            {
                CGRect frm = self.view.frame;
                frm.origin.x -= 350;
                frm.size.width += 350;
                self.view.frame = frm;
            }
        }
        else if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
            if (self.view.frame.origin.x == 0){
                CGRect frm = self.view.frame;
                frm.origin.x -= 146;
                frm.size.width += 146;
                self.view.frame=frm;
            }
        }
    }
    if (orientation == UIInterfaceOrientationLandscapeRight)
    {
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
            if (self.view.frame.size.width == [UIScreen mainScreen].bounds.size.width)
            {
                CGRect frm = self.view.frame;
                frm.size.width += 350;
                self.view.frame = frm;
            }
        }
        else if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
            if (self.view.frame.size.width == [UIScreen mainScreen].bounds.size.width){
            CGRect frm = self.view.frame;
            frm.size.width += 146;
            self.view.frame=frm;
            }
        }
    }
    if (orientation == UIInterfaceOrientationPortrait)
    {
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
            if (self.view.frame.origin.y == 0)
            {
                CGRect frm = self.view.frame;
                frm.origin.y -= 200;
                frm.size.height += 200;
                self.view.frame = frm;
            }
        }
        else if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
            if (self.view.frame.origin.y == 0){
            CGRect frm = self.view.frame;
            frm.origin.y-=110;
            frm.size.height+=110;
            self.view.frame=frm;
            }
        }
    }
    if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
            if (self.view.frame.size.height == [UIScreen mainScreen].bounds.size.height)
            {
                CGRect frm = self.view.frame;
                frm.size.height += 200;
                self.view.frame = frm;
            }
        }
        else if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
            if (self.view.frame.size.height == [UIScreen mainScreen].bounds.size.height){
            CGRect frm = self.view.frame;
            frm.size.height+=110;
            self.view.frame=frm;
            }
        }
    }
}

- (void)endEditing
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        fromInterfaceOrientation = orientation;
        isEditing = NO;
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            if (self.view.frame.origin.x != 0)
            {
                CGRect frm = self.view.frame;
                frm.origin.x += 350;
                frm.size.width -= 350;
                self.view.frame = frm;
            }
        }
        if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            if (self.view.frame.size.width != [UIScreen mainScreen].bounds.size.width)
            {
                CGRect frm = self.view.frame;
                frm.size.width -= 350;
                self.view.frame = frm;
            }
        }
        if (orientation == UIInterfaceOrientationPortrait)
        {
            if (self.view.frame.origin.y != 0)
            {
                CGRect frm = self.view.frame;
                frm.origin.y += 200;
                frm.size.height -= 200;
                self.view.frame = frm;
            }
        }
        if (orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            if (self.view.frame.size.height != [UIScreen mainScreen].bounds.size.height)
            {
                CGRect frm = self.view.frame;
                frm.size.height -= 200;
                self.view.frame = frm;
            }
        }
    }
    else{
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        fromInterfaceOrientation = orientation;
        isEditing = NO;
        if (orientation == UIInterfaceOrientationLandscapeLeft)
        {
            if (self.view.frame.origin.x != 0)
            {
                CGRect frm = self.view.frame;
                frm.origin.x += 220;
                frm.size.width -= 220;
                self.view.frame = frm;
            }
        }
        if (orientation == UIInterfaceOrientationLandscapeRight)
        {
            if (self.view.frame.size.width != [UIScreen mainScreen].bounds.size.width)
            {
                CGRect frm = self.view.frame;
                frm.size.width -= 220;
                self.view.frame = frm;
            }
        }
        if (orientation == UIInterfaceOrientationPortrait)
        {
            if (self.view.frame.origin.y != 0)
            {
                CGRect frm = self.view.frame;
                frm.origin.y += 110;
                frm.size.height -= 110;
                self.view.frame = frm;
            }
        }
        if (orientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            if (self.view.frame.size.height != [UIScreen mainScreen].bounds.size.height)
            {
                CGRect frm = self.view.frame;
                frm.size.height -= 110;
                self.view.frame = frm;
            }
        }

    }
}

- (void)login
{
    [prog start];
    NSString *user = [_txtUser text];
    NSString *pass = [_txtPass text];
    [_txtPass setText:@""];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[MOOCConnection sharedInstance] MOOCLogin:user Pass:pass];
    });
}

- (void)receiveNotification:(NSNotification *)noti
{
    NSDate *date = [NSDate date];
    dispatch_async(dispatch_get_main_queue(), ^{[prog stop];});
    NSDictionary *recv = noti.userInfo;
    BOOL status = [[recv objectForKey:@"status"] boolValue];
    if (status)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"logintoMain" sender:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:sMOOCLoginNotification object:nil];
        });
        [save setObject:@"1" forKey:@"isLogin"];
        [save synchronize];
    }
    else
    {
        NSLog(@"ErrorCode:%@ Error:%@",[recv objectForKey:@"statusCode"],[recv objectForKey:@"error"]);
        int code = [[recv objectForKey:@"statusCode"] intValue];
        if (code!=200)
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"网络错误" message:@"请检查网络后重新尝试登录。" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            });
        else
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"错误的用户名或密码" message:@"请检查是否输入有误，然后重试。" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
                _txtPass.text = @"";
            });
        [save setObject:@"0" forKey:@"isLogin"];
        [save synchronize];
    }
    NSLog(@"Notification @MOOCLoginView complete, Elapsed Time: %f",[[NSDate date] timeIntervalSinceDate:date]);
}

- (void)viewDidLayoutSubviews
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsLandscape(orientation))
        {
            [_logo setFrame:CGRectMake(337, 37, 350, 350)];
            [_label_user setFrame:CGRectMake(294, 471, 88, 30)];
            [_label_pass setFrame:CGRectMake(294, 551, 88, 30)];
            [_txtUser setFrame:CGRectMake(414, 471, 317, 30)];
            [_txtPass setFrame:CGRectMake(414, 551, 317, 30)];
            [_label_myzh setFrame:CGRectMake(321, 656, 101, 20)];
            [_btn_liulan setFrame:CGRectMake(419, 656, 42, 20)];
            [_label_wmdkchz setFrame:CGRectMake(459, 656, 144, 20)];
            [_btn_zhuce setFrame:CGRectMake(597, 657, 46, 20)];
            [_label_xinyonghu setFrame:CGRectMake(641, 656, 62, 20)];
        
        }
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            [_logo setFrame:CGRectMake(184, 150, 400, 400)];
            [_label_user setFrame:CGRectMake(166, 678, 88, 30)];
            [_label_pass setFrame:CGRectMake(166, 751, 88, 30)];
            [_txtUser setFrame:CGRectMake(286, 678, 317, 30)];
            [_txtPass setFrame:CGRectMake(286, 751, 317, 30)];
            [_label_myzh setFrame:CGRectMake(193, 863, 101, 20)];
            [_btn_liulan setFrame:CGRectMake(290, 863, 42, 20)];
            [_label_wmdkchz setFrame:CGRectMake(331, 863, 144, 20)];
            [_btn_zhuce setFrame:CGRectMake(469, 864, 46, 20)];
            [_label_xinyonghu setFrame:CGRectMake(513, 863, 62, 20)];
        }
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            [_logo setFrame:CGRectMake(337, 37, 350, 350)];
            [_label_user setFrame:CGRectMake(294, 471, 88, 30)];
            [_label_pass setFrame:CGRectMake(294, 551, 88, 30)];
            [_txtUser setFrame:CGRectMake(414, 471, 317, 30)];
            [_txtPass setFrame:CGRectMake(414, 551, 317, 30)];
            [_label_myzh setFrame:CGRectMake(321, 656, 101, 20)];
            [_btn_liulan setFrame:CGRectMake(419, 656, 42, 20)];
            [_label_wmdkchz setFrame:CGRectMake(459, 656, 144, 20)];
            [_btn_zhuce setFrame:CGRectMake(597, 657, 46, 20)];
            [_label_xinyonghu setFrame:CGRectMake(641, 656, 62, 20)];
        }
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
        {
            [_logo setFrame:CGRectMake(184, 150, 400, 400)];
            [_label_user setFrame:CGRectMake(166, 678, 88, 30)];
            [_label_pass setFrame:CGRectMake(166, 751, 88, 30)];
            [_txtUser setFrame:CGRectMake(286, 678, 317, 30)];
            [_txtPass setFrame:CGRectMake(286, 751, 317, 30)];
            [_label_myzh setFrame:CGRectMake(193, 863, 101, 20)];
            [_btn_liulan setFrame:CGRectMake(290, 863, 42, 20)];
            [_label_wmdkchz setFrame:CGRectMake(331, 863, 144, 20)];
            [_btn_zhuce setFrame:CGRectMake(469, 864, 46, 20)];
            [_label_xinyonghu setFrame:CGRectMake(513, 863, 62, 20)];
        }
        if (isEditing)
        {
            if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
                self.view.frame = CGRectMake(-350, 0, 1118, 1024);
            if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
                self.view.frame = CGRectMake(0, 0, 1118, 1024);
            if (toInterfaceOrientation == UIInterfaceOrientationPortrait)
                self.view.frame = CGRectMake(0, -200, 768, 1224);
            if (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
                self.view.frame = CGRectMake(0, 0, 768, 1224);
        }
    }
}

//固定屏幕方向
-(NSUInteger)supportedInterfaceOrientations
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        return UIInterfaceOrientationMaskPortrait;
    }
    else
        return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}
@end

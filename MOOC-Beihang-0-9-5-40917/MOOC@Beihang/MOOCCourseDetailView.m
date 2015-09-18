//
//  MOOCCourseDetailView.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-7.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCCourseDetailView.h"
#import "MOOCMyCourseSplitView.h"
#import "MOOCMyCourseShow.h"
#import "MOOCForumDiscussion.h"

@interface MOOCCourseDetailView ()

- (void)receiveNotification:(NSNotification *)noti;
-(void)backToIndex;

@end

@implementation MOOCCourseDetailView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _name.text = @"全力打造具有中部地区特征的江西共青团工作新格局并团结带领团员青年在鄱阳湖生态经济区建设中发挥生力军作用";
    _img.image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"0" ofType:@"JPG"]];

    
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backToIndex)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    prog = [[MOOCActivityIndicator alloc] init];
    information = [[MOOCCourseData sharedInstance] getCourseData:_courseid withSections:NO];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    _name.text = [information objectForKey:@"course_title"];
    _num.text = [information objectForKey:@"display_number"];
    NSDate *start_time = [information objectForKey:@"course_start"];
    _starttime.text = [formatter stringFromDate:start_time];
    _stoptime_label.hidden = YES;
    _stoptime.hidden = YES;
    [_courseintro loadHTMLString:[information objectForKey:@"about"] baseURL:nil];
    NSString *imgAddr = [information objectForKey:@"course_image"];
    if (imgAddr)
        _img.image = [UIImage imageWithContentsOfFile:imgAddr];
    else
        _img.image = [UIImage imageNamed:@"buaa_logo.png"];
    isSelected = [[information objectForKey:@"registered"] boolValue];
    isFull = [[information objectForKey:@"is_full"] boolValue];
    if (isSelected)
    {
        [_choose setTitle:@"前往课程" forState:UIControlStateNormal];
        //[_choose setEnabled:NO];
        //[_choose setBackgroundColor:[UIColor grayColor]];
    }
    else
    {
        if (isFull)
        {
            [_choose setTitle:@"抱歉，人数已满" forState:UIControlStateNormal];
            [_choose setEnabled:NO];
            [_choose setBackgroundColor:[UIColor grayColor]];
        }
        else
            [_choose setTitle:(isSelected?@"退课":@"选课") forState:UIControlStateNormal];
        //[_choose setEnabled:NO];
        //[_choose setBackgroundColor:[UIColor grayColor]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:sMOOCCourseEnrollNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetect:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:tapGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view.window removeGestureRecognizer:tapGesture];
    tapGesture = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)tapDetect:(UITapGestureRecognizer *)sender
{
    //nslog(@"%d",sender.state);
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint p = [sender locationInView:nil];
        if (![self.view pointInside:[self.view convertPoint:p fromView:self.view.window] withEvent:nil])
        {
            [self.view.window removeGestureRecognizer:sender];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (IBAction)chooseCourse:(id)sender
{
    [prog start];
    if (isSelected)
    {
        //在选课的前提下，如果是ipad则执行以下操作
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
            //前往课程
        [self dismissViewControllerAnimated:YES completion:nil];
        [_mainView setSelectedIndex:0];
        UIBarButtonItem *targetBtn = _mainView.mView.show.btn;
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
            [targetBtn.target performSelector:targetBtn.action withObject:targetBtn];
        [prog stop];
        }
        //在选课的前提下如果是iphone得情况
        else{
            //[self.navigationController popViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            [_mainView setSelectedIndex:0];//tabView
            MOOCMyCourseSplitView *courseMainView=_mainView.mView;//splitView
            MOOCMyCourseList *courseListView=courseMainView.list;
            [courseListView.navigationController popToRootViewControllerAnimated:YES];
            [prog stop];
        }
    }
    else
    {
        //选课
        NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
        if(![[save objectForKey:@"isLogin"] boolValue])
        {
            //登陆
            [prog stop];
            [self dismissViewControllerAnimated:YES completion:^{
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[MOOCConnection sharedInstance] MOOCCourseEnroll:_courseid action:(isSelected?MOOCCourseUnEnroll:MOOCCourseEnroll)];
            });
        }
    }
}

- (IBAction)returnToCourse:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toForumDiscussion:(id)sender {
    if(isSelected){
        if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
            [self performSegueWithIdentifier:@"courseToForum" sender:_courseid];
        }
    }
    else{
         NSUserDefaults *save = [NSUserDefaults standardUserDefaults];
        if(![[save objectForKey:@"isLogin"] boolValue])
        {
            //登陆
            [self dismissViewControllerAnimated:YES completion:^{
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else{
            [[[UIAlertView alloc] initWithTitle:@"请先选课" message:@"您还未选课，请先选课" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
        }
    }
}

- (void)receiveNotification:(NSNotification *)noti
{
    NSDate *date = [NSDate date];
    dispatch_async(dispatch_get_main_queue(), ^{[prog stop];});
    NSDictionary *dict = noti.userInfo;
    if ([[dict objectForKey:@"status"] boolValue])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[dict objectForKey:@"registered"] boolValue])
            {
                isSelected = YES;
                [self chooseCourse:[dict objectForKey:sMOOCCourseID]];
            }
            else
            {
                isSelected = NO;
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        });
    }
    else
    {
        NSDictionary *recv = noti.userInfo;
        NSLog(@"ErrorCode:%@ Error:%@",[recv objectForKey:@"statusCode"],[recv objectForKey:@"error"]);
        int code = [[recv objectForKey:@"statusCode"] intValue];
        if (code!=200)
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"网络错误" message:@"请检查网络后重试。" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
            });
    }
    NSLog(@"Notification @MOOCCourseDetailView complete, Elapsed Time: %f",[[NSDate date] timeIntervalSinceDate:date]);
}

-(void) backToIndex
{
    self.navigationController.navigationBar.hidden=NO;
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL) shouldAutorotate{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone){
        return NO;
    }
    else
        return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"courseToForum"]){
        //UIViewController *view;
        UINavigationController *navi=[segue destinationViewController];
        MOOCForumDiscussion *view=[navi.viewControllers objectAtIndex:0];
        view.cid=_courseid;
    }
}
@end

//
//  MOOCCourseView.m
//  MOOC@Beihang
//
//  Created by Satte on 14-8-6.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCCourseView.h"
#import "MOOCCourseViewCell.h"
#import "MOOCCourseDetailView.h"
#import "MOOCActivityIndicator.h"
#import "MOOCConnection.h"

static BOOL isAlertViewExist;

@interface MOOCCourseView ()
{
    MOOCActivityIndicator *prog;
    MOOCConnection *conn;
    NSUserDefaults *save;
    //BOOL iscourseview ;
}
- (void)receiveNotificationFromCourse:(NSNotification *)noti;
- (void)receiveNotificationFromImage:(NSNotification *)noti;
@end

@implementation MOOCCourseView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    //iscourseview=false;
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isAlertViewExist = NO;
    _collectionArr = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationFromCourse:) name:sMOOCCourseNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationFromImage:) name:sMOOCGetImageNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    //iscourseview=true;
    prog = [[MOOCActivityIndicator alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[MOOCConnection sharedInstance] MOOCCourses];
    });
    [prog start];
    if (_recvStr)
    {
        NSLog(@"%@",_recvStr);
        _recvStr = nil;
    }
}


/*
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}
*/
//此处：从服务器获取课程信息后创建课程数组，标号，segue传数据时根据编号判断课程

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    //nslog(@"%lu",(unsigned long)[_collectionArr count]);
    return [_collectionArr count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    MOOCCourseViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"coursecell" forIndexPath:indexPath];
    NSDictionary *dict = [_collectionArr objectAtIndex:indexPath.row];
    //NSLog(@"Get course %@",[dict objectForKey:sMOOCCourseID]);
    cell.courseid = indexPath.row;
    cell.label.text = [dict objectForKey:@"course_title"];
    cell.layer.borderWidth=0.7f;
    cell.layer.borderColor=[[UIColor alloc]initWithWhite:0.5 alpha:0.7].CGColor;
    NSString *imgPath = [dict objectForKey:@"course_image"];
    NSLog(@"imgPath-:%@",imgPath);
    if (imgPath)
    {
        [imgPath stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (![imgPath isEqualToString:@""])
            cell.image.image = [UIImage imageWithContentsOfFile:imgPath];
        else
            cell.image.image = [UIImage imageNamed:@"buaa_logo.png"];
    }
    else
        cell.image.image = [UIImage imageNamed:@"buaa_logo.png"];
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"coursetoDetail"])
    {
        MOOCCourseDetailView *dest = [segue destinationViewController];
        MOOCCourseViewCell *t = (MOOCCourseViewCell *)sender;
        dest.courseid = [[_collectionArr objectAtIndex:t.courseid] objectForKey:sMOOCCourseID];
        dest.mainView = (MOOCMainView *)self.tabBarController;
        //NSLog(@"%@",self.tabBarController);
    }
    id dest = segue.destinationViewController;
    if ([dest isKindOfClass:[MOOCQRCodeView class]])
    {
        MOOCQRCodeView *view = (MOOCQRCodeView *)dest;
        view.sourceView = self;
        //_popoverView = [(UIStoryboardPopoverSegue *)segue popoverController];
    }
}

- (void)receiveNotificationFromCourse:(NSNotification *)noti
{
    NSDate *date = [NSDate date];
    if ([[noti.userInfo objectForKey:@"status"] boolValue])
    {
        _collectionArr = [NSMutableArray arrayWithArray:[[MOOCCourseData sharedInstance] getCourseData]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
        for (NSDictionary *dict in _collectionArr)
        {
            NSString *courseID = [dict objectForKey:sMOOCCourseID];
            NSString *imagePath = [dict objectForKey:@"course_image_url"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[MOOCConnection sharedInstance] MOOCGetImage:courseID imagePath:imagePath];
            });
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[MOOCConnection sharedInstance] MOOCCourseAbout:courseID];
            });
        }
    }
    else
    {
        NSDictionary *recv = noti.userInfo;
        NSLog(@"ErrorCode:%@ Error:%@",[recv objectForKey:@"statusCode"],[recv objectForKey:@"error"]);
        int code = [[recv objectForKey:@"statusCode"] intValue];
        if (code!=200)
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!isAlertViewExist)
                {
                    [[[UIAlertView alloc] initWithTitle:@"网络错误" message:@"请检查网络后尝试刷新本页面。" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
                    isAlertViewExist = YES;
                }
            });
    }
    NSLog(@"Course Notification @MOOCCourseView OK, Elapsed Time: %f",[[NSDate date] timeIntervalSinceDate:date]);
    dispatch_async(dispatch_get_main_queue(), ^{[prog stop];});
}

- (void)receiveNotificationFromImage:(NSNotification *)noti
{
    NSDate *date = [NSDate date];
    NSDictionary *dict = noti.userInfo;
    if ([[dict objectForKey:@"status"] boolValue])
    {
        NSDictionary *recv = [[MOOCCourseData sharedInstance] getCourseData:[dict objectForKey:sMOOCCourseID] withSections:NO];
        int index = -1;
        for (NSDictionary *d in _collectionArr)
        {
            if ([[d objectForKey:sMOOCCourseID] isEqualToString:[dict objectForKey:sMOOCCourseID]])
            {
                index = [_collectionArr indexOfObject:d];
            }
        }
        if ((index+1))
        {
            [_collectionArr replaceObjectAtIndex:index withObject:recv];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
    NSLog(@"Image Notification @MOOCCourseView OK, Elapsed Time: %f",[[NSDate date] timeIntervalSinceDate:date]);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:NO completion:nil];
    isAlertViewExist = NO;
}
// 获取当前view的viewController
-(BOOL) is_viewController
{    if([self.view isKindOfClass:[MOOCCourseView class]])
        return true;
    else
        return false;
}
@end

//
//  MOOCForumDetails.m
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/5/6.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import "MOOCForumDetails.h"
#import "MOOCConnection.h"
#import "MOOCCommentDetails.h"
#import "MOOCReplyTheThread.h"

@interface MOOCForumDetails ()
{
    BOOL isProgAnimated;
    int comment_count;
}

@end

@implementation MOOCForumDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"讨论详情";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFromCreateCommentAlready:) name:sMOOCCreateCommentAlready object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isProgAnimated=YES;
    _user_info=[_discussionContent objectForKey:@"user_info"];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *create_time=[formatter dateFromString:[_discussionContent objectForKey:@"created_at"]];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    _creatTimeLabel.text=[formatter stringFromDate:create_time];
    _titleLabel.text=[_discussionContent objectForKey:@"title"];
    _authorLabel.text=[_discussionContent objectForKey:@"username"];
    NSString *comment_count_s=[_discussionContent objectForKey:@"comments_count"];
    comment_count=[comment_count_s intValue];
    //comment_count=(NSInteger *)[_discussionContent objectForKey:@"comments_count"];
    _commentBar.title=[NSString stringWithFormat:@"回复(%d)",comment_count];
    [_bodyWebView loadHTMLString:[_discussionContent objectForKey:@"body"] baseURL:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"toCommentDetails"]){
        MOOCCommentDetails *view=[segue destinationViewController];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        [dict setObject:[_discussionContent objectForKey:@"course_id"] forKey:@"course_id"];
        [dict setObject:[_discussionContent objectForKey:@"discussion_id"] forKey:@"discussion_id"];
        [dict setObject:[_discussionContent objectForKey:@"thread_id"] forKey:@"thread_id"];
        view.requstInfo=dict;
        view.user_id=[_discussionContent objectForKey:@"user_id"];
        view.user_info=_user_info;
    }
    else if([[segue identifier] isEqualToString:@"toAddReplyToThreads"]){
        MOOCReplyTheThread *view=[segue destinationViewController];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        [dict setObject:[_discussionContent objectForKey:@"course_id"] forKey:@"course_id"];
        [dict setObject:[_discussionContent objectForKey:@"thread_id"] forKey:@"thread_id"];
        view.requestInfo=dict;
        
    }
}

- (IBAction)getCommentDetails:(id)sender {
    [self performSegueWithIdentifier:@"toCommentDetails" sender:self];
}

- (IBAction)addComment:(id)sender {
    if([[_discussionContent objectForKey:@"can_reply"] boolValue]){
        [self performSegueWithIdentifier:@"toAddReplyToThreads" sender:self];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"评论权限提示" message:@"讨论帖被设置为不能回复，您不能回复该讨论帖" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil]show];
        });
    }
}


-(void) receiveFromCreateCommentAlready:(NSNotification *)noti
{
    comment_count=comment_count+1;
    NSString *a=[[NSString alloc] initWithFormat:@"%d",comment_count];
    [_discussionContent setObject:a forKey:@"comments_count"];
}

@end

//
//  MOOCReplyAComment.m
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/9/28.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import "MOOCReplyAComment.h"

@interface MOOCReplyAComment ()
@property MoocVideoActivityIndicator *prog;
@end

@implementation MOOCReplyAComment

- (void)viewDidLoad {
    [super viewDidLoad];
    _inputText.delegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_inputText resignFirstResponder];
}

-(BOOL)textViewDidBeginEditing:(UITextView *)textView
{
    if(textView==_inputText){
        return YES;
    }
    return NO;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if(textView==_inputText){
        [_inputText resignFirstResponder];
    }
}

- (IBAction)cancleAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)okAction:(id)sender {
    [_inputText resignFirstResponder];
    if ([[_inputText text] length]==0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"输入有误" message:@"输入不能为空" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
        });
    }
    else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationFromReplyAComment:) name:sMOOCReplyAComment object:nil];
        NSString *inputInfo=[_inputText text];
        [_postInfo setObject:inputInfo forKey:@"body"];
        _prog=[[MoocVideoActivityIndicator alloc] init];
        [_prog start];
        [[MOOCConnection sharedInstance] MOOCReplyAComment:_postInfo];
    }
}

-(void)receiveNotificationFromReplyAComment:(NSNotification *)noti
{
    NSDate *date=[NSDate date];
    if([[noti.userInfo objectForKey:@"status"] boolValue]){
        [_prog stop];
        [[NSNotificationCenter defaultCenter] postNotificationName:sMOOCReplyCommentAlready object:[noti.userInfo objectForKey:@"status"]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [_prog stop];
        NSDictionary *recv=noti.userInfo;
        NSLog(@"ErrorCode:%@ Error:%@",[recv objectForKey:@"statusCode"],[recv objectForKey:@"error"]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"网络问题" message:@"您的网络有问题清稍后再试" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
        });
    }
    NSLog(@"Get Reply to the comment complete,Elapsed time: %f",[[NSDate date] timeIntervalSinceDate:date]);
}
@end

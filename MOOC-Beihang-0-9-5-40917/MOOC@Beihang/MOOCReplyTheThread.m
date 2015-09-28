//
//  MOOCReplyTheComment.m
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/5/10.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import "MOOCReplyTheThread.h"
#import "MoocVideoActivityIndicator.h"
#import "MOOCConnection.h"

@interface MOOCReplyTheThread ()
//@property (strong,nonatomic) NSString *inputString;
@property MoocVideoActivityIndicator *prog;
@end

@implementation MOOCReplyTheThread

- (void)viewDidLoad {
    [super viewDidLoad];
    _inputText.delegate=self;
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationFromCreateAComment:) name:sMOOCCreateAComment object:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_inputText resignFirstResponder];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if(textView==_inputText){
        return  YES;
    }
    return NO;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if(textView==_inputText){
        [_inputText resignFirstResponder];
    }
}

- (IBAction)cancleAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)okAction:(id)sender {
    [_inputText resignFirstResponder];
   // NSLog(@"%@",_inputText.text);
    if ([[_inputText text] length]==0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"输入有误" message:@"输入不能为空" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
        });
    }
    else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotificationFromCreateAComment:) name:sMOOCCreateAComment object:nil];
        [_requestInfo setObject:[_inputText text] forKey:@"body"];
        _prog=[[MoocVideoActivityIndicator alloc] init];
        [_prog start];
        [[MOOCConnection sharedInstance] MOOCCreateAComment:_requestInfo];
    }
}

-(void)receiveNotificationFromCreateAComment:(NSNotification *)noti
{
    NSDate *date=[NSDate date];
    if([[noti.userInfo objectForKey:@"status"] boolValue]){
        [_prog stop];
        [[NSNotificationCenter defaultCenter] postNotificationName:sMOOCCreateCommentAlready object:[noti.userInfo objectForKey:@"status"]];
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
    NSLog(@"Get Add new comment complete,Elapsed time: %f",[[NSDate date] timeIntervalSinceDate:date]);
}
@end

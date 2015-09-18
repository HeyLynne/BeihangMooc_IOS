//
//  MOOCaddTheThread.m
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/5/11.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import "MOOCaddTheThread.h"
#import "MoocVideoActivityIndicator.h"
#import "MOOCConnection.h"

@interface MOOCaddTheThread ()
@property (strong,nonatomic) MoocVideoActivityIndicator *prog;
@end

@implementation MOOCaddTheThread

- (void)viewDidLoad {
    [super viewDidLoad];
    _titleText.delegate=self;
    _contentText.delegate=self;
    _titleText.layer.borderWidth=1.0;
    _titleText.layer.borderColor=[[UIColor colorWithWhite:0.5 alpha:0.5] CGColor];
    _contentText.layer.borderColor=[[UIColor colorWithWhite:0.5 alpha:0.5] CGColor];
    _contentText.layer.borderWidth=1.0;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if(textView == _contentText || textView == _titleText){
        return  YES;
    }
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancleAction:(id)sender {
    [_titleText resignFirstResponder];
    [_contentText resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)okAction:(id)sender {
    [_titleText resignFirstResponder];
    [_contentText resignFirstResponder];
    if([_titleText.text length] == 0 || [_contentText.text length] == 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"输入有误" message:@"输入不能为空" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil] show];
        });
    }
    else{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFromAddThread:) name:sMOOCCreateAThread object:nil];
        [_recvInfo setObject:[_titleText text] forKey:@"title"];
        [_recvInfo setObject:[_contentText text] forKey:@"body"];
        _prog=[[MoocVideoActivityIndicator alloc] init];
        [_prog start];
        [[MOOCConnection sharedInstance] MOOCCreateAThread:_recvInfo];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(_prog){
        [_prog stop];
    }
}

-(void)receiveFromAddThread:(NSNotification *)noti
{
    NSDate *date=[NSDate date];
    if([[noti.userInfo objectForKey:@"status"] boolValue]){
        [_prog stop];
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:sMOOCCreateThreadAlready object:nil];
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

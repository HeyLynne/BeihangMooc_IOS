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
        NSString *inputInfo=[_inputText text];
        _prog=[[MoocVideoActivityIndicator alloc] init];
        [_prog start];
    }
}
@end

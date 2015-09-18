//
//  MOOCReplyTheComment.h
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/5/10.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOOCReplyTheThread: UIViewController<UITextViewDelegate,UIAlertViewDelegate>
@property (strong,nonatomic) NSMutableDictionary *requestInfo;
- (IBAction)cancleAction:(id)sender;
- (IBAction)okAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *inputText;

@end

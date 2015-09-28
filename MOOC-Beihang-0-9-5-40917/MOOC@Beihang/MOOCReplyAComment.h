//
//  MOOCReplyAComment.h
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/9/28.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoocVideoActivityIndicator.h"
#import "MOOCConnection.h"

@interface MOOCReplyAComment : UIViewController<UITextViewDelegate,UIAlertViewDelegate>
@property(strong,nonatomic) NSMutableDictionary *postInfo;
- (IBAction)cancleAction:(id)sender;
- (IBAction)okAction:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *inputText;

@end

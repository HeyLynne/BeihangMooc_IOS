//
//  MOOCaddTheThread.h
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/5/11.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOOCaddTheThread : UIViewController<UIAlertViewDelegate,UITextViewDelegate>
- (IBAction)cancleAction:(id)sender;
- (IBAction)okAction:(id)sender;

@property (strong,nonatomic) NSMutableDictionary *recvInfo;
@property (weak, nonatomic) IBOutlet UITextView *titleText;
@property (weak, nonatomic) IBOutlet UITextView *contentText;

@end

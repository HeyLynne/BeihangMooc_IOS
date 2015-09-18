//
//  MOOCForumDetails.h
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/5/6.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOOCForumDetails : UIViewController<UIAlertViewDelegate>
@property (strong,nonatomic) NSMutableDictionary *discussionContent;
@property (strong,nonatomic) NSMutableDictionary *user_info;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIWebView *bodyWebView;
@property (weak, nonatomic) IBOutlet UILabel *creatTimeLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *commentBar;
- (IBAction)getCommentDetails:(id)sender;
- (IBAction)addComment:(id)sender;

@end

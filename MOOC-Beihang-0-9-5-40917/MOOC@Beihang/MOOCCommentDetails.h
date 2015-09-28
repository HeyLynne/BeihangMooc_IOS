//
//  MOOCCommentDetails.h
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/5/7.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOOCReplyAComment.h"

@interface MOOCCommentDetails : UITableViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UIActionSheetDelegate>
@property (strong,nonatomic) NSMutableDictionary* requstInfo;
@property (strong,nonatomic) NSMutableDictionary *user_info;
@property (strong,nonatomic) NSMutableArray *comments;
@property (strong,nonatomic) NSString *user_id;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *prog;

@end

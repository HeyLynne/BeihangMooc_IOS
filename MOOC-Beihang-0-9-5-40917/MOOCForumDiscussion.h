//
//  MOOCForumDiscussion.h
//  MOOC@Beihang
//
//  Created by buaaAdmire on 15/4/24.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOOCForumDiscussion : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
- (IBAction)dismissButtonAction:(id)sender;
- (IBAction)addAThread:(id)sender;

@property(nonatomic,strong) NSMutableArray *discussions;
@property(nonatomic,strong) NSString *cid;
@property(nonatomic,strong) NSMutableDictionary *user_info;

@end

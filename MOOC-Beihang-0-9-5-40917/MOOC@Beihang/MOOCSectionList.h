//
//  MOOCSectionList.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-25.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MOOCSectionList : UITableViewController <UITableViewDelegate, UITableViewDataSource>
@property NSDictionary *courseInfo;
@property NSArray *sectionList;
@property (strong,nonatomic) NSString *courseId;
@end

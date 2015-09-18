//
//  MOOCMyCourseList.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-13.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOOCActivityIndicator.h"

@interface MOOCMyCourseList : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@property NSMutableArray *course;
@property NSArray *self_views;

- (void)refreshCourse;
@end

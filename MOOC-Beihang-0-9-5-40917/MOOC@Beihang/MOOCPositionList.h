//
//  MOOCPositionList.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-25.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoocIphoneCourseShow.h"
#import "MOOCUrlProcessing.h"

@interface MOOCPositionList : UITableViewController <UITableViewDelegate, UITableViewDataSource,NSURLSessionDownloadDelegate>

@property NSDictionary *courseInfo;
@property NSArray *videoList;

//@property NSDictionary *section;
//@property NSMutableArray *videoList;
@end

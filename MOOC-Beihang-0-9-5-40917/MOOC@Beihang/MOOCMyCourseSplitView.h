//
//  MOOCMyCourseSplitView.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-17.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOOCMyCourseList.h"
#import "MOOCMyCourseShow.h"

@interface MOOCMyCourseSplitView : UISplitViewController

@property MOOCMyCourseList *list;
@property MOOCMyCourseShow *show;

@end
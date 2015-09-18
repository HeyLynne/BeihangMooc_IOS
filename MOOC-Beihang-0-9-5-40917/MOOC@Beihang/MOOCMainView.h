//
//  MOOCMainView.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-20.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOOCMyCourseSplitView.h"
#import "MOOCCourseView.h"
#import "MOOCSettingView.h"

@interface MOOCMainView : UITabBarController <UITabBarControllerDelegate>

@property MOOCMyCourseSplitView *mView;
@property MOOCCourseView *cView;
@property MOOCSettingView *sView;

- (void)switchViewTo:(int)index;

@end

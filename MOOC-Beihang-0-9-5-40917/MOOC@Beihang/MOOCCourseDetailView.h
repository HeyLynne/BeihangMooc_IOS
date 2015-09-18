//
//  MOOCCourseDetailView.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-7.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOOCMainView.h"
#include "MOOCCourseData.h"
#include "MOOCConnection.h"
#import "MOOCMyCourseList.h"

@interface MOOCCourseDetailView : UIViewController<UIAlertViewDelegate>
{
    BOOL isSelected;
    BOOL isFull;
    NSDateFormatter *formatter;
    NSDictionary *information;
    MOOCActivityIndicator *prog;
    UITapGestureRecognizer *tapGesture;
}
- (void)tapDetect:(UITapGestureRecognizer *)sender;
- (IBAction)chooseCourse:(id)sender;
- (IBAction)returnToCourse:(id)sender;
- (IBAction)toForumDiscussion:(id)sender;


@property (nonatomic, retain) NSString *courseid;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *num;
@property (weak, nonatomic) IBOutlet UILabel *starttime;
@property (weak, nonatomic) IBOutlet UILabel *stoptime;
@property (weak, nonatomic) IBOutlet UILabel *stoptime_label;
@property (weak, nonatomic) IBOutlet UIButton *choose;
@property MOOCMainView *mainView;
@property (weak, nonatomic) IBOutlet UIWebView *courseintro;

@end

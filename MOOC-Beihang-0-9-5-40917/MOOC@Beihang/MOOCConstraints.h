//
//  NSObject_MOOCConstraints_h.h
//  MOOC@Beihang
//
//  Created by Satte on 14-9-9.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define Target_URL "http://mooc.buaa.edu.cn"
#define Target_URL "http://10.2.13.251"
//#define Target_URL_Pattern "http://www.mooc.buaa.edu.cn/"
#define Target_URL_Pattern "http://10.2.13.251/"
//#define Target_URL_Domain "www.mooc.buaa.edu.cn"
#define Target_URL_Domain "10.2.13.251"
#define Target_URL_Domain_Without_WWW "10.2.13.251"
//#define Target_URL_Domain_Without_WWW "mooc.buaa.edu.cn"
#define Target_Path "/mobile_api/"


static NSString *const sMOOCInitNotification = @"init";
static NSString *const sMOOCLoginNotification = @"login";
static NSString *const sMOOCCourseNotification = @"course";
static NSString *const sMOOCCourseAboutNotification = @"about";
static NSString *const sMOOCCourseWareNotification = @"ware";
static NSString *const sMOOCCourseEnrollNotification = @"enroll";
static NSString *const sMOOCGetCourseEnrollmentNotification = @"enrollment";
static NSString *const sMOOCGetImageNotification = @"image";
static NSString *const sMOOCCourseID = @"course_id";
static NSString *const sMOOCIsValid = @"isValid";
static NSString *const sMOOCIsValidDate = @"isValidDate";
static NSString *const sMOOCDatebaseIsValid = @"is_valid";
static NSString *const sMOOCGetSubtitles=@"sutitles";
static NSString *const sMoocGetSubtitlesIphone=@"iphone_subtitles";
static NSString *const sMOOCGetForumDiscussionData=@"discussion_forum";
static NSString *const sMOOCGetPageForum=@"discussion_page";
static NSString *const sMOOCGetDiscussionDetails=@"discussion_detail";
static NSString *const sMOOCReplyToTheComment=@"reply_the_comment";
static NSString *const sMOOCCreateAComment=@"reply_the_thread";
static NSString *const sMOOCCreateAThread=@"create_a_thread";
static NSString *const sMOOCCreateCommentAlready=@"comment_already";
static NSString *const sMOOCCreateThreadAlready=@"thready_already";
static NSString *const sMOOCReplyAComment=@"reply_a_comment";
static NSString *const sMOOCReplyCommentAlready=@"reply_comment_already";



static int const iMOOCValidTime = 300;
static int const iMOOCRequestTimeOut = 1000;
static int const iMOOCRequestTimeOutDownload = 1500;


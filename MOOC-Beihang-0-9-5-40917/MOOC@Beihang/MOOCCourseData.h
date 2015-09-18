//
//  MOOCCourseData.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-31.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "MOOCDatabaseCourse.h"
#import "MOOCDatabaseUser.h"

@interface MOOCCourseData : NSObject
{
    AppDelegate *appDelegate;
    NSLock *lock;
    NSManagedObjectContext *context;
    NSDateFormatter *format;
    dispatch_queue_t queue;
}

+ (id)sharedInstance;
- (BOOL)insertCourseWithData:(NSDictionary *)dict;
- (BOOL)insertUserInfoWithData:(NSDictionary *)dict;
- (NSArray *)getCourseData;
- (NSDictionary *)getCourseData:(NSString *)cid withSections:(BOOL)section;
- (NSDictionary *)getUserInfo;
- (BOOL)updateCourse:(NSString *)cid withData:(NSDictionary *)dict;
- (BOOL)updateUserInfoWithData:(NSDictionary *)dict;
- (BOOL)deleteCourse:(NSString *)cid;
- (BOOL)deleteUserInfo;
- (BOOL)checkValid;
- (BOOL)checkValid:(NSString *)cid;

@end

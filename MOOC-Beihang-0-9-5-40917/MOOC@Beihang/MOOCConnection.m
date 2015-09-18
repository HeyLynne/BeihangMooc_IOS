//
//  MOOCConnection.m
//  commTesting
//
//  Created by Satte on 14-8-19.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCConnection.h"

__strong static MOOCConnection *sharedInstance = nil;

/*
@interface MOOCConnection ()
- (BOOL)refreshCookie:(NSURLResponse *)res From:(NSURL *)url;
- (void)getFile:(NSString *)url parameter:(NSString *)param sender:(NSString *)sid;
- (void)sendHTTPGetRequest:(NSURL *)url parameter:(NSString *)param sender:(NSString *)sid;
- (void)sendHTTPPostRequest:(NSURL *)url parameter:(NSString *)param sender:(NSString *)sid;
@end
*/
/*
 notiDict Format:
 status: BOOL
 statusCode: int
 Error: errString
 courseid: NSString
 */
@implementation MOOCConnection

- (id)init
{
    self = [super init];
    if (self)
    {
        conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        conf.timeoutIntervalForRequest = iMOOCRequestTimeOut;
        conf.timeoutIntervalForResource = iMOOCRequestTimeOutDownload;
        session = [NSURLSession sessionWithConfiguration:conf];
        noti = [NSNotificationCenter defaultCenter];
        courseData = [MOOCCourseData sharedInstance];
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return self;
}

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super allocWithZone:nil] init];
    });
    return sharedInstance;
}

- (void)MOOCInit
{
    NSURL *addr = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@init",Target_URL,@"/mobile_api/"]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:addr completionHandler:^(NSData *data, NSURLResponse *res, NSError *err)
    {
        NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
        NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)res;
        int code = [httpres statusCode];
        if(code>=400 || err)
        {
            //NSDictionary *sendDict = @{@"statusCode":[NSString stringWithFormat:@"%d",code],@"error":err};
            [notiDict setObject:@"0" forKey:@"status"];
        }
        else
        {
            NSArray *arr = [NSHTTPCookie cookiesWithResponseHeaderFields:[httpres allHeaderFields] forURL:addr];
            NSString *token = nil;
            for (NSHTTPCookie *cookie in arr)
            {
                BOOL isToken = [[[cookie name] stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@"csrftoken"];
                NSString *value = [[cookie value] stringByReplacingOccurrencesOfString:@" " withString:@""];
                if (isToken && value && ![value isEqualToString:@""]) token = value;
            }
            if (token)
            {
                [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"X-CSRFToken"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [notiDict setObject:@"1" forKey:@"status"];
            }
            else
            {
                [notiDict setObject:@"0" forKey:@"status"];
            }
        }
        [notiDict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
        [notiDict setObject:(err?[err localizedDescription]:@"") forKey:@"error"];
        [noti postNotificationName:sMOOCInitNotification object:self userInfo:notiDict];
    }];
    [task resume];
}

- (void)MOOCLogin:(NSString *)user Pass:(NSString *)pass
{
    NSURL *addr = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@login",Target_URL,@"/mobile_api/"]];
    NSString *token = [[[NSUserDefaults standardUserDefaults] objectForKey:@"X-CSRFToken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
#warning 写死
    //NSString *args = [NSString stringWithFormat:@"email=%@&password=%@",user,pass];
    NSString *args = [NSString stringWithFormat:@"email=staff@mooc.buaa.edu.cn&password=BSy8oLrn"];
    user = @"staff@mooc.buaa.edu.cn";
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:addr];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[args dataUsingEncoding:NSUTF8StringEncoding]];
    [urlReq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlReq addValue:token forHTTPHeaderField:@"X-CSRFToken"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData *data, NSURLResponse *res, NSError *err)
    {
        NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
        NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)res;
        int code = [httpres statusCode];
        if(code>=400)
        {
            [notiDict setObject:@"0" forKey:@"status"];
        }
        else
        {
            NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [dict setObject:user forKey:@"mail_address"];
            BOOL success = [[dict objectForKey:@"success"] boolValue];
            if (success)
            {
                [courseData insertUserInfoWithData:dict];
                [notiDict setObject:@"1" forKey:@"status"];
            }
            else
            {
                [notiDict setObject:@"0" forKey:@"status"];
            }
        }
        [notiDict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
        [notiDict setObject:(err?[err localizedDescription]:@"") forKey:@"error"];
        [noti postNotificationName:sMOOCLoginNotification object:self userInfo:notiDict];
    }];
    [task resume];
}

- (void)MOOCCourses
{
    //if ([[MOOCCourseData sharedInstance] checkValid])
    if (false)
    {
        NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
        NSArray *arr = [[MOOCCourseData sharedInstance] getCourseData];
        [notiDict setObject:arr forKey:@"courseArray"];
        [notiDict setObject:@"1" forKey:@"status"];
        [notiDict setObject:@"200" forKey:@"statusCode"];
        [notiDict setObject:@"" forKey:@"error"];
        [noti postNotificationName:sMOOCCourseNotification object:self userInfo:notiDict];
    }
    else
    {
        NSURL *addr = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@courses",Target_URL,@"/mobile_api/"]];
        NSURLSessionDataTask *task = [session dataTaskWithURL:addr completionHandler:^(NSData *data, NSURLResponse *res, NSError *err)
        {
            NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
            NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)res;
            int code = [httpres statusCode];
            if(code>=400)
            {
                [notiDict setObject:@"0" forKey:@"status"];
            }
            else
            {
                [courseData deleteCourse:nil];
                NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                [notiDict setObject:arr forKey:@"courseArray"];
                for (NSDictionary *dict in arr)
                    [courseData insertCourseWithData:dict];
                [notiDict setObject:@"1" forKey:@"status"];
            }
            [notiDict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
            [notiDict setObject:(err?[err localizedDescription]:@"") forKey:@"error"];
            [noti postNotificationName:sMOOCCourseNotification object:self userInfo:notiDict];
            //NSLog(@"Finished");
        }];
        [task resume];
    }
}


- (void)MOOCCourseAbout:(NSString *)cid
{
    if ([[MOOCCourseData sharedInstance] checkValid:cid]&&[[[[MOOCCourseData sharedInstance] getCourseData:cid withSections:NO] objectForKey:@"about"] length]>10)
    {
        NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
        [notiDict setObject:@"1" forKey:@"status"];
        [notiDict setObject:cid forKey:sMOOCCourseID];
        [notiDict setObject:@"200" forKey:@"statusCode"];
        [notiDict setObject:@"" forKey:@"error"];
        [noti postNotificationName:sMOOCCourseAboutNotification object:self userInfo:notiDict];
    }
    else
    {
        NSURL *addr = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@course_about",Target_URL,@"/mobile_api/"]];
        NSString *token = [[[NSUserDefaults standardUserDefaults] objectForKey:@"X-CSRFToken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *args = [NSString stringWithFormat:@"course_id=%@",cid];
        
        NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:addr];
        [urlReq setHTTPMethod:@"POST"];
        [urlReq setHTTPBody:[args dataUsingEncoding:NSUTF8StringEncoding]];
        [urlReq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
        [urlReq addValue:token forHTTPHeaderField:@"X-CSRFToken"];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData *data, NSURLResponse *res, NSError *err)
        {
            NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
            NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)res;
            int code = [httpres statusCode];
            if(code>=400)
            {
                [notiDict setObject:@"0" forKey:@"status"];
            }
            else
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                [courseData updateCourse:cid withData:dict];
                [notiDict setObject:@"1" forKey:@"status"];
            }
            [notiDict setObject:cid forKey:sMOOCCourseID];
            [notiDict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
            [notiDict setObject:(err?[err localizedDescription]:@"") forKey:@"error"];
            [noti postNotificationName:sMOOCCourseAboutNotification object:self userInfo:notiDict];
        }];
        [task resume];
    }
}

- (void)MOOCCourseware:(NSString *)cid
{
    NSURL *addr = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@course_courseware",Target_URL,@"/mobile_api/"]];
    NSString *token = [[[NSUserDefaults standardUserDefaults] objectForKey:@"X-CSRFToken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *args = [NSString stringWithFormat:@"course_id=%@",cid];
    
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:addr];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[args dataUsingEncoding:NSUTF8StringEncoding]];
    [urlReq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlReq addValue:token forHTTPHeaderField:@"X-CSRFToken"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData *data, NSURLResponse *res, NSError *err)
    {
        NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
        NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)res;
        NSString *reason = nil;
        int code = [httpres statusCode];
        if(code>=400)
        {
            [notiDict setObject:@"0" forKey:@"status"];
        }
        else
        {
            NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];

            if ([[dict objectForKey:@"status"] boolValue])
            {
#warning 临时方法
                [notiDict setObject:[dict objectForKey:@"sections"] forKey:@"sections"];
                [dict removeObjectForKey:@"sections"];
                [courseData updateCourse:cid withData:dict];
                [notiDict setObject:@"1" forKey:@"status"];
            }
            else
            {
                [notiDict setObject:@"0" forKey:@"status"];
            }
            
        }
        [notiDict setObject:cid forKey:sMOOCCourseID];
        [notiDict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
        [notiDict setObject:(err?[err localizedDescription]:(reason?reason:@"")) forKey:@"error"];
        [noti postNotificationName:sMOOCCourseWareNotification object:self userInfo:notiDict];
    }];
    [task resume];
}

- (void)MOOCCourseEnroll:(NSString *)cid action:(int)enroll
{
    NSURL *addr = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@course_enroll",Target_URL,@"/mobile_api/"]];
    NSString *enrollStr;
    if (enroll == MOOCCourseEnroll) enrollStr = @"enroll";
    else if (enroll == MOOCCourseUnEnroll) enrollStr = @"unenroll";
    else
        return;
    NSString *token = [[[NSUserDefaults standardUserDefaults] objectForKey:@"X-CSRFToken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *args = [NSString stringWithFormat:@"course_id=%@&enrollment_action=%@",cid,enrollStr];
    
    NSMutableURLRequest *urlReq = [NSMutableURLRequest requestWithURL:addr];
    [urlReq setHTTPMethod:@"POST"];
    [urlReq setHTTPBody:[args dataUsingEncoding:NSUTF8StringEncoding]];
    [urlReq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlReq addValue:token forHTTPHeaderField:@"X-CSRFToken"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:urlReq completionHandler:^(NSData *data, NSURLResponse *res, NSError *err)
    {
        NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
        NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)res;
        NSString *reason = nil;
        int code = [httpres statusCode];
        if(code>=400)
        {
            [notiDict setObject:@"0" forKey:@"status"];
        }
        else
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            BOOL status = [[dict objectForKey:@"status"] boolValue];
            if (status)
            {
                [notiDict setObject:@"1" forKey:@"status"];
                if (enroll == MOOCCourseEnroll)
                {
                    [courseData updateCourse:cid withData:@{@"registered":@"1"}];
                    [notiDict setObject:@"1" forKey:@"registered"];
                }
                else
                {
                    [courseData updateCourse:cid withData:@{@"registered":@"0"}];
                    [notiDict setObject:@"0" forKey:@"registered"];
                }

            }
            else
            {
                [notiDict setObject:@"0" forKey:@"status"];
                reason = [dict objectForKey:@"reason"];
            }
        }
        [notiDict setObject:cid forKey:sMOOCCourseID];
        [notiDict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
        [notiDict setObject:(err?[err localizedDescription]:(reason?reason:@"")) forKey:@"error"];
        [noti postNotificationName:sMOOCCourseEnrollNotification object:self userInfo:notiDict];
    }];
    [task resume];
}

//单独课程列表不设有效期，实时更新
- (void)MOOCGetCourseEnrollment
{
    NSURL *addr = [NSURL URLWithString:[NSString stringWithFormat:@"%s%@get_course_enrollment",Target_URL,@"/mobile_api/"]];
    NSURLSessionDataTask *task = [session dataTaskWithURL:addr completionHandler:^(NSData *data, NSURLResponse *res, NSError *err)
    {
        NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
        NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)res;
        int code = [httpres statusCode];
        if(code>=400)
        {
            [notiDict setObject:@"0" forKey:@"status"];
        }
        else
        {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            BOOL status = [[dict objectForKey:@"status"] boolValue];
            if (status)
            {
                NSArray *courses = [dict objectForKey:@"enrollment"];
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in courses)
                {
                    NSString *courseid = [dict objectForKey:sMOOCCourseID];
                    [courseData updateCourse:courseid withData:dict];
                    [arr addObject:courseid];
                }
                [notiDict setObject:arr forKey:@"courseArray"];
                [notiDict setObject:@"1" forKey:@"status"];
            }
            else
            {
                [notiDict setObject:@"0" forKey:@"status"];
            }
        }
        [notiDict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
        [notiDict setObject:(err?[err localizedDescription]:@"") forKey:@"error"];
        [noti postNotificationName:sMOOCGetCourseEnrollmentNotification object:self userInfo:notiDict];
    }];
    [task resume];
}


//有效期
- (void)MOOCGetImage:(NSString *)cid imagePath:(NSString *)path
{
#warning 临时永久只取一次图片以体现好效果
    NSDictionary *dict = [[MOOCCourseData sharedInstance] getCourseData:cid withSections:NO];
    //if (false)
    if ([[dict objectForKey:@"course_image"] isAbsolutePath]&&[[MOOCCourseData sharedInstance] checkValid:cid])
    {
        NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
        [notiDict setObject:@"1" forKey:@"status"];
        [notiDict setObject:cid forKey:sMOOCCourseID];
        [notiDict setObject:@"200" forKey:@"statusCode"];
        [notiDict setObject:@"" forKey:@"error"];
        [noti postNotificationName:sMOOCCourseAboutNotification object:self userInfo:notiDict];
    }
    else
    {
        //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%s%s%@",Target_URL,Target_Img_Path?Target_Img_Path:nil,path]];
        NSString* urlstr = [NSString stringWithFormat:@"%s%@", Target_URL, path];
        NSURL *url = [NSURL URLWithString:[urlstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        //NSLog(@"%@,%@",url,cid);
        NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url completionHandler:^(NSURL *loc, NSURLResponse *res, NSError *err)
        {
            NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
            NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)res;
            int code = [httpres statusCode];
            if (err || code>=400 )
            {
                [notiDict setObject:@"0" forKey:@"status"];
            }
            else
            {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSURL *path = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
                NSData *data = [NSData dataWithContentsOfURL:loc];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMddHHmmss-SSS"];
                int lengthOfString = 4;
                char string[lengthOfString];
                for (int x=0; x<lengthOfString; string[x++] = (char)('a'+(arc4random_uniform(26))));
                NSString *randname = [[NSString alloc] initWithBytes:string length:lengthOfString encoding:NSUTF8StringEncoding];
                NSString *datename = [dateFormatter stringFromDate:[NSDate date]];
                NSString *filename = [NSString stringWithFormat:@"%@-%@",datename,randname];
                NSString *fullpath = [NSString stringWithFormat:@"%@%@.jpg",[path path],filename];
                BOOL success = [fileManager createFileAtPath:fullpath contents:data attributes:nil];
                //NSLog(@"fullpath:%@",fullpath);
                if (success)
                {
                    NSLog(@"File Saved To Path: %@",fullpath);
                    NSDictionary *sendDict = @{@"course_image":fullpath};
                    [courseData updateCourse:cid withData:sendDict];
                    [notiDict setObject:@"1" forKey:@"status"];
                }
                else
                {
                    [notiDict setObject:@"0" forKey:@"status"];
                }
            }
            [notiDict setObject:cid forKey:sMOOCCourseID];
            [notiDict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
            [notiDict setObject:(err?[err localizedDescription]:@"") forKey:@"error"];
            [noti postNotificationName:sMOOCGetImageNotification object:self userInfo:notiDict];
        }];
        [task resume];
    }
}

//下载字幕文件并返回字幕文件的位置
-(void)MOOCGetSubtitles:(NSString *)subtitleUrl
{
    NSMutableDictionary *subtitleLocalUrl=[[ NSMutableDictionary alloc] init];
   // NSMutableDictionary *notiDict = [[NSMutableDictionary alloc] init];
    NSURL *aSubtitleUrl=[NSURL URLWithString:subtitleUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:aSubtitleUrl];
    //NSString *fullpath = @"";
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *loc, NSURLResponse *res, NSError *err){
        NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)res;
        int code = [httpres statusCode];
        if (err || code>=400 )
        {
            [subtitleLocalUrl setValue:@"0" forKey:@"status"];
        }
        else{
           
            NSHTTPURLResponse *httpres = (NSHTTPURLResponse *)res;
            int code = [httpres statusCode];
            if (err || code>=400 )
            {
                [subtitleLocalUrl setValue:@"0" forKey:@"status"];
            }
            else
            {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSURL *path = [[fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] objectAtIndex:0];
                NSData *data = [NSData dataWithContentsOfURL:loc];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyyMMddHHmmss-SSS"];
                int lengthOfString = 4;
                char string[lengthOfString];
                for (int x=0; x<lengthOfString; string[x++] = (char)('a'+(arc4random_uniform(26))));
                NSString *randname = [[NSString alloc] initWithBytes:string length:lengthOfString encoding:NSUTF8StringEncoding];
                NSString *datename = [dateFormatter stringFromDate:[NSDate date]];
                NSString *filename = [NSString stringWithFormat:@"%@-%@",datename,randname];
                NSString *fullpath = [NSString stringWithFormat:@"%@%@.srt",[path path],filename];
                BOOL success = [fileManager createFileAtPath:fullpath contents:data attributes:nil];
                //NSLog(@"fullpath:%@",fullpath);
                if (success)
                {
                    //NSLog(@"File Saved To Path: %@",fullpath);
                    [subtitleLocalUrl setValue:@"1" forKey:@"status"];
                    [subtitleLocalUrl setValue:fullpath forKey:@"url"];
                }
                else
                {
                    [subtitleLocalUrl setValue:@"0" forKey:@"status"];
                }
            }
        }
        [noti postNotificationName:sMOOCGetSubtitles object:self userInfo:subtitleLocalUrl];
    }];
    [task resume];
}

-(void)MOOCGetForumDiscussionData:(NSString *)course_id
{
    NSString *addr=[NSURL URLWithString:[NSString stringWithFormat:@"%s%@discussion_forum",Target_URL,@"/mobile_api/"]];
    NSString *token = [[[NSUserDefaults standardUserDefaults] objectForKey:@"X-CSRFToken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *args=[NSString stringWithFormat:@"course_id=%@",course_id];
    NSMutableURLRequest *urlreq=[NSMutableURLRequest requestWithURL:addr];
    [urlreq setHTTPMethod:@"POST"];
    [urlreq setHTTPBody:[args dataUsingEncoding:NSUTF8StringEncoding]];
    [urlreq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlreq addValue:token forHTTPHeaderField:@"X-CSRFToken"];
    
    NSURLSessionDataTask *task=[session dataTaskWithRequest:urlreq completionHandler:^(NSData *data,NSURLResponse *res,NSError *err){
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        NSHTTPURLResponse *httpRes=(NSHTTPURLResponse *)res;
        NSString *reason=nil;
        int code=[httpRes statusCode];
        if(code>=400){
            [dict setObject:@"0" forKey:@"status"];
        }
        else{
            NSMutableDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if([[jsonDict objectForKey:@"status"] boolValue]){
                [dict setObject:@"1" forKey:@"status"];
                [jsonDict removeObjectForKey:@"status"];
                [dict setObject:[jsonDict objectForKey:@"course_id"] forKey:@"course_id"];
                [jsonDict removeObjectForKey:@"course_id"];
                [dict setObject:[jsonDict objectForKey:@"threads"] forKey:@"threads"];
                [jsonDict removeObjectForKey:@"threads"];
                [dict setObject:[jsonDict objectForKey:@"annotated_content_info"] forKey:@"annotated_content_info"];
                [jsonDict removeObjectForKey:@"annotated_content_info"];
                [dict setObject:[jsonDict objectForKey:@"staff_access"] forKey:@"staff_access"];
                [jsonDict removeObjectForKey:@"staff_access"];
                [dict setObject:[jsonDict objectForKey:@"user_info"] forKey:@"user_info"];
                [jsonDict removeObjectForKey:@"user_info"];
                [dict setObject:[jsonDict objectForKey:@"cohorts"] forKey:@"cohorts"];
                [jsonDict removeObjectForKey:@"cohorts"];
                [dict setObject:[jsonDict objectForKey:@"cohorted_commentables"] forKey:@"cohorted_commentables"];
                [jsonDict removeObjectForKey:@"cohorted_commentables"];
                [dict setObject:[jsonDict objectForKey:@"category_map"] forKey:@"category_map"];
                [jsonDict removeObjectForKey:@"category_map"];
                [dict setObject:[jsonDict objectForKey:@"sort_preference"] forKey:@"sort_preference"];
                [jsonDict removeObjectForKey:@"category_map"];
                [dict setObject:[jsonDict objectForKey:@"is_moderator"] forKey:@"is_moderator"];
                [jsonDict removeObjectForKey:@"is_moderator"];
                [dict setObject:[jsonDict objectForKey:@"thread_pages"] forKey:@"thread_pages"];
                [jsonDict removeObjectForKey:@"thread_pages"];
                [dict setObject:[jsonDict objectForKey:@"user_cohort"] forKey:@"user_cohort"];
                [jsonDict removeObjectForKey:@"user_cohort"];
                [dict setObject:[jsonDict objectForKey:@"flag_moderator"] forKey:@"flag_moderator"];
                [jsonDict removeObjectForKey:@"flag_moderator"];
                [dict setObject:[jsonDict objectForKey:@"is_course_cohorted"] forKey:@"is_course_cohorted"];
                [jsonDict removeObjectForKey:@"is_course_cohorted"];
                [jsonDict removeAllObjects];
            }
            else{
                [dict setObject:@"0" forKey:@"status"];
            }
        }
        [dict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
        [dict setObject:(err?[err localizedDescription]:(reason?reason:@"")) forKey:@"error"];
        [noti postNotificationName:sMOOCGetForumDiscussionData object:self userInfo:dict];
    }];
    [task resume];
}

-(void)MOOCGEtPageForumData:(NSString *)course_id pageNum:(int) page
{
    NSString *addr=[NSURL URLWithString:[NSString stringWithFormat:@"%s%@discussion_forum?ajax=1&page=%d&sort_key=date&sort_order=desc",Target_URL,@"/mobile_api/",page]];
    NSString *token = [[[NSUserDefaults standardUserDefaults] objectForKey:@"X-CSRFToken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *args=[NSString stringWithFormat:@"course_id=%@",course_id];
    NSMutableURLRequest *urlreq=[NSMutableURLRequest requestWithURL:addr];
    [urlreq setHTTPMethod:@"POST"];
    [urlreq setHTTPBody:[args dataUsingEncoding:NSUTF8StringEncoding]];
    [urlreq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlreq addValue:token forHTTPHeaderField:@"X-CSRFToken"];
    
    NSURLSessionDataTask *task=[session dataTaskWithRequest:urlreq completionHandler:^(NSData *data,NSURLResponse *res,NSError *err){
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        NSHTTPURLResponse *httpRes=(NSHTTPURLResponse *)res;
        NSString *reason=nil;
        int code=[httpRes statusCode];
        if(code>=400){
            [dict setObject:@"0" forKey:@"status"];
        }
        else{
            NSMutableDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if([[jsonDict objectForKey:@"status"] boolValue]){
                [dict setObject:@"1" forKey:@"status"];
                [jsonDict removeObjectForKey:@"status"];
                [dict setObject:[jsonDict objectForKey:@"course_id"] forKey:@"course_id"];
                [jsonDict removeObjectForKey:@"course_id"];
                [dict setObject:[jsonDict objectForKey:@"threads"] forKey:@"threads"];
                [jsonDict removeObjectForKey:@"threads"];
                [dict setObject:[jsonDict objectForKey:@"annotated_content_info"] forKey:@"annotated_content_info"];
                [jsonDict removeObjectForKey:@"annotated_content_info"];
                [dict setObject:[jsonDict objectForKey:@"staff_access"] forKey:@"staff_access"];
                [jsonDict removeObjectForKey:@"staff_access"];
                [dict setObject:[jsonDict objectForKey:@"cohorts"] forKey:@"cohorts"];
                [jsonDict removeObjectForKey:@"cohorts"];
                [dict setObject:[jsonDict objectForKey:@"category_map"] forKey:@"category_map"];
                [jsonDict removeObjectForKey:@"category_map"];
                [dict setObject:[jsonDict objectForKey:@"sort_preference"] forKey:@"sort_preference"];
                [jsonDict removeObjectForKey:@"category_map"];
                [dict setObject:[jsonDict objectForKey:@"cohorted_commentables"] forKey:@"cohorted_commentables"];
                [jsonDict removeObjectForKey:@"cohorted_commentables"];
                [dict setObject:[jsonDict objectForKey:@"thread_pages"] forKey:@"thread_pages"];
                [jsonDict removeObjectForKey:@"thread_pages"];
                [dict setObject:[jsonDict objectForKey:@"user_cohort"] forKey:@"user_cohort"];
                [jsonDict removeObjectForKey:@"user_cohort"];
                [dict setObject:[jsonDict objectForKey:@"flag_moderator"] forKey:@"flag_moderator"];
                [jsonDict removeObjectForKey:@"flag_moderator"];
                [dict setObject:[jsonDict objectForKey:@"is_course_cohorted"] forKey:@"is_course_cohorted"];
                [jsonDict removeObjectForKey:@"is_course_cohorted"];
                [jsonDict removeAllObjects];
            }
            else{
                [dict setObject:@"0" forKey:@"status"];
            }
        }
        [dict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
        [dict setObject:(err?[err localizedDescription]:(reason?reason:@"")) forKey:@"error"];
        [noti postNotificationName:sMOOCGetPageForum object:self userInfo:dict];
    }];
    [task resume];
}

-(void)MOOCGetDiscussionDetail:(NSDictionary *)dict
{
    NSString *addr=[NSURL URLWithString:[NSString stringWithFormat:@"%s%@discussion_forum_details",Target_URL,@"/mobile_api/"]];
    NSString *token=[[[NSUserDefaults standardUserDefaults] objectForKey:@"X-CSRFToken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *args=[NSString stringWithFormat:@"course_id=%@&discussion_id=%@&thread_id=%@",[dict objectForKey:@"course_id"],[dict objectForKey:@"discussion_id"],[dict objectForKey:@"thread_id"]];
    NSMutableURLRequest *urlreq=[NSMutableURLRequest requestWithURL:addr];
    [urlreq setHTTPMethod:@"POST"];
    [urlreq setHTTPBody:[args dataUsingEncoding:NSUTF8StringEncoding]];
    [urlreq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlreq addValue:token forHTTPHeaderField:@"X-CSRFToken"];
    
    NSURLSessionDataTask *task=[session dataTaskWithRequest:urlreq completionHandler:^(NSData *data,NSURLResponse *res,NSError *err){
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] init];
        NSHTTPURLResponse *httpRes=(NSHTTPURLResponse *) res;
        NSString *reason=nil;
        int code=[httpRes statusCode];
        if(code>=400){
            [dict setObject:@"0" forKey:@"status"];
        }
        else{
            NSMutableDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if([[jsonDict objectForKey:@"status"] boolValue]){
                [dict setObject:@"1" forKey:@"status"];
                [jsonDict removeObjectForKey:@"status"];
                [dict setObject:[jsonDict objectForKey:@"course_id"] forKey:@"course_id"];
                [jsonDict removeObjectForKey:@"course_id"];
                [dict setObject:[jsonDict objectForKey:@"thread"] forKey:@"thread"];
                [jsonDict removeObjectForKey:@"thread"];
                [dict setObject:[jsonDict objectForKey:@"thread_id"] forKey:@"thread_id"];
                [jsonDict removeObjectForKey:@"thread_id"];
                [dict setObject:[jsonDict objectForKey:@"discussion_id"] forKey:@"discussion_id"];
                [jsonDict removeObjectForKey:@"discussion_id"];
                [dict setObject:[jsonDict objectForKey:@"user_info"] forKey:@"user_info"];
                [jsonDict removeObjectForKey:@"user_info"];
                [dict setObject:[jsonDict objectForKey:@"category_map"] forKey:@"category_map"];
                [jsonDict removeObjectForKey:@"category_map"];
                [dict setObject:[jsonDict objectForKey:@"roles"] forKey:@"roles"];
                [jsonDict removeObjectForKey:@"roles"];
                [dict setObject:[jsonDict objectForKey:@"is_course_cohorted"] forKey:@"is_course_cohorted"];
                [jsonDict removeObjectForKey:@"is_course_cohorted"];
                [dict setObject:[jsonDict objectForKey:@"is_moderator"] forKey:@"is_moderator"];
                [jsonDict removeObjectForKey:@"is_moderator"];
                [dict setObject:[jsonDict objectForKey:@"flag_moderator"] forKey:@"flag_moderator"];
                [jsonDict removeObjectForKey:@"flag_moderator"];
                [dict setObject:[jsonDict objectForKey:@"cohorts"] forKey:@"cohorts"];
                [jsonDict removeObjectForKey:@"cohorts"];
                [dict setObject:[jsonDict objectForKey:@"user_cohort"] forKey:@"user_cohort"];
                [jsonDict removeObjectForKey:@"user_cohort"];
                [dict setObject:[jsonDict objectForKey:@"cohorted_commentables"] forKey:@"cohorted_commentables"];
                [jsonDict removeObjectForKey:@"cohorted_commentables"];
                [dict setObject:[jsonDict objectForKey:@"sort_preference"] forKey:@"sort_preference"];
                [jsonDict removeObjectForKey:@"sort_preference"];
                [jsonDict removeAllObjects];
            }
            else{
                [dict setObject:@"0" forKey:@"status"];
            }
        }
        [dict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
        [dict setObject:(err?[err localizedDescription]:(reason?reason:@"")) forKey:@"error"];
        [noti postNotificationName:sMOOCGetDiscussionDetails object:self userInfo:dict];
    }];
    [task resume];
}

-(void)MOOCCreateAComment:(NSDictionary *)dict
{
    NSString *addr=[NSString stringWithFormat:@"%s/courses/%@/discussion/threads/%@/reply?ajax=1",Target_URL,[dict objectForKey:@"course_id"],[dict objectForKey:@"thread_id"]];
    NSString *token=[[[NSUserDefaults standardUserDefaults] objectForKey:@"X-CSRFToken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *args=[NSString stringWithFormat:@"body=%@",[dict objectForKey:@"body"]];
    NSMutableURLRequest *urlreq=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:addr]];
    [urlreq setHTTPMethod:@"POST"];
    [urlreq setHTTPBody:[args dataUsingEncoding:NSUTF8StringEncoding]];
    [urlreq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlreq addValue:token forHTTPHeaderField:@"X-CSRFToken"];
     NSURLSessionDataTask *task=[session dataTaskWithRequest:urlreq completionHandler:^(NSData *data,NSURLResponse *res,NSError *err){
         NSMutableDictionary *ndict=[[NSMutableDictionary alloc] init];
         NSHTTPURLResponse *httpRes=(NSHTTPURLResponse *) res;
         NSString *reason=nil;
         int code=[httpRes statusCode];
         if(code>=400){
             [ndict setObject:@"0" forKey:@"status"];
         }
         else{
             NSMutableDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             if([[jsonDict allKeys] containsObject:@"errors"]){
                 [ndict setObject:@"0" forKey:@"status"];
             }
             else{
                 [ndict setObject:@"1" forKey:@"status"];
                 [jsonDict removeAllObjects];
             }
        }
         [ndict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
         [ndict setObject:(err?[err localizedDescription]:(reason?reason:@"")) forKey:@"error"];
         [noti postNotificationName:sMOOCCreateAComment object:self userInfo:ndict];
     }];
    [task resume];
}

-(void)MOOCCreateAThread:(NSDictionary *)dict
{
    NSString *addr=[NSString stringWithFormat:@"%s%@new_thread",Target_URL,@"/mobile_api/"];
    NSString *token=[[[NSUserDefaults standardUserDefaults] objectForKey:@"X-CSRFToken"] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *args=[NSString stringWithFormat:@"body=%@&title=%@&course_id=%@&commentable_id=%@",[dict objectForKey:@"body"],[dict objectForKey:@"title"],[dict objectForKey:@"course_id"],[dict objectForKey:@"discussion_id"]];
    NSMutableURLRequest *urlreq=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:addr]];
    [urlreq setHTTPMethod:@"POST"];
    [urlreq setHTTPBody:[args dataUsingEncoding:NSUTF8StringEncoding]];
    [urlreq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [urlreq addValue:token forHTTPHeaderField:@"X-CSRFToken"];
    NSURLSessionDataTask *task=[session dataTaskWithRequest:urlreq completionHandler:^(NSData *data,NSURLResponse *res,NSError *err){
        NSMutableDictionary *ndict=[[NSMutableDictionary alloc] init];
        NSHTTPURLResponse *httpRes=(NSHTTPURLResponse *) res;
        NSString *reason=nil;
        int code=[httpRes statusCode];
        if(code>=400){
            [ndict setObject:@"0" forKey:@"status"];
        }
        else{
            NSMutableDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if([[jsonDict allKeys] containsObject:@"errors"]){
                [ndict setObject:@"0" forKey:@"status"];
            }
            else{
                [ndict setObject:@"1" forKey:@"status"];
                [jsonDict removeAllObjects];
            }
        }
        [ndict setObject:[NSString stringWithFormat:@"%d",code] forKey:@"statusCode"];
        [ndict setObject:(err?[err localizedDescription]:(reason?reason:@"")) forKey:@"error"];
        [noti postNotificationName:sMOOCCreateAThread object:self userInfo:ndict];
     }];
    [task resume];
}
@end

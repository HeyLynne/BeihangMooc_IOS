//
//  MOOCUrlProcessing.m
//  MOOC@Beihang
//
//  Created by AdmireBeihang on 15/1/11.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import "MOOCUrlProcessing.h"

@implementation MOOCUrlProcessing
static NSString *pattern=@"^(http|https):\/\/(www).(mooc).(buaa).(edu).(cn)\/(.*).(mp4)$";


-(BOOL)isHTTPUrl:(NSString *)url{
    NSError *error=NULL;
    NSRegularExpression *reg=[NSRegularExpression regularExpressionWithPattern:pattern options:nil error:&error];
    NSInteger numberOfMatches=[reg numberOfMatchesInString:url options:0 range:NSMakeRange(0, [url length])];
    //NSLog(@"numberOfMatches:%d",numberOfMatches);
    if(numberOfMatches==1)
        return  YES;
    else
        return NO;
}

-(NSString *)patternUrl:(NSString *)url{
    NSString *newUrl=nil;
    NSString *begin=[url substringToIndex:2];
    //NSLog(@"begin-length:%d",[begin length]);
    if([begin isEqualToString:@"//"]){
        newUrl=[@"http:" stringByAppendingString:url];
    }
    else{
        NSLog(@"%@",[url substringToIndex:20]);
        if([[url substringToIndex:1] isEqualToString:@"/"]){
            newUrl=[@Target_URL stringByAppendingString:url];
        }
        else if([[url substringToIndex:20]isEqualToString:@Target_URL_Domain]||[[url substringToIndex:16]isEqualToString:@Target_URL_Domain_Without_WWW]){
            newUrl=[@"http://" stringByAppendingString:url];
        }
        else{
            newUrl=[@Target_URL_Pattern stringByAppendingString:url];
        }
    }
    return newUrl;
}

//处理字幕的url
-(NSString *)patternSrtUrl:(NSString *)subtitleUrl courseid:(NSString *)courseId
{
    NSArray *couseIdArray=[courseId componentsSeparatedByString:@"/"];
    NSString *newCourseId=[[couseIdArray objectAtIndex:0] stringByAppendingFormat:@"%@%@",@"/",[couseIdArray objectAtIndex:1]];
    if(![[subtitleUrl substringFromIndex:[subtitleUrl length]-4] isEqualToString:@".srt"]){
        [subtitleUrl stringByAppendingString:@".srt"];
    }
    return [@Target_URL_Pattern stringByAppendingFormat:@"%@%@%@%@%@",@"c4x",@"/",newCourseId,@"/asset/",subtitleUrl];
}
@end

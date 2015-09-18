//
//  MOOCUrlProcessing.h
//  MOOC@Beihang
//
//  Created by AdmireBeihang on 15/1/11.
//  Copyright (c) 2015年 admire. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOOCUrlProcessing : NSRegularExpression

-(BOOL)isHTTPUrl:(NSString *)url;
-(NSString *)patternUrl:(NSString *)url;
-(BOOL)isContainChinese:(NSString *)url;
-(NSString *)patternSrtUrl:(NSString *)subtitleUrl courseid:(NSString *)courseId;
@end

//
//  MoocVideoActivityIndicator.h
//  MOOC@Beihang
//
//  Created by AdmireBeihang on 14/12/22.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoocVideoActivityIndicator : UIViewController
{
    UIActivityIndicatorView *prog;
    float mpWidth;
    float mpHeight;
}
@property(nonatomic,assign)BOOL *isStop;
- (id)init;
- (void)start;
- (void)stop;

@end

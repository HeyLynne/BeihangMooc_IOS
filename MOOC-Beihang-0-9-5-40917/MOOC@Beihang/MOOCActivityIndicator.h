//
//  MOOCActivityIndicator.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-24.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MOOCActivityIndicator : UIViewController
{
    UIActivityIndicatorView *prog;
}

- (id)init;
- (void)start;
- (void)stop;

@end

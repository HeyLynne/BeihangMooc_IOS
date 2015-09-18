//
//  MOOCWelcomeView.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-2.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOOCConnection.h"

@interface MOOCWelcomeView : UIViewController <UIAlertViewDelegate>
{
    BOOL isReceived;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *prog;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet UILabel *label_bhsyssj;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UILabel *label_addr;

- (IBAction)aboutUs:(id)sender;

@end

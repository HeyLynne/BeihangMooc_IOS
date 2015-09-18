//
//  MOOCLoginView.h
//  MOOC@Beihang
//
//  Created by Satte on 14-8-2.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOOCConnection.h"

@interface MOOCLoginView : UIViewController <UITextFieldDelegate>
{
    UIInterfaceOrientation fromInterfaceOrientation;
    BOOL isEditing;
}
//@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *prog;

- (IBAction)anonyLogin:(id)sender;
- (IBAction)regAccount:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txtUser;
@property (weak, nonatomic) IBOutlet UITextField *txtPass;
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UILabel *label_user;
@property (weak, nonatomic) IBOutlet UILabel *label_pass;
@property (weak, nonatomic) IBOutlet UIButton *btn_liulan;
@property (weak, nonatomic) IBOutlet UILabel *label_myzh;
@property (weak, nonatomic) IBOutlet UILabel *label_wmdkchz;
@property (weak, nonatomic) IBOutlet UIButton *btn_zhuce;
@property (weak, nonatomic) IBOutlet UILabel *label_xinyonghu;

- (IBAction)beginPass:(id)sender;
- (IBAction)exitPass:(id)sender;
- (IBAction)endPass:(id)sender;

- (IBAction)beginUser:(id)sender;
- (IBAction)endUser:(id)sender;
- (IBAction)exitUser:(id)sender;

- (IBAction)backTap:(id)sender;
- (IBAction)resign_txt:(id)sender;

@end

//
//  MOOCQRCodeView.h
//  MOOC@Beihang
//
//  Created by Satte on 14-9-4.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MOOCQRCodeView : UIViewController <AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureSession *session;
    AVCaptureDevice *device;
    AVCaptureDeviceInput *input;
    AVCaptureMetadataOutput *output;
    AVCaptureVideoPreviewLayer *previewLayer;
    NSString *decodedMessage;
    CGRect videoBound, captureBound;
    CGPoint videoPoint;
    NSDate *date;
    CAShapeLayer *square;
    UITapGestureRecognizer *tapGesture;
}

@property id sourceView;
@property (weak, nonatomic) IBOutlet UIView *detectView;
@property (weak, nonatomic) IBOutlet UILabel *label_title;
@property (weak, nonatomic) IBOutlet UILabel *label_intro;

- (void)tapDetect:(UITapGestureRecognizer *)sender;
@end

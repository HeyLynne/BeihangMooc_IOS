//
//  MOOCQRCodeView.m
//  MOOC@Beihang
//
//  Created by Satte on 14-9-4.
//  Copyright (c) 2014年 admire. All rights reserved.
//

#import "MOOCQRCodeView.h"
#import "MOOCMyCourseShow.h"
#import "MOOCCourseView.h"
#import <UIKit/UIBarButtonItem.h>
@interface MOOCQRCodeView ()

@end

@implementation MOOCQRCodeView

static BOOL isFinished;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Create a new AVCaptureSession
    isFinished = NO;
    self.navigationItem.leftBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backToIndex)];
}
- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    date = [NSDate date];
    videoBound = _detectView.frame;
    videoPoint = [_detectView center];
    captureBound = CGRectMake(75, 75, 400, 400);
    session = [[AVCaptureSession alloc] init];
    device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    // Want the normal device
    input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if(input) {
        // Add the input to the session
        [session addInput:input];
    } else {
        NSLog(@"error: %@", error);
        return;
    }
    output = [[AVCaptureMetadataOutput alloc] init];
    // Have to add the output before setting metadata types
    [session addOutput:output];
    // What different things can we register to recognise?
    NSLog(@"%@", [output availableMetadataObjectTypes]);
    // We're only interested in QR Codes
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    // This VC is the delegate. Please call us on the main queue
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // Display on screen
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.bounds = [self.view convertRect:videoBound toView:_detectView];
    previewLayer.position = [self.view convertPoint:videoPoint toView:_detectView];
    [_detectView.layer addSublayer:previewLayer];
    
    // Start the AVSession running
    [session startRunning];
    NSLog(@"%f,%f,%f,%f",self.view.bounds.origin.x,self.view.bounds.origin.y,self.view.bounds.size.width,self.view.bounds.size.height);
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetect:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    [self.view.window addGestureRecognizer:tapGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view.window removeGestureRecognizer:tapGesture];
    tapGesture = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [previewLayer removeFromSuperlayer];
    previewLayer = nil;
    [session removeInput:input];
    [session stopRunning];
    session = nil;
    [output setMetadataObjectsDelegate:nil queue:nil];
    output = nil;
    input = nil;
    device = nil;
    
    //NSLog(@"OK");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadata in metadataObjects)
    {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeQRCode])
        {
            // Transform the meta-data coordinates to screen coords
            AVMetadataMachineReadableCodeObject *transformed = (AVMetadataMachineReadableCodeObject *)[previewLayer transformedMetadataObjectForMetadataObject:metadata];
            
            CGRect sourceRect = transformed.bounds;
            CGRect targetRect = captureBound;
            BOOL inside = YES;
            if (CGRectGetMinX(sourceRect)<CGRectGetMinX(targetRect)) {inside = NO;NSLog(@"1");}
            if (CGRectGetMinY(sourceRect)<CGRectGetMinY(targetRect)) {inside = NO;NSLog(@"2");}
            if (CGRectGetMaxX(sourceRect)>CGRectGetMaxX(targetRect)) {inside = NO;NSLog(@"3");}
            if (CGRectGetMaxY(sourceRect)>CGRectGetMaxY(targetRect)) {inside = NO;NSLog(@"4");}
            
            if (inside&&!isFinished)
            {
                NSLog(@"x=%f,y=%f,w=%f,h=%f,Is Inside: %hhd",transformed.bounds.origin.x,transformed.bounds.origin.y,transformed.bounds.size.width,transformed.bounds.size.height,inside);
                decodedMessage = [transformed stringValue];
                if ([_sourceView isKindOfClass:[MOOCMyCourseShow class]])
                {
                    MOOCMyCourseShow *view = (MOOCMyCourseShow *)_sourceView;
                    view.recvStr = decodedMessage;
                    [self dismissViewControllerAnimated:YES completion:nil];
                    isFinished = YES;
                    
                }
                if ([_sourceView isKindOfClass:[MOOCCourseView class]])
                {
                    MOOCCourseView *view = (MOOCCourseView *)_sourceView;
                    view.recvStr = decodedMessage;
                    [self dismissViewControllerAnimated:YES completion:nil];
                    isFinished = YES;
                }
                
                /*
                if ([decodedMessage hasPrefix:@"MOOCVideo://"])
                {
                    decodedMessage = [decodedMessage stringByReplacingOccurrencesOfString:@"MOOCVideo" withString:@"http"];
                    isFinished = YES;
                    NSLog(@"%@",self.presentedViewController);
                    [self dismissViewControllerAnimated:NO completion:NULL];
                }
                 */
            }
        }
    }
}


- (void)tapDetect:(UITapGestureRecognizer *)sender
{
    //[self dismissViewControllerAnimated:NO completion:NULL];
}
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MOOCMyCourseShow *view = (MOOCMyCourseShow *)sender;
    view.recvURL = decodedMessage;
}
*/



- (void)viewDidLayoutSubviews
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        _label_title.frame = CGRectMake(333, 39, 358, 45);
        _label_intro.frame = CGRectMake(701, 128, 263, 250);
        _detectView.frame = CGRectMake(90, 128, 550, 550);
    }
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        _label_title.frame = CGRectMake(205, 70, 358, 45);
        _label_intro.frame = CGRectMake(109, 770, 550, 173);
        _detectView.frame = CGRectMake(109, 165, 550, 550);
        
    }
    videoBound = _detectView.frame;
    videoPoint = [_detectView center];
    previewLayer.bounds = [self.view convertRect:videoBound toView:_detectView];
    previewLayer.position = [self.view convertPoint:videoPoint toView:_detectView];
    previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)orientation;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad){
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        _label_title.frame = CGRectMake(333, 39, 358, 45);
        _label_intro.frame = CGRectMake(701, 128, 263, 250);
        _detectView.frame = CGRectMake(90, 128, 550, 550);
    }
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        _label_title.frame = CGRectMake(205, 70, 358, 45);
        _label_intro.frame = CGRectMake(109, 770, 550, 173);
        _detectView.frame = CGRectMake(109, 165, 550, 550);
    }
    videoBound = _detectView.frame;
    videoPoint = [_detectView center];previewLayer.bounds = [self.view convertRect:videoBound toView:_detectView];
    previewLayer.position = [self.view convertPoint:videoPoint toView:_detectView];
    previewLayer.connection.videoOrientation = (AVCaptureVideoOrientation)toInterfaceOrientation;
    }
}


-(void) backToIndex
{
    self.navigationController.navigationBar.hidden=NO;
    //[self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


@end

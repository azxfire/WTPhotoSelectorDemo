//
//  MDCAVCameraView.m
//  ImageChooseLibrary
//
//  Created by taowang on 15/7/21.
//  Copyright © 2015年 MDC. All rights reserved.
//

#import "MDCAVCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import "WTPhotoSelectorMarco.h"
#import "UIImage+UserPhoto.h"
@interface MDCAVCameraView()
//camera subviews
@property (strong, nonatomic) UIView *cameraActionBar;
@property (strong, nonatomic) UIButton *cameraActionBarClose;
@property (strong, nonatomic) UIButton *cameraActionBarFlash;
@property (strong, nonatomic) UILabel  *cameraActionBarFlashLable;
@property (strong, nonatomic) UIButton *cameraActionBarFlip;
@property (strong, nonatomic) UIView *cameraPreview;
@property (strong, nonatomic) UIButton *captureButton;
//avsession parts
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDeviceInput *frontCamera;
@property (strong, nonatomic) AVCaptureDeviceInput *backCamera;
@property (nonatomic) BOOL cameraIsShown;
//store image
@property (nonatomic, strong) UIImage *captureImage;
@end
@implementation MDCAVCameraView
//-(instancetype)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self setupCamera];
//        [self showCamera:YES];
//    }
//    return self;
//}
- (instancetype)initCameraWithOutPutImageSizeType:(enum MDCAVCameraPreviewAndOutPutImageSizeType)type
{
    self = [super init];
    if (self) {
        _cameraType = type;
        [self setupCamera];
        [self showCamera:YES];
    }
    return self;
}
+(UIView *)createViewWithSize:(CGSize)size
{
    return nil;
}
-(void)setupCamera
{
    CGRect cameraPreViewSize;
    cameraPreViewSize =  _cameraType == MDCAVCameraPreviewAndOutPutImageSizeTypeRectangle?CGRectMake(0, 44, MyKScreenWidth, MyKScreenHeight-44):CGRectMake(0, 0, MyKScreenWidth, MyKScreenHeight);
    self.cameraPreview = [[UIView alloc]initWithFrame:cameraPreViewSize];
    self.cameraPreview.alpha = 0.0f;
    [self addSubview:self.cameraPreview];
    
    
    self.cameraActionBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MyKScreenWidth, 44)];
    self.cameraActionBarClose = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraActionBarClose.frame = CGRectMake(2, 0, 44, 44);
    [self.cameraActionBarClose setImage:[UIImage imageNamed:@"icon-close"] forState:UIControlStateNormal];
    [self.cameraActionBarClose addTarget:self action:@selector(didPressClose) forControlEvents:UIControlEventTouchUpInside];
    
    self.cameraActionBarFlip = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraActionBarFlip.frame = CGRectMake(MyKScreenWidth-54, 0, 44, 44);
    [self.cameraActionBarFlip setImage:[UIImage imageNamed:@"icon-camera-flip"] forState:UIControlStateNormal];
    [self.cameraActionBarFlip addTarget:self action:@selector(didPressCamerFlip) forControlEvents:UIControlEventTouchUpInside];
    
    self.cameraActionBarFlash = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cameraActionBarFlash.frame = CGRectMake(MyKScreenWidth/2-40, 0, 44, 44);
    [self.cameraActionBarFlash setImage:[UIImage imageNamed:@"icon-camera-flash"] forState:UIControlStateNormal];
    [self.cameraActionBarFlash addTarget:self action:@selector(didPressCameraFlash) forControlEvents:UIControlEventTouchUpInside];
    
    self.cameraActionBarFlashLable = [[UILabel alloc]initWithFrame:CGRectMake(MyKScreenWidth/2-6, 0, 80, 44)];
    self.cameraActionBarFlashLable.font = [UIFont systemFontOfSize:18];
    self.cameraActionBarFlashLable.textColor = [UIColor whiteColor];
    self.cameraActionBarFlashLable.text = @"";
    
    [self.cameraActionBar addSubview:self.cameraActionBarClose];
    [self.cameraActionBar addSubview:self.cameraActionBarFlip];
    [self.cameraActionBar addSubview:self.cameraActionBarFlash];
    [self.cameraActionBar addSubview:self.cameraActionBarFlashLable];
    //    [[[[UIApplication sharedApplication]delegate]window] addSubview:self.cameraActionBar];
    [self addSubview:self.cameraActionBar];
    self.captureButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 64, 64)];
    [self.captureButton setImage:[UIImage imageNamed:@"icon-camera-capture"] forState:UIControlStateNormal];
    [self.captureButton addTarget:self action:@selector(didPressCapture) forControlEvents:UIControlEventTouchUpInside];
    self.captureButton.center = CGPointMake(MyKScreenWidth/2, MyKScreenWidth+110);
    self.captureButton.alpha = 0.0f;
    
    [self addSubview:self.captureButton];
    
    [self performSelectorInBackground:@selector(initializeCamera) withObject:nil];
}
-(void)initializeCamera{
    self.captureSession = [[AVCaptureSession alloc]init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    captureVideoPreviewLayer.frame = self.cameraPreview.bounds;
    [self.cameraPreview.layer addSublayer:captureVideoPreviewLayer];
    
    UIView *view = self.cameraPreview;
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            NSError *error = nil;
            if ([device position] == AVCaptureDevicePositionBack) {
                self.backCamera = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                if (!self.backCamera) {
                    NSLog(@"ERROR:trying to open camera:%@",error);
                }
            }
            else{
                self.frontCamera = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                if (!self.frontCamera) {
                    NSLog(@"ERROR:trying to open camera:%@",error);
                }
            }
        }
    }
    if (self.backCamera) {
        [self.captureSession addInput:self.backCamera];
    }
    if (!self.backCamera.device.hasFlash) {
        self.cameraActionBarFlash.hidden = YES;
        self.cameraActionBarFlashLable.hidden = YES;
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *flashString = @"";
            if (self.backCamera.device.flashMode == AVCaptureFlashModeAuto) {
                flashString = @"自动";
            }else if (self.backCamera.device.flashMode == AVCaptureFlashModeOn){
                flashString = @"打开";
            }else{
                flashString = @"关闭";
            }
            self.cameraActionBarFlashLable.text = flashString;
        });
    }
    if (!self.frontCamera) {
        self.cameraActionBarFlip.hidden = YES;
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = [[NSDictionary alloc]initWithObjectsAndKeys:AVVideoCodecJPEG ,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    [self.captureSession addOutput:self.stillImageOutput];
    [self.captureSession startRunning];
}
/**显示或者隐藏相机*/
-(void)showCamera:(BOOL)on{
    if (on) {
        //如果session已经停止了运行，再次启动运行
        if (!self.captureSession.isRunning) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self.captureSession startRunning];
            });
            
        }
        
        //        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
        
        self.captureButton.alpha = 1.0f;
        
        self.backgroundColor = [UIColor blackColor];
        
        self.cameraActionBar.backgroundColor = [UIColor blackColor];
        
        self.cameraPreview.alpha = 1.0f;
    }else{
        //        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
        self.cameraIsShown = NO;
        [self.captureSession stopRunning];
    }
}
/**拍照Action处理*/
-(void)didPressClose{
    if (self.cameraIsShown == NO) {
        //        [self showCamera:NO];
        if (self.delegate && [self.delegate respondsToSelector:@selector(mdcAVCameraViewDidCancle:)]) {
            [self.delegate mdcAVCameraViewDidCancle:self];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(mdcAVCameraViewDidCancle:)]) {
            [self.delegate mdcAVCameraViewDidCancle:self];
        }
        [self.captureSession stopRunning];
        //        [self showCamera:NO];
    }
}
/**切换前后摄像头*/
-(void)didPressCamerFlip{
    if (self.captureSession.inputs[0] == self.backCamera) {
        [self.captureSession removeInput:self.backCamera];
        [self.captureSession addInput:self.frontCamera];
        
        self.cameraActionBarFlash.hidden = !self.frontCamera.device.hasFlash;
        self.cameraActionBarFlashLable.hidden = !self.frontCamera.device.hasFlash;
    }else if (self.captureSession.inputs[0] == self.frontCamera){
        [self.captureSession removeInput:self.frontCamera];
        [self.captureSession addInput:self.backCamera];
        
        self.cameraActionBarFlash.hidden = NO;
        self.cameraActionBarFlashLable.hidden = NO;
    }
}
/**开启关闭闪光灯的方法*/
-(void)didPressCameraFlash{
    AVCaptureDeviceInput *deviceInput = (self.captureSession.inputs[0] == self.backCamera) ? self.backCamera : self.frontCamera;
    AVCaptureDevice *device = deviceInput.device;
    
    if (device.hasFlash) {
        // Start session configuration
        [self.captureSession beginConfiguration];
        [device lockForConfiguration:nil];
        
        if (device.flashMode == AVCaptureFlashModeAuto) {
            device.flashMode = AVCaptureFlashModeOff;
            self.cameraActionBarFlashLable.text =
            @"关闭";
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeAuto;
            self.cameraActionBarFlashLable.text =
            @"自动";
        } else {
            device.flashMode = AVCaptureFlashModeOn;
            self.cameraActionBarFlashLable.text =
            @"打开";
        }
        
        [device unlockForConfiguration];
        [self.captureSession commitConfiguration];
    }
}
/**按下了拍摄按钮*/
-(void)didPressCapture{
    if (!self.captureSession.isRunning) {
        return;
    }
    if (!self.captureSession.isRunning) {
        return;
    }
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqualToString:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    UIDeviceOrientation deviceOriention = [UIDevice currentDevice].orientation;
    AVCaptureVideoOrientation oriention = videoConnection.videoOrientation;
    switch (deviceOriention) {
        case UIDeviceOrientationLandscapeLeft:
            oriention = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            oriention = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationPortrait:
            oriention = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            oriention = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        default:
            break;
    }
    [videoConnection setVideoOrientation:oriention];
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            dispatch_async(dispatch_get_main_queue(), ^{
                //这里这个方法是在拍完照片之后默认地将flash关闭掉
                AVCaptureDeviceInput *deviceInput = (self.captureSession.inputs[0] == self.backCamera) ? self.backCamera : self.frontCamera;
                AVCaptureDevice *device = deviceInput.device;
                
                if (device.hasFlash) {
                    // Start session configuration
                    [self.captureSession beginConfiguration];
                    [device lockForConfiguration:nil];
                    
                    if ((device.flashMode == AVCaptureFlashModeAuto) || (device.flashMode = AVCaptureFlashModeOn)) {
                        device.flashMode = AVCaptureFlashModeOff;
                        self.cameraActionBarFlashLable.text =
                        @"关闭";
                    }
                    [device unlockForConfiguration];
                    [self.captureSession commitConfiguration];
                }
                
            });
            //产出的图片的宽度高度都是KScreenWidth
            if (_cameraType == MDCAVCameraPreviewAndOutPutImageSizeTypeRectangle) {
                CGRect outPutImageSize;
                outPutImageSize =  _cameraType == MDCAVCameraPreviewAndOutPutImageSizeTypeRectangle?CGRectMake(0, 44, MyKScreenWidth, MyKScreenHeight-44):CGRectMake(0, 0, MyKScreenWidth, MyKScreenWidth);
//                self.captureImage = [UIImage imageWithData:imageData];
                
                self.captureImage = [UIImage imageWithData:imageData];//[self rectImageWithImage:[UIImage imageWithData:imageData] scaledToSize:CGSizeMake(MyKScreenWidth, MyKScreenHeight)];
            }else{
                self.captureImage = [self rectImageWithImage:[UIImage imageWithData:imageData] scaledToSize:CGSizeMake(MyKScreenWidth, MyKScreenHeight)];
            }
            [self.captureSession stopRunning];
            if (self.delegate && [self.delegate respondsToSelector:@selector(mdcAVCameraView:captureImage:)]) {
                [self.delegate mdcAVCameraView:self captureImage:self.captureImage];
            }
        }
        
        
    }];
}

//这个产出正方形的图片
-(UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    double ratio;
    double delta;
    CGPoint offset;
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    if (image.size.width > image.size.height) {
        ratio = newSize.height / image.size.height;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (image.size.width * ratio),
                                 (image.size.height * ratio));
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
-(UIImage *)rectImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    double ratio;
    double delta;
    CGPoint offset;
    CGSize sz = CGSizeMake(newSize.width, newSize.height);
    
    if (image.size.width > image.size.height) {
        ratio = newSize.height / image.size.height;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
    //                                 (image.size.width * ratio),
    //                                 (image.size.height * ratio));
    
    CGRect clipRect = CGRectMake(0, 64, MyKScreenWidth, image.size.width/image.size.height * MyKScreenHeight);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    
    
    
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end

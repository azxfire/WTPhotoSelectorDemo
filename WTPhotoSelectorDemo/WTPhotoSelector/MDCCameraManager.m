//
//  MDCCameraManager.m
//  MDCPhotoSelector
//
//  Created by taowang on 15/7/20.
//  Copyright © 2015年 MDC. All rights reserved.
//

#import "MDCCameraManager.h"
#import "UIImage+UserPhoto.h"
@implementation MDCCameraManager
{
    AVCaptureSession *_captureSession;
    AVCaptureDeviceInput *_backCamera;
    AVCaptureDeviceInput *_frontCamera;
    AVCaptureStillImageOutput *_stillImageOutPut;
    
    AVCaptureVideoPreviewLayer *_previewLayer;
    BOOL _running;
    
    CALayer *_crosshairLayer;
    NSTimer *_tapToFocusTimer;
}
@dynamic currentInput;
+ (MDCCameraManager *)shareInstance
{
    static MDCCameraManager *_shareInstance = nil;
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _shareInstance = [[self alloc]init];
    });
    return _shareInstance;
}
-(instancetype)init
{
    self = [super init];
    if (self) {
        _captureSession = [[AVCaptureSession alloc]init];
        _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        [self initializeCamera];
    }
    return self;
}
- (BOOL)hasAuthorizedCameraAccess
{
//    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    return authStatus == AVAuthorizationStatusAuthorized;
    //下面的方法在67都可以
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:nil];
    if (!captureInput) {
        return NO;
    } else {
        return YES;
    }
}
- (BOOL)hasCamera
{
    return [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count > 0;
}
- (void)addPreviewSublayerToLayer:(CALayer *)layer completion:(void (^)(void))completion
{
    if (_previewLayer) {
        [_previewLayer removeFromSuperlayer];
    }else
    {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_captureSession];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    [layer addSublayer:_previewLayer];
    _previewLayer.frame = layer.bounds;
    
    if (_running) {
        if (completion)
            completion();
    }else{
            _running = YES;
            //后台线程执行启动session的耗时操作
           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
               [_captureSession startRunning];
               //回到主线程反馈需要和UI交互的block函数
               dispatch_async(dispatch_get_main_queue(), ^{
                   if (completion) {
                       completion();
                   }
               });
           });
        }
    
    
}
- (void)captureWithCompletion:(void (^)(UIImage *))completion
{
    AVCaptureConnection *videoConnection;
    for (AVCaptureConnection *connection in _stillImageOutPut.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqualToString:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    if (!videoConnection) {
        if (completion) completion(nil);
        return;
    }
    [_stillImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            if (completion) completion(nil);
            return;
        }else{
            NSData *imageData =
            [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [[UIImage imageWithData:imageData] userPhotoImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) completion(image);
            });
        }
    }];
}
-(void)cycleFlashModes
{
    AVCaptureDevice *device = [self currentInput].device;
    if (!device.hasFlash) {
        return;
    }
    
    [_captureSession beginConfiguration];
    [device lockForConfiguration:nil];
    switch (device.flashMode) {
        case AVCaptureFlashModeAuto:{
            device.flashMode = AVCaptureFlashModeOff;
            break;
        }
        case AVCaptureFlashModeOn: {
            device.flashMode = AVCaptureFlashModeAuto;
            
            break;
        }
        case AVCaptureFlashModeOff: {
            device.flashMode = AVCaptureFlashModeOn;
            
            break;
        }
    }
    [device unlockForConfiguration];
    [_captureSession commitConfiguration];
    
}
- (void)cycleInputCamera
{
    AVCaptureDeviceInput *currentInput = (AVCaptureDeviceInput *)_captureSession.inputs[0];
    [_captureSession removeInput:currentInput];
    if (currentInput == _backCamera && _frontCamera) {
        currentInput = _frontCamera;
    }else if (currentInput == _frontCamera && _backCamera){
        currentInput = _backCamera;
    }
    [_captureSession addInput:currentInput];
}
- (void)didTapPointInPreviewLayer:(CGPoint)point
{
    CGPoint pointOfInterest = [_previewLayer captureDevicePointOfInterestForPoint:point];
    AVCaptureDevice *device = [self currentInput].device;
    if (device.isFocusPointOfInterestSupported) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            [device setFocusMode:AVCaptureFocusModeAutoFocus];
            [device setFocusPointOfInterest:pointOfInterest];
            if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            }
            [device setExposurePointOfInterest:pointOfInterest];
            [device unlockForConfiguration];
        }
    }
    [_tapToFocusTimer invalidate];
    _tapToFocusTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                                        target:self
                                                      selector:@selector(drawBoxAtPoint:)
                                                      userInfo:@{@"point":[NSValue valueWithCGPoint:point]}
                                                       repeats:YES];
}
-(void)startRunningLivePreview
{
    if (_running) {
        return;
    }
    _running = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_captureSession startRunning];
    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [_captureSession startRunning];
//    });
}
-(void)stopRunningLivePreview
{
    if (_running) {
        return;
    }
    _running = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_captureSession stopRunning];
    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        
//    });
}
#pragma mark -Accessors
- (AVCaptureDeviceInput *)currentInput
{
    if ([_captureSession.inputs count]) {
        return _captureSession.inputs[0];
    }else{
        return nil;
    }
}
#pragma mark -Private
- (void)drawBoxAtPoint:(NSTimer *)timer
{
    CGPoint point;
    [timer.userInfo[@"point"] getValue:&point];
    
    AVCaptureDevice *device = [self currentInput].device;
    if (device.adjustingExposure || device.adjustingFocus || device.adjustingWhiteBalance) {
        if (_crosshairLayer.superlayer && CGPointEqualToPoint(_crosshairLayer.position, point)) {
            
        } else {
            
            CGFloat animationDuration = 0.2f;
            if (!_crosshairLayer) {
                UIImageView *crosshairImageView =
                [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-camera-crosshair"]];
                crosshairImageView.alpha = 0.7f;
                _crosshairLayer = crosshairImageView.layer;
                animationDuration = 0.f;
            }
            
            CABasicAnimation *crosshairAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
            crosshairAnimation.fromValue = [NSValue valueWithCGPoint:_crosshairLayer.position];
            crosshairAnimation.toValue = [NSValue valueWithCGPoint:point];
            crosshairAnimation.duration = animationDuration;
            crosshairAnimation.autoreverses = NO;
            crosshairAnimation.repeatCount = 0;
            [_crosshairLayer addAnimation:crosshairAnimation forKey:@"crosshairAnimation"];
        }
    } else {
        
        [_crosshairLayer removeFromSuperlayer];
        [_tapToFocusTimer invalidate];
        _tapToFocusTimer = nil;
    }
}
- (void)initializeCamera {
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            NSError *error = nil;
            if ([device position] == AVCaptureDevicePositionBack) {
                _backCamera = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                
                if (!_backCamera) {
                }
            }
            else {
                _frontCamera = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];;
                if (!_frontCamera) {
                }
            }
        }
    }
    
    if (_backCamera) {
        [_captureSession addInput:_backCamera];
    } else if (_frontCamera) {
        [_captureSession addInput:_frontCamera];
    }
    
    // If we have both devices, enable flip.
    if (_backCamera && _frontCamera) {
        _canFlip = YES;
    }
    
    _stillImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    _stillImageOutPut.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
    [_captureSession addOutput:_stillImageOutPut];
}
@end

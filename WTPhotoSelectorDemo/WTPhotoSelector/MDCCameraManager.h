//
//  MDCCameraManager.h
//  MDCPhotoSelector
//
//  Created by taowang on 15/7/20.
//  Copyright © 2015年 MDC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface MDCCameraManager : NSObject
+ (MDCCameraManager*)shareInstance;

@property (nonatomic, readonly) BOOL canFlip;
@property (nonatomic, readonly) AVCaptureDeviceInput *currentInput;

- (BOOL)hasAuthorizedCameraAccess;
- (BOOL)hasCamera;

- (void)addPreviewSublayerToLayer:(CALayer*)layer completion:(void(^)(void))completion;

- (void)captureWithCompletion:(void(^)(UIImage* captureImage))completion;
- (void)cycleFlashModes;
- (void)cycleInputCamera;

- (void)didTapPointInPreviewLayer:(CGPoint)point;

- (void)startRunningLivePreview;
- (void)stopRunningLivePreview;
@end

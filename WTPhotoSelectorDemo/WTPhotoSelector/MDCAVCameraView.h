//
//  MDCAVCameraView.h
//  ImageChooseLibrary
//
//  Created by taowang on 15/7/21.
//  Copyright © 2015年 MDC. All rights reserved.
//
#import <UIKit/UIKit.h>
enum MDCAVCameraPreviewAndOutPutImageSizeType
{
    MDCAVCameraPreviewAndOutPutImageSizeTypeSquare,
    MDCAVCameraPreviewAndOutPutImageSizeTypeRectangle,
};
@class MDCAVCameraView;
@protocol MDCAVCameraViewDelegate <NSObject>
@required
- (void)mdcAVCameraView:(MDCAVCameraView *)cameraView captureImage:(UIImage *)image;
- (void)mdcAVCameraViewDidCancle:(MDCAVCameraView *)cameraView;

@end
@interface MDCAVCameraView : UIView
@property (nonatomic, weak) id<MDCAVCameraViewDelegate> delegate;
@property (nonatomic, assign) enum MDCAVCameraPreviewAndOutPutImageSizeType cameraType;
- (void)showCamera:(BOOL)on;
- (instancetype)initCameraWithOutPutImageSizeType:(enum MDCAVCameraPreviewAndOutPutImageSizeType)type;
@end

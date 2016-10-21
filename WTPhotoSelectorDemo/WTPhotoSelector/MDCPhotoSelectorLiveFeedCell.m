//
//  MDCPhotoSelectorLiveFeedCell.m
//  MDCPhotoSelector
//
//  Created by taowang on 15/7/20.
//  Copyright © 2015年 MDC. All rights reserved.
//

#import "MDCPhotoSelectorLiveFeedCell.h"
#import <AVFoundation/AVFoundation.h>
#import "MDCCameraManager.h"
#import "UIImage+Color.h"
#import "WTPhotoSelectorMarco.h"
static const CGFloat kHeight = 160.f;
static const CGFloat kWidth = 160.f;

static const CGFloat kOverlayAlpha = 0.6f;
@implementation MDCPhotoSelectorLiveFeed
@end
@implementation MDCPhotoSelectorLiveFeedCell
{
    CALayer *_capturePreviewSuper;
    UIImageView *_cameraImageView;
    UIView *_maskView;
    UIButton *_titleButton;
}
-(instancetype)init
{
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
    }
    return self;
}
- (void)createView
{
    self.clipsToBounds = YES;
    _capturePreviewSuper = [[CALayer alloc]init];
    _capturePreviewSuper.frame = CGRectMake(0, 0, kWidth, kHeight);
    _capturePreviewSuper.opacity = 0.0f;
    [self.layer addSublayer:_capturePreviewSuper];
    
    _maskView = [[UIView alloc]initWithFrame:CGRectZero];
    _maskView.alpha = kOverlayAlpha;
    _maskView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_maskView];
    _cameraImageView = [[UIImageView alloc]init];
    if (MyKScreenHeight<568) {
        _cameraImageView.image = [[UIImage imageNamed:@"icon-camera"] imageWithColor:[UIColor lightGrayColor]];
    }else
    {
      _cameraImageView.image = [UIImage imageNamed:@"icon-camera"];
    }
    [self addSubview:_cameraImageView];
    
    _titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_titleButton setTitle:@"拍照" forState:UIControlStateNormal];
//    [self addSubview:_titleButton];
}
-(void)layoutSubviews
{
    _capturePreviewSuper.frame = self.bounds;
    _maskView.frame = self.bounds;
    _cameraImageView.frame = CGRectMake(0, 0, 57, 48);
    _cameraImageView.center = self.center;
//    _cameraImageView.contentMode =
    
    _titleButton.frame = ({
        CGRect frame;
        frame.size.height = 20;
        frame.size.width = self.bounds.size.width;
        frame.origin.x = 0;
        frame.origin.y = (self.bounds.size.width -40);
        frame;
    });
}
-(CGSize)sizeThatFits:(CGSize)size
{
    return [[self class]desiredSize];
}
-(void)startCaptureSession
{
    if (![[MDCCameraManager shareInstance]hasAuthorizedCameraAccess]) {
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MDCCameraManager shareInstance]addPreviewSublayerToLayer:_capturePreviewSuper completion:^{
//            _cameraImageView.image = [UIImage imageNamed:@"icon-camera"];
            [UIView animateWithDuration:3.0f animations:^{
                _capturePreviewSuper.opacity = 1.0f;
            }];
        }];
    });
}
+ (CGSize)desiredSize
{
    return CGSizeMake(kWidth, kHeight);
}
@end

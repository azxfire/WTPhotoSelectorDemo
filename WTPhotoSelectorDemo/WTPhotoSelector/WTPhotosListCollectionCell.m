//
//  WTPhotosListCollectionCell.m
//  zwy
//
//  Created by taowang on 2016/7/28.
//  Copyright © 2016年 zwy. All rights reserved.
//

#import "WTPhotosListCollectionCell.h"
#import "WTPhotoManager.h"
#import "ZWYHelper.h"
#import "WTPhotoSelectorMarco.h"
@implementation WTPhotosListCollectionCell
{
    UIImageView *_imageView;
}
- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}
- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self createView];
        
    }
    return self;
}
//- (void)setRepresentedAssetIdentifier:(NSString *)representedAssetIdentifier{
//    _representedAssetIdentifier = representedAssetIdentifier;
//}
- (void)createView{
    _imageView = [UIImageView new];
    [self addSubview:_imageView];
    
    _blackBlurView = [UIView new];
    _blackBlurView.hidden = YES;
    _blackBlurView.backgroundColor = [UIColor blackColor];
    _blackBlurView.alpha = 0.5f;
    [self addSubview:_blackBlurView];
    
    _clickButton = [UIButton new];
    [_clickButton addTarget:self action:@selector(chooseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_clickButton setImage:[UIImage imageNamed:@"compose_photo_preview_default"] forState:UIControlStateNormal];
    [self addSubview:_clickButton];
}
- (void)layoutSubviews{
    _imageView.frame = self.bounds;
    _blackBlurView.frame = self.bounds;
    _clickButton.frame = CGRectMake((MyKScreenWidth / 3) - 35, 5, 30, 30);
}
- (void)prepareForReuse {
    [super prepareForReuse];
    _imageView.image = nil;
    _representedAssetIdentifier = nil;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    _thumbnailImage = thumbnailImage;
    _imageView.image = thumbnailImage;
}
- (void)setAsset:(PHAsset *)asset{
    _asset = asset;
    _representedAssetIdentifier = asset.localIdentifier;
    
    if ([[WTPhotoManager sharedInstance].imageLocalIdentifierArray containsObject:asset]){
        [_clickButton setImage:[UIImage imageNamed:@"compose_photo_preview_right"] forState:UIControlStateNormal];
        _blackBlurView.hidden = NO;
    }else{
        [_clickButton setImage:[UIImage imageNamed:@"compose_photo_preview_default"] forState:UIControlStateNormal];
        _blackBlurView.hidden = YES;
    }
}
- (void)setLivePhotoBadgeImage:(UIImage *)livePhotoBadgeImage {
    _livePhotoBadgeImage = livePhotoBadgeImage;
}

- (void)chooseButtonClick:(id)sender {
    
    if ([WTPhotoManager sharedInstance].thumbnailImageArray.count < [WTPhotoManager sharedInstance].maxSelectedPhotoCount) {
        
        if (_blackBlurView.hidden) {
            
            [[WTPhotoManager sharedInstance] addThumbNail:_thumbnailImage];
            [[WTPhotoManager sharedInstance] addImageLocalIdentifier:_asset];
            
        }else{
            [[WTPhotoManager sharedInstance] deleteThumbNail:_thumbnailImage];
            [[WTPhotoManager sharedInstance] deleteImageLocalIdentifier:_asset];
        }
        _blackBlurView.hidden = !_blackBlurView.hidden;
        
        [_clickButton setImage:_blackBlurView.hidden ? [UIImage imageNamed:@"compose_photo_preview_default"] :  [UIImage imageNamed:@"compose_photo_preview_right"] forState:UIControlStateNormal];
    }else if ([WTPhotoManager sharedInstance].thumbnailImageArray.count == [WTPhotoManager sharedInstance].maxSelectedPhotoCount){
        if (_blackBlurView.hidden) {
            
//            [[ZWYHelper sharedHelper] addAlertViewControllerToView:[ZWYHelper rootTabbarViewController].view withClickBlock:^(int clickInt) {
//                
//            } title:@"" content:[NSString stringWithFormat:@"图片不能大于%d张", [WTPhotoManager sharedInstance].maxSelectedPhotoCount] cancleStr:@"" confirmStr:@"确定" animated:YES];
            
        }else{
            [[WTPhotoManager sharedInstance] deleteThumbNail:_thumbnailImage];
            [[WTPhotoManager sharedInstance] deleteImageLocalIdentifier:_asset];
            
            _blackBlurView.hidden = !_blackBlurView.hidden;
            
            [_clickButton setImage:_blackBlurView.hidden ? [UIImage imageNamed:@"compose_photo_preview_default"] :  [UIImage imageNamed:@"compose_photo_preview_right"] forState:UIControlStateNormal];
        }
        
    }
    else{
        
//        [[ZWYHelper sharedHelper] addAlertViewControllerToView:[ZWYHelper rootTabbarViewController].view withClickBlock:^(int clickInt) {
//            
//        } title:@"" content:[NSString stringWithFormat:@"图片不能大于%d张", [WTPhotoManager sharedInstance].maxSelectedPhotoCount] cancleStr:@"" confirmStr:@"确定" animated:YES];
    }
    
}
@end

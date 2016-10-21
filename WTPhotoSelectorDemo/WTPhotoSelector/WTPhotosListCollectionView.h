//
//  WTPhotosListCollectionView.h
//  zwy
//
//  Created by taowang on 2016/7/28.
//  Copyright © 2016年 zwy. All rights reserved.
//

#import <UIKit/UIKit.h>
@import UIKit;
@import Photos;
typedef enum
{
    WTPhotosListCollectionViewTypeContentImage,//选择内容图片
    WTPhotosListCollectionViewTypeHeaderImage,//选择头像图片
}WTPhotosListCollectionViewType;
@interface WTPhotosListCollectionView : UIViewController
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout showCameraView:(BOOL)show;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout showCameraView:(BOOL)show type:(WTPhotosListCollectionViewType)type;
@property (nonatomic, copy) void (^didChooseImagesSuccessBlock)();
@property (nonatomic, copy) void (^didChooseHeadImageSuccessBlock)(UIImage *headImage);
@end

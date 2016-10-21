//
//  WTPhotoManager.h
//  WTPhotoDemo
//
//  Created by taowang on 2016/7/27.
//  Copyright © 2016年 zwy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTPhotosListCollectionView.h"
@import UIKit;
@import Photos;
@interface WTPhotoCellModel : NSObject
@property (nonatomic, strong) UIImage *thumbnailImage;//缩略图
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) BOOL isLivePhoto;
- (instancetype)initWithAsset:(PHAsset *)asset imageSize:(CGSize)imageSize;
@end
static NSString * const WTPhotoLibraryDidChangeNotification = @"WTPhotoLibraryDidChangeNotification";
@import Photos;
@interface WTPhotoManager : NSObject
+ (instancetype)sharedInstance;
- (NSArray *)sectionFetchResult;
@property (nonatomic, strong, readonly) NSMutableArray *thumbnailImageArray;//缩略图数组
@property (nonatomic, strong, readonly) NSMutableArray *imageLocalIdentifierArray;//局部标识图
@property (nonatomic, assign) int maxSelectedPhotoCount;//可选的图片最大数量
- (void)clearData;//清除缓存
- (void)stopCachingImagesForAllAssets;
- (void)addThumbNail:(UIImage *)thumbNail;//添加缩略图
- (void)deleteThumbNail:(UIImage *)thumbNail;//删除缩略图
- (void)addImageLocalIdentifier:(PHAsset *)asset;//
- (void)deleteImageLocalIdentifier:(PHAsset *)asset;
- (void)requestImageForAsset:(PHAsset *)asset imageSize:(CGSize)targetSize successBlock:(void (^)(UIImage *image))block;//
- (void)startCachingImagesForAssets:(NSArray *)assetsToStartCaching
                         targetSize:(CGSize)size;
- (void)stopCachingImagesForAssets:(NSArray *)assetsToStopCaching
                        targetSize:(CGSize)size;
//获取选择图片数组的原图数组
- (void)selectedImagesArraySuccessBlock:(void (^)(NSMutableArray *imagesArr))successBlock;
/*contentBlock 选择内容图片的回调函数
 *headBlock 选择头像的回调函数
 **/
- (void)showAllPhotoWithTitle:(NSString *)title maxSelectedCount:(int)maxCount contentImagesuccessBlock:(void (^)())contentBlock headImagesuccessBlock:(void (^)(UIImage *head))headBlock type:(WTPhotosListCollectionViewType)type;
@end

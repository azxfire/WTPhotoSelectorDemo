//
//  WTPhotosListCollectionCell.h
//  zwy
//
//  Created by taowang on 2016/7/28.
//  Copyright © 2016年 zwy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset;
@interface WTPhotosListCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *livePhotoBadgeImage;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIView *blackBlurView;
@property (nonatomic, strong) UIButton *clickButton;;
@end

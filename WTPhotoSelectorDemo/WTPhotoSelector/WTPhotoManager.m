//
//  WTPhotoManager.m
//  WTPhotoDemo
//
//  Created by taowang on 2016/7/27.
//  Copyright © 2016年 zwy. All rights reserved.
//

#import "WTPhotoManager.h"
#import "ZWYHelper.h"
@implementation WTPhotoCellModel
- (instancetype)initWithAsset:(PHAsset *)asset imageSize:(CGSize)imageSize{
    self = [super init];
    if (self) {
        _representedAssetIdentifier = asset.localIdentifier;
        if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
            _isLivePhoto = YES;
        }
        [[WTPhotoManager sharedInstance] requestImageForAsset:asset imageSize:imageSize successBlock:^(UIImage *image) {
            if ([_representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                _thumbnailImage = image;
            }
        }];
    }
    return self;
}
@end
@interface WTPhotoManager()<PHPhotoLibraryChangeObserver>
@end
@implementation WTPhotoManager{
    NSArray *_sectionFetchResults;
    NSArray *_sectionLocalizedTitles;
    PHCachingImageManager *_imageManager;
}
- (void)clearData{
    [self stopCachingImagesForAllAssets];
    [_thumbnailImageArray removeAllObjects];
    [_imageLocalIdentifierArray removeAllObjects];
}
- (void)stopCachingImagesForAllAssets{
    [_imageManager stopCachingImagesForAllAssets];
}
+ (instancetype)sharedInstance{
    static WTPhotoManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc]init];
        [_sharedInstance initPhotos];
    });
    return _sharedInstance;
}
- (void)setMaxSelectedPhotoCount:(int)maxSelectedPhotoCount{
    _maxSelectedPhotoCount = maxSelectedPhotoCount;
}
- (void)initPhotos{
    if (!_thumbnailImageArray) {
        _thumbnailImageArray = [NSMutableArray array];
    }
    if (!_imageLocalIdentifierArray) {
        _imageLocalIdentifierArray = [NSMutableArray array];
    }
    
    _maxSelectedPhotoCount = 9;
    _imageManager = [[PHCachingImageManager alloc]init];
    
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc]init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    _sectionFetchResults = @[allPhotos, smartAlbums, topLevelUserCollections];
    _sectionLocalizedTitles = @[@"", NSLocalizedString(@"Smart Albums", @""), NSLocalizedString(@"Albums", @"")];
    
    [[PHPhotoLibrary sharedPhotoLibrary]registerChangeObserver:self];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Loop through the section fetch results, replacing any fetch results that have been updated.
        NSMutableArray *updatedSectionFetchResults = [[[WTPhotoManager sharedInstance]sectionFetchResult] mutableCopy];
        __block BOOL reloadRequired = NO;
        
        [[[WTPhotoManager sharedInstance]sectionFetchResult] enumerateObjectsUsingBlock:^(PHFetchResult *collectionsFetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:collectionsFetchResult];
            
            if (changeDetails != nil) {
                [updatedSectionFetchResults replaceObjectAtIndex:index withObject:[changeDetails fetchResultAfterChanges]];
                reloadRequired = YES;
            }
        }];
        
        if (reloadRequired) {
            _sectionFetchResults = updatedSectionFetchResults;
            [[NSNotificationCenter defaultCenter] postNotificationName:WTPhotoLibraryDidChangeNotification object:changeInstance];
        }
        
    });
}
- (NSArray *)sectionFetchResult{
    return _sectionFetchResults;
}
- (void)addThumbNail:(UIImage *)thumbNail{
    [_thumbnailImageArray addObject:thumbNail];
}
- (void)deleteThumbNail:(UIImage *)thumbNail{
    [_thumbnailImageArray removeObject:thumbNail];
}
- (void)addImageLocalIdentifier:(PHAsset *)localIdentifier{
    [_imageLocalIdentifierArray insertObject:localIdentifier atIndex:_imageLocalIdentifierArray.count];
//    [self.selectedAssets insertObject:asset atIndex:self.selectedAssets.count]
}
- (void)deleteImageLocalIdentifier:(PHAsset *)localIdentifier{
    [_imageLocalIdentifierArray removeObject:localIdentifier];
}
- (void)requestImageForAsset:(PHAsset *)asset imageSize:(CGSize)targetSize successBlock:(void (^)(UIImage *))block{
    [_imageManager requestImageForAsset:asset
                                  targetSize:targetSize
                                 contentMode:PHImageContentModeAspectFill
                                     options:nil
                               resultHandler:^(UIImage *result, NSDictionary *info) {
                                   if (block) {
                                       block(result);
                                   }
                                   
                               }];

}
- (void)startCachingImagesForAssets:(NSArray *)assetsToStartCaching targetSize:(CGSize)size{
        [_imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:size
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
}
- (void)stopCachingImagesForAssets:(NSArray *)assetsToStopCaching targetSize:(CGSize)size{
        [_imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:size
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
}
- (void)selectedImagesArraySuccessBlock:(void (^)(NSMutableArray *))successBlock{
    
    NSArray *savedAssets = [[WTPhotoManager sharedInstance] imageLocalIdentifierArray];
    
    
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = YES;
    option.networkAccessAllowed = YES;

    NSMutableArray *arr = [NSMutableArray arrayWithArray:savedAssets];

    __block NSMutableSet *setA = [NSMutableSet setWithArray:arr];
    NSSet *setB = [NSSet setWithArray:savedAssets];

    for (int i = 0 ; i < savedAssets.count; i++) {
        PHAsset *asset = savedAssets[i];
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
            
        };
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(400, 400) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage *result, NSDictionary *info) {
    
            // Check if the request was successful.
            if (!result) {
                return;
            }
           
            NSInteger index = [savedAssets indexOfObject:asset];
            
            [arr replaceObjectAtIndex:index withObject:result];
            
            setA = [NSMutableSet setWithArray:arr];
        
            [setA intersectSet:setB];
            
            if (setA.count == 0) {
               successBlock(arr);
            }
        }];
    }
    
}
- (void)updateStaticImageWithAsset:(PHAsset *)asset{
    // Prepare the options to pass when fetching the live photo.
    
}
- (void)showAllPhotoWithTitle:(NSString *)title maxSelectedCount:(int)maxCount contentImagesuccessBlock:(void (^)())contentBlock headImagesuccessBlock:(void (^)(UIImage *))headBlock type:(WTPhotosListCollectionViewType)type{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted)
                {
                    //                    NSLog(@"User Granted");
                }
                else
                {
                    //                    NSLog(@"User Denied");
                }
            }];
            break;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
        {
            UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"相机授权" message:@"无法查看照片！请在系统“设置-隐私-照片/相机”选项中打开债无忧的相册权限" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
            [alterView show];
            return;
            break;
        }
            
        default:
        {
            //拍照
            //从相册获取
            break;
            
        }
    }

    
    self.maxSelectedPhotoCount = maxCount;
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    WTPhotosListCollectionView *assetGridViewController = [[WTPhotosListCollectionView alloc]initWithCollectionViewLayout:layout showCameraView:YES type:type];
    assetGridViewController.title = title;
    PHFetchResult *fetchResult = [[[WTPhotoManager sharedInstance]sectionFetchResult]firstObject];
    assetGridViewController.assetsFetchResults = fetchResult;
    
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    [nav pushViewController:assetGridViewController animated:YES];
    
    
    assetGridViewController.didChooseHeadImageSuccessBlock = ^(UIImage *image){
        if (headBlock) {
            headBlock(image);
        }
    };
}
@end

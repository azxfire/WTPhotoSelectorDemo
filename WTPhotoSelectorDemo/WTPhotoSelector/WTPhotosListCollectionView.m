//
//  WTPhotosListCollectionView.m
//  zwy
//
//  Created by taowang on 2016/7/28.
//  Copyright © 2016年 zwy. All rights reserved.
//

#import "WTPhotosListCollectionView.h"
#import "WTPhotosListCollectionCell.h"
#import "WTPhotoManager.h"
#import "NSIndexSet+Convenience.h"
#import "UICollectionView+Convenience.h"
#import "WTPhotoSelectorMarco.h"
#import "MDCPhotoSelectorLiveFeedCell.h"
#import "ZWYHelper.h"
#import "MDCCameraManager.h"
#import "MDCAVCameraView.h"
@import PhotosUI;
@interface WTPhotosListCollectionView ()<PHPhotoLibraryChangeObserver, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,MDCAVCameraViewDelegate>
@property CGRect previousPreheatRect;
@end

@implementation WTPhotosListCollectionView
{
    UICollectionView *_collectionView;
    BOOL _show;
    MDCAVCameraView      *_cameraView;
    WTPhotosListCollectionViewType _type;
}
static NSString * const CellReuseIdentifier = @"WTPhotosListCollectionCell";
static NSString * const LiveCellReuseIdentifier = @"MDCPhotoSelectorLiveFeedCell";
static CGSize AssetGridThumbnailSize;
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout showCameraView:(BOOL)show type:(WTPhotosListCollectionViewType)type{
    _type = type;
    return [self initWithCollectionViewLayout:layout showCameraView:show];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        
    } completion:^(BOOL finished) {
        
    }];
}
-(void)viewDidDisappear:(BOOL)animated{
    _cameraView.alpha = 0.0f;
}
- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout showCameraView:(BOOL)show{
    
    self = [super init];
    if (self) {
        _show = show;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, MyKScreenWidth, MyKScreenHeight - 15) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    return self;
}
- (void)viewDidLoad{
    
    [super viewDidLoad];
    [_collectionView registerClass:[WTPhotosListCollectionCell class] forCellWithReuseIdentifier:CellReuseIdentifier];
    
    [_collectionView registerClass:[MDCPhotoSelectorLiveFeedCell class] forCellWithReuseIdentifier:LiveCellReuseIdentifier];
    
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    self.previousPreheatRect = CGRectZero;
    
    
    UIBarButtonItem *rightBtnItem =
    [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"zwy_nav_back_image"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = rightBtnItem;
}
- (void)back{
    [self.navigationController popViewControllerAnimated:YES];
    if (_didChooseImagesSuccessBlock) {
        _didChooseImagesSuccessBlock();
    }
}
- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_cameraView.alpha) {
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize =  ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize;
    
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    if (!self.assetCollection || [self.assetCollection canPerformEditOperation:PHCollectionEditOperationAddContent]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:0 target:self action:@selector(doneClick:)];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Begin caching assets in and around collection view's visible rect.
    [self updateCachedAssets];
}
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Check if there are changes to the assets we are showing.
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.assetsFetchResults];
    if (collectionChanges == nil) {
        return;
    }
    
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        self.assetsFetchResults = [collectionChanges fetchResultAfterChanges];
        
        UICollectionView *collectionView = _collectionView;
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
            // Reload the collection view if the incremental diffs are not available
            [collectionView reloadData];
            
        } else {
            /*
             Tell the collection view to animate insertions and deletions if we
             have incremental diffs.
             */
            [collectionView performBatchUpdates:^{
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                if ([removedIndexes count] > 0) {
                    [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                if ([insertedIndexes count] > 0) {
                    [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
                
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                if ([changedIndexes count] > 0) {
                    [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                }
            } completion:NULL];
        }
        
        [[WTPhotoManager sharedInstance]stopCachingImagesForAllAssets];
        self.previousPreheatRect = CGRectZero;
    });
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _show ? self.assetsFetchResults.count + 1 : self.assetsFetchResults.count;
   
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && _show) {
        
        MDCPhotoSelectorLiveFeedCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:LiveCellReuseIdentifier
                                                  forIndexPath:indexPath];
        
            if (MyKScreenHeight >= 568) {
                [cell startCaptureSession];
            }

        return cell;
    }else{
        PHAsset *asset = self.assetsFetchResults[_show ? indexPath.item - 1 : indexPath.row];
        
        // Dequeue an AAPLGridViewCell.
        WTPhotosListCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentifier forIndexPath:indexPath];
        cell.asset = asset;
        if (_type == WTPhotosListCollectionViewTypeHeaderImage) {
            cell.clickButton.hidden = YES;
        }
        // Add a badge to the cell if the PHAsset represents a Live Photo.
        if (asset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
            // Add Badge Image to the cell to denote that the asset is a Live Photo.
            UIImage *badge = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
            cell.livePhotoBadgeImage = badge;
        }
        
        [[WTPhotoManager sharedInstance] requestImageForAsset:asset imageSize:AssetGridThumbnailSize successBlock:^(UIImage *image) {
            if ([cell.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
                cell.thumbnailImage = image;
            }
        }];
        //
        return cell;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.bounds.size.width / 3, collectionView.bounds.size.width / 3);
}
- (void)showNotifyMessage{
//    [[ZWYHelper sharedHelper] addAlertViewControllerToView:[ZWYHelper rootTabbarViewController].view withClickBlock:^(int clickInt) {
//        
//    } title:@"" content:[NSString stringWithFormat:@"图片不能大于%d张", [WTPhotoManager sharedInstance].maxSelectedPhotoCount] cancleStr:@"" confirmStr:@"确定" animated:YES];;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0 ) {
        if ([WTPhotoManager sharedInstance].thumbnailImageArray.count >= [WTPhotoManager sharedInstance].maxSelectedPhotoCount) {
            
            [self showNotifyMessage];
            return;
        }
        if (![[MDCCameraManager shareInstance]hasAuthorizedCameraAccess]) {
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"请到 手机设置 -> 隐私 -> 相机，允许债无忧使用您的相机" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
        [self initialCamera];
        
        [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [_cameraView showCamera:YES];
            [UIView animateWithDuration:0.5f animations:^{
                _cameraView.alpha = 1.0f;
                [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            }];
        } completion:^(BOOL finished) {
            
        }];

    }else{
        
        if (_type == WTPhotosListCollectionViewTypeHeaderImage) {
            PHAsset *asset = self.assetsFetchResults[_show ? indexPath.item - 1 : indexPath.row];
            
            [[WTPhotoManager sharedInstance] addImageLocalIdentifier:asset];
            [[WTPhotoManager sharedInstance] selectedImagesArraySuccessBlock:^(NSArray *imagesArr) {
                
                [self.navigationController popViewControllerAnimated:NO];
                if (_didChooseHeadImageSuccessBlock) {
                    _didChooseHeadImageSuccessBlock([imagesArr firstObject]);
                    
                    [[WTPhotoManager sharedInstance]clearData];
                }
            }];
        }
        
    }
}
- (void)initialCamera
{
    _cameraView = [[MDCAVCameraView alloc]initCameraWithOutPutImageSizeType:MDCAVCameraPreviewAndOutPutImageSizeTypeRectangle];
    _cameraView.frame = CGRectMake(0, 0, MyKScreenWidth, MyKScreenHeight);
    _cameraView.delegate = self;
    [self.view addSubview:_cameraView];
    _cameraView.alpha = 0.0f;
}
- (void)mdcAVCameraViewDidCancle:(MDCAVCameraView *)cameraView
{
    [_cameraView showCamera:NO];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

        _cameraView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        
    }];
    
}
- (void)mdcAVCameraView:(MDCAVCameraView *)cameraView captureImage:(UIImage *)image
{
    
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);//将图片加到相册中
    
    
    
    [_cameraView showCamera:NO];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _cameraView.alpha = 0.0f;
        
    } completion:^(BOOL finished) {
        
    }];
    
    if (_type == WTPhotosListCollectionViewTypeHeaderImage) {
        
        [self.navigationController popViewControllerAnimated:NO];
        if (_didChooseHeadImageSuccessBlock) {
            _didChooseHeadImageSuccessBlock(image);
            
            [[WTPhotoManager sharedInstance]clearData];
        }
    }else{
    
        __block PHAsset *nowAsset = nil;
        __block NSString *localId;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{

            PHAssetCollectionChangeRequest *albumRequest = [PHAssetCollectionChangeRequest new];
            PHAssetChangeRequest *createImageRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            [albumRequest addAssets:@[createImageRequest.placeholderForCreatedAsset]];

            localId = createImageRequest.placeholderForCreatedAsset.localIdentifier;

//            PHObjectPlaceholder *p = createImageRequest.placeholderForCreatedAsset;

        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"saved successed");
            
                PHFetchResult *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil];
                
                [[WTPhotoManager sharedInstance] requestImageForAsset:asset[0] imageSize:AssetGridThumbnailSize successBlock:^(UIImage *image) {
                    
                    if (nowAsset) return;
                    
                    [[WTPhotoManager sharedInstance].thumbnailImageArray addObject:image];
                }];
                
                nowAsset = asset[0];
        
                [[WTPhotoManager sharedInstance].imageLocalIdentifierArray addObject:asset[0]];
                
            }
        }];
    }
    
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update cached assets for the new visible area.
    [self updateCachedAssets];
}

#pragma mark - Asset Caching
- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect.
    CGRect preheatRect = _collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    /*
     Check if the collection view is showing an area that is significantly
     different to the last preheated area.
     */
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(_collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [_collectionView aapl_indexPathsForElementsInRect:removedRect showCamera:_show];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [_collectionView aapl_indexPathsForElementsInRect:addedRect showCamera:_show];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        // Update the assets the PHCachingImageManager is caching.
        
        [[WTPhotoManager sharedInstance] startCachingImagesForAssets:assetsToStartCaching targetSize:AssetGridThumbnailSize];
        [[WTPhotoManager sharedInstance] stopCachingImagesForAssets:assetsToStopCaching targetSize:AssetGridThumbnailSize];
        
        
        // Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}
- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths {
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.assetsFetchResults[_show ? indexPath.item - 1 : indexPath.item];
        [assets addObject:asset];
    }
    
    return assets;
}
- (void)doneClick:(id)sender {
    NSLog(@"点击了确定按钮");
    
    if (_didChooseImagesSuccessBlock) {
        _didChooseImagesSuccessBlock();
    }

    if ([WTPhotoManager sharedInstance].thumbnailImageArray.count == 0) {
//        [[ZWYHelper sharedHelper] addAlertViewControllerToView:[ZWYHelper rootTabbarViewController].view withClickBlock:^(int clickInt) {
//                   } title:@"" content:[NSString stringWithFormat:@"选择不能为空!"] cancleStr:@"" confirmStr:@"确认" animated:YES];;
    }else{
    [self.navigationController popViewControllerAnimated:YES];
    }
    
    }
@end

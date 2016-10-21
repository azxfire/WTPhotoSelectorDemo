//
//  WTPhotoAlbumListViewController.m
//  zwy
//
//  Created by taowang on 2016/7/28.
//  Copyright © 2016年 zwy. All rights reserved.
//

#import "WTPhotoAlbumListViewController.h"
#import "WTPhotosListCollectionView.h"
#import "WTPhotoManager.h"
#import "WTPhotoSelectorMarco.h"
@interface WTPhotoAlbumListViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation WTPhotoAlbumListViewController{
    UITableView *_tableview;
}
static NSString * const AllPhotosReuseIdentifier = @"AllPhotosCell";
static NSString * const CollectionCellReuseIdentifier = @"CollectionCell";

- (void)viewDidLoad {

    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wtPhotoLibraryDidChange) name:WTPhotoLibraryDidChangeNotification object:nil];
    
    
    _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, MyKScreenWidth, MyKScreenHeight) style:UITableViewStyleGrouped];
    [self.view addSubview:_tableview];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:CollectionCellReuseIdentifier];
    [_tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:AllPhotosReuseIdentifier];
}
- (void)wtPhotoLibraryDidChange{
    [_tableview reloadData];
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[WTPhotoManager sharedInstance]sectionFetchResult].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if (section == 0) {
        numberOfRows = 1;
    }else{
        PHFetchResult *fetchResult = [[WTPhotoManager sharedInstance]sectionFetchResult][section];
        numberOfRows = fetchResult.count;
    }
    return numberOfRows;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:AllPhotosReuseIdentifier forIndexPath:indexPath];
        
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AllPhotosReuseIdentifier];
        }
        cell.textLabel.text = NSLocalizedString(@"All Photos", @"");
    } else {
        PHFetchResult *fetchResult = [[WTPhotoManager sharedInstance]sectionFetchResult][indexPath.section];
        PHCollection *collection = fetchResult[indexPath.row];
        
        cell = [tableView dequeueReusableCellWithIdentifier:CollectionCellReuseIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CollectionCellReuseIdentifier];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = collection.localizedTitle;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    
    
    if (indexPath.section == 0) {
        
        WTPhotosListCollectionView *assetGridViewController = [[WTPhotosListCollectionView alloc]initWithCollectionViewLayout:layout showCameraView:YES];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        // Set the title of the AAPLAssetGridViewController.
        assetGridViewController.title = cell.textLabel.text;
        
        // Get the PHFetchResult for the selected section.
        //        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        PHFetchResult *fetchResult = [[WTPhotoManager sharedInstance]sectionFetchResult][indexPath.section];
        
        //        if ([segue.identifier isEqualToString:AllPhotosSegue]) {
        assetGridViewController.assetsFetchResults = fetchResult;
        //        }
        
        [self.navigationController pushViewController:assetGridViewController animated:YES];
    }else{
        
        WTPhotosListCollectionView *assetGridViewController = [[WTPhotosListCollectionView alloc]initWithCollectionViewLayout:layout showCameraView:YES];
        
        PHFetchResult *fetchResult = [[WTPhotoManager sharedInstance]sectionFetchResult][indexPath.section];
        PHCollection *collection = fetchResult[indexPath.row];
        if (![collection isKindOfClass:[PHAssetCollection class]]) {
            return;
        }
        
        // Configure the AAPLAssetGridViewController with the asset collection.
        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        
        assetGridViewController.assetsFetchResults = assetsFetchResult;
        assetGridViewController.assetCollection = assetCollection;
        
        [self.navigationController pushViewController:assetGridViewController animated:YES];
    }
}

@end

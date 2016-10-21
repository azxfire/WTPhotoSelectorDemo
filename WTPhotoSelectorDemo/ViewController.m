//
//  ViewController.m
//  WTPhotoSelectorDemo
//
//  Created by taowang on 2016/10/21.
//  Copyright © 2016年 mm. All rights reserved.
//

#import "ViewController.h"
#import "WTPhotoManager.h"
#import "SelfEditHeadController.h"
@interface ViewController ()
- (IBAction)chooseContentImages:(id)sender;
- (IBAction)chooseHeadImage:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)chooseContentImages:(id)sender {
    [[WTPhotoManager sharedInstance] showAllPhotoWithTitle:@"相片" maxSelectedCount:9 contentImagesuccessBlock:^{
        //返回取得的图片，缩略图，如果需要上传原图需要调用selectedImagesArraySuccessBlock
        for (UIImage *image in [WTPhotoManager sharedInstance].thumbnailImageArray) {
            NSLog(@"%@", image);
        }
    } headImagesuccessBlock:^(UIImage *head) {
        
    } type:WTPhotosListCollectionViewTypeContentImage];
}

- (IBAction)chooseHeadImage:(id)sender {
    [[WTPhotoManager sharedInstance]showAllPhotoWithTitle:@"选择头像" maxSelectedCount:1 contentImagesuccessBlock:^{
        
    } headImagesuccessBlock:^(UIImage *head) {
        SelfEditHeadController *editHeadVc = [[SelfEditHeadController alloc]init];
        editHeadVc.editImage = head;
        editHeadVc.didCropBlock = ^(UIImage *image) {
            //
            //上传图片，返回头像地址
            //[self uploadNewHeadIcon:image];
//            NSArray *headImgArr = @[image];
//            [[APIManager sharedManager]uploadFileWithArray:headImgArr success:^(NSString *imagesString) {
//                if (ValidStr(imagesString)) {
//                    ZWYUpdateUserDetailInfoRequestModel *request = [ZWYUpdateUserDetailInfoRequestModel new];
//                    request.icon = imagesString;
//                    [[APIManager sharedManager]commonRequestWithRequestModel:request success:^(NSObject *responseModel) {
//                        ZWYUserLoginResponseModel *res = (ZWYUserLoginResponseModel *)responseModel;
//                        if (res.rtnCode.intValue == 0) {
//                            [ZWYUserUtil sharedUtil].currentUser = res.data;
//                        }
//                    } failure:^(NSError *error) {
//                        
//                    }];
//                    
//                    
//                }
//            } failure:^(NSError *error) {
//                
//            } hud:nil];
            
        };
        UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        [nav pushViewController:editHeadVc animated:YES];

        
    } type:WTPhotosListCollectionViewTypeHeaderImage];
}
@end

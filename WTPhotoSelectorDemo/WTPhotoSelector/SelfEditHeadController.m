//
//  SelfEditHeadController.m
//  Plague
//
//  Created by 王涛 on 15/2/2.
//  Copyright (c) 2015年 plague. All rights reserved.
//

#import "SelfEditHeadController.h"
#import "TWImageScrollView.h"
#import "WTPhotoSelectorMarco.h"
@interface SelfEditHeadController ()

@end

@implementation SelfEditHeadController
{
    UIButton *_closeButton;
    UIButton *sendButton;
    TWImageScrollView *imageScrollView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

}

-(void)setEditImage:(UIImage *)editImage
{
    _editImage = editImage;
    
    UIBarButtonItem *rightBtnItem =
    [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(cropAction)];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, MyKScreenWidth, MyKScreenWidth, MyKScreenHeight - MyKScreenWidth- KNavHeight)];
    bottomView.backgroundColor = [[UIColor colorWithRed:26.0/255 green:29.0/255 blue:33.0/255 alpha:1] colorWithAlphaComponent:.8f];
    [self.view addSubview:bottomView];
    
    
    imageScrollView = [[TWImageScrollView alloc] initWithFrame:CGRectMake(0, 0, MyKScreenWidth, MyKScreenWidth)];
//    imageScrollView.backgroundColor = [UIColor];
    [self.view addSubview:imageScrollView];
    
    [self.view insertSubview:bottomView aboveSubview:imageScrollView];

    [imageScrollView displayImage:_editImage];
}
- (void)cropAction {
    if (_didCropBlock) _didCropBlock(imageScrollView.capture);
//    [self backAction];
    [self didTapClose:nil];
}
-(void)didTapClose:(id)sender
{
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self.navigationController popViewControllerAnimated:YES];
//    self.navigationController.navigationBarHidden = YES;
    
//    [self dismissViewControllerAnimated:YES completion:^{
//        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
//    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

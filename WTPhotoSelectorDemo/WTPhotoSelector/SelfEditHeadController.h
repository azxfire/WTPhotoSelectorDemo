//
//  SelfEditHeadController.h
//  Plague
//
//  Created by 王涛 on 15/2/2.
//  Copyright (c) 2015年 plague. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelfEditHeadController : UIViewController
//修改完成图片了的block
//@property(nonatomic, copy) void (^didTapDoneBlock)(void);
@property (nonatomic, copy) void(^didCropBlock)(UIImage *image);
@property (nonatomic, strong) UIImage *editImage;
@end

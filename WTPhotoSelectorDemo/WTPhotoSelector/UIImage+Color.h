//
//  UIImage+Color.h
//  com.diandian.yundong
//
//  Created by wangtao on 16/6/13.
//  Copyright © 2016年 Techfaith. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)
- (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)resizeImageWithSize:(CGSize)desiredSize;
@end

//
//  UIImage+UserPhoto.h
//  MDCPhotoSelector
//
//  Created by taowang on 15/7/20.
//  Copyright © 2015年 MDC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UserPhoto)
- (UIImage *)userPhotoImage;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end

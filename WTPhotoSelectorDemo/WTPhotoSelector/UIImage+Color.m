//
//  UIImage+Color.m
//  com.diandian.yundong
//
//  Created by wangtao on 16/6/13.
//  Copyright © 2016年 Techfaith. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)
- (UIImage *)imageWithColor:(UIColor *)color {
    
    CGFloat r, g, b, a;
    if (![color getRed:&r green:&g blue:&b alpha:&a]) {
        [color getWhite:&r alpha:&a];
        g = r;
        b = r;
    }
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetShouldAntialias(context, YES);
    
    CGAffineTransform flipVertical = CGAffineTransformMake(
                                                           1, 0, 0, -1, 0, self.size.height
                                                           );
    
    CGContextConcatCTM(context, flipVertical);
    
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:r green:g blue:b alpha:1].CGColor);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    CGContextFillRect(context, rect);
    
    //    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    //    CGContextDrawImage(context, rect, self.CGImage);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}
- (UIImage *)resizeImageWithImage:(UIImage *)image andSize:(CGSize)desiredSize{
    
    return [self scaleImage:image maxWidth:desiredSize.width maxHeight:desiredSize.height];
}
- (UIImage *)resizeImageWithSize:(CGSize)desiredSize{
    return [self resizeImageWithImage:self andSize:desiredSize];
}
- (UIImage *)scaleImage:(UIImage *)image maxWidth:(int) maxWidth maxHeight:(int) maxHeight
{
    CGImageRef imgRef = image.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    if (width <= maxWidth && height <= maxHeight)
    {
        return image;
    }
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    if (width > maxWidth || height > maxHeight)
    {
        CGFloat ratio = width/height;
        
        if (ratio > 1)
        {
            bounds.size.width = maxWidth;
            bounds.size.height = bounds.size.width / ratio;
        }
        else
        {
            bounds.size.height = maxHeight;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    UIGraphicsBeginImageContext(bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, scaleRatio, -scaleRatio);
    CGContextTranslateCTM(context, 0, -height);
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
    
}

@end

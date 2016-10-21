//
//  MDCPhotoSelectorLiveFeedCell.h
//  MDCPhotoSelector
//
//  Created by taowang on 15/7/20.
//  Copyright © 2015年 MDC. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MDCPhotoSelectorLiveFeed : NSObject
@end
@interface MDCPhotoSelectorLiveFeedCell : UICollectionViewCell
+ (CGSize)desiredSize;
- (void)startCaptureSession;
@end

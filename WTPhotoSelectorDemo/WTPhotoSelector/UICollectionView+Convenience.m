/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A category on UICollectionView for convienience methods.
 */

#import "UICollectionView+Convenience.h"

@implementation UICollectionView (Convenience)

- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    return [self aapl_indexPathsForElementsInRect:rect showCamera:NO];
}
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect showCamera:(BOOL)show{
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        if (show) {
            if (indexPath.row != 0) {
                [indexPaths addObject:indexPath];
            }
        }else{
            [indexPaths addObject:indexPath];
        }
        
        
    }
    return indexPaths;
}
@end

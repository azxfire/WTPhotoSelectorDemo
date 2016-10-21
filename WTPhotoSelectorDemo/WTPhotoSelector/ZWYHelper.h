//
//  ZWYHelper.h
//  zwy
//
//  Created by taowang on 2016/7/19.
//  Copyright © 2016年 zwy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ZWYUserAuthPersonalRequestModel;
@class ZWYAddPropertyZipInfoRequestModel;
@class ZWYAuthEnterpriseRequestModel;
@class ZWYAuthCollectorsRequestModel;
@class ZWYMapModel;
typedef void(^blurHideBlockBlock)(void);
typedef void(^alertClickBlock)(int clickInt);
typedef void(^rightNavButtonClickBlock)();
@interface ZWYHelper : NSObject
+ (instancetype)sharedHelper;
- (void)addBlurViewToView:(UIView *)toView frame:(CGRect)blurFrame withHideBlock:(blurHideBlockBlock)hide animated:(BOOL)animated;
- (void)addClearViewToView:(UIView *)toView;
- (void)hideClearView;
- (void)hideBlurAnimated:(BOOL)animated;
- (void)addAlertViewControllerToView:(UIView *)toView withClickBlock:(alertClickBlock)clickBlock title:(NSString *)title content:(NSString *)content cancleStr:(NSString *)cancleStr confirmStr:(NSString *)confirmStr animated:(BOOL)animated;
- (void)addAlertViewControllerToView:(UIView *)toView withClickBlock:(alertClickBlock)clickBlock title:(NSString *)title content:(NSString *)content cancleStr:(NSString *)cancleStr confirmStr:(NSString *)confirmStr animated:(BOOL)animated blurEnable:(BOOL)enable;

+ (NSString*)getStringReplaceColonWithSpace:(NSString *)originalStr;
- (void)addPaidPercentViewToView:(UIView *)toView animated:(BOOL)animated;
- (void)addAlertToView:(UIView *)toView image:(UIImage *)image animated:(BOOL)animated;
- (void)addRightNavBarButtonToViewController:(UIViewController *)toViewController title:(NSString *)title clickBlock:(rightNavButtonClickBlock)block;
- (BOOL)stringIsNumber:(NSString *)str;
- (UIViewController *)getViewControllerFromStoryBoardName:(NSString *)name;
+ (BOOL)valiMobile:(NSString *)mobile;
- (void)startCountWithButton:(UIButton *)btn;
- (void)stopTime;
+ (NSString *)stringWithTimelineDate:(NSDate *)date;
+ (NSString *)timeStampWithString:(NSString *)dateStr format:(NSString *)format;
- (void)popToViewController:(Class)vc withCurrentVC:(UIViewController *)currentVC;
- (NSString *)getTimeStringWithTimeStamp:(long long)stamp;

- (void)showImageInspectViewWithUrlArray:(NSArray *)imageArray withSourceViews:(NSArray *)sourceView clickView:(UIView *)clickView;

- (void)showMessage:(NSString *)message;
- (void)showDebtDetailWith:(ZWYMapModel *)mapModel viewController:(UIViewController *)currentViewControllerl;
- (void)addCsrzNoneViewToView:(UIView *)view message:(NSString *)message;
- (void)removeNoneView;
- (void)addSearchHistory:(NSString *)searchStr;
- (NSArray *)getSearchHistory;
- (void)deleteAllHistory;
- (NSString *)removeAllSpaceAndNewLine:(NSString *)str;
- (BOOL)isString:(NSString*)originalString confirmFormat:(NSString *)format;
- (NSDate *)getYesterday;
@property (nonatomic, strong) NSMutableDictionary *zhaiQuan;
@property (nonatomic, strong) NSMutableDictionary *zhaiWu;
@property (nonatomic, strong) NSMutableDictionary *authPersonal;
@property (nonatomic, strong) NSMutableDictionary *zipModel;
@property (nonatomic, strong) NSMutableDictionary *authEnterprise;
@property (nonatomic, strong) NSMutableDictionary *collector;
@property (nonatomic, strong) NSMutableDictionary *company;
@property (nonatomic, strong) NSMutableDictionary *userHeadImage;
@property (nonatomic, assign) BOOL blurEnable;;
@end

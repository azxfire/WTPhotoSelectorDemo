//
//  ZWYHelper.m
//  zwy
//
//  Created by taowang on 2016/7/19.
//  Copyright © 2016年 zwy. All rights reserved.
//

#import "ZWYHelper.h"
@interface ZWYHelper()
@property (nonatomic, strong) UIButton *blurView;
@property (nonatomic, strong) UIButton *clearView;
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UIView *messageView;
@end
@implementation ZWYHelper{
    NSTimer *_verfityEnableTimer;
    
    int _timerTarget;
    int _timerCount;
    
    NSString *_vCode;
    int _vCodeTimeOut;
    UIButton *_fireButton;
    UIButton *_csrzNoneButton;
    UILabel *_csrzNoneLable;
}
+ (instancetype)sharedHelper{
    static ZWYHelper *_sessionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sessionManager = [[self alloc]init];
        _sessionManager.blurEnable = YES;
    });
    return _sessionManager;
}
+ (WWTabbarViewController *)rootTabbarViewController{
    WWTabbarViewController *rootVC = (WWTabbarViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    return rootVC;
}
- (void)addBlurViewToView:(UIView *)toView frame:(CGRect)blurFrame withHideBlock:(blurHideBlockBlock)hide animated:(BOOL)animated{
    if (CGRectEqualToRect(blurFrame, CGRectZero)) {
        
        _blurView = [[UIButton alloc]initWithFrame:toView.bounds];
    }else{
        
        _blurView = [[UIButton alloc]initWithFrame:blurFrame];
    }
    _blurView.alpha = 0.5f;
    [_blurView setImage:[[toView snapshotImageAfterScreenUpdates:NO]imageByBlurDark] forState:UIControlStateNormal];
    [_blurView setImage:[[toView snapshotImageAfterScreenUpdates:NO]imageByBlurDark] forState:UIControlStateHighlighted];
    @weakify(self)
    [_blurView addBlockForControlEvents:UIControlEventTouchUpInside block:^(id sender) {
        @strongify(self)
        if (self.blurEnable) {
            if (hide) {
                hide();
            }
        }
        
    }];
    [toView addSubview:_blurView];
    
    if (animated) {
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            _blurView.alpha = 0.9f;
        } completion:^(BOOL finished) {
        }];
    }else{
        
        _blurView.alpha = 0.9f;
    }
    
    
}
- (void)addAlertViewControllerToView:(UIView *)toView withClickBlock:(alertClickBlock)clickBlock title:(NSString *)title content:(NSString *)content cancleStr:(NSString *)cancleStr confirmStr:(NSString *)confirmStr animated:(BOOL)animated blurEnable:(BOOL)enable{
    _blurEnable = enable;
    [self addAlertViewControllerToView:toView withClickBlock:clickBlock title:title content:content cancleStr:cancleStr confirmStr:confirmStr animated:animated];
}
- (void)addClearViewToView:(UIView *)toView{
    
    if (!_clearView) {
        _clearView = [UIButton new];
        _clearView.backgroundColor = [UIColor clearColor];
        _clearView.frame = toView.bounds;
        [toView addSubview:_clearView];
    }
    
}
- (void)hideClearView{
    [_clearView removeFromSuperview];
    _clearView = nil;
}
- (void)hideBlurAnimated:(BOOL)animated{
    if (animated) {
        [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
            _blurView.alpha = 0.f;
        } completion:^(BOOL finished) {
            [_blurView removeFromSuperview];
            _blurView = nil;
        }];
    }else{
        _blurView.alpha = 0.0f;
        [_blurView removeFromSuperview];
        _blurView = nil;
    }
    
}
- (void)addAlertViewControllerToView:(UIView *)toView withClickBlock:(alertClickBlock)clickBlock title:(NSString *)title content:(NSString *)content cancleStr:(NSString *)cancleStr confirmStr:(NSString *)confirmStr animated:(BOOL)animated{
    @weakify(self)
    [self addBlurViewToView:toView frame:CGRectZero withHideBlock:^{
        [weak_self hideBlurAnimated:YES];
    } animated:animated];
    _alertView = [UIView new];
    _alertView.backgroundColor = [UIColor whiteColor];
    _alertView.layer.cornerRadius = 10;
    _alertView.clipsToBounds = YES;
    [_blurView addSubview:_alertView];
    
    [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weak_self.blurView).with.offset(25);
        make.right.equalTo(weak_self.blurView).with.offset(-25);
        make.height.mas_equalTo(107);
        make.centerY.equalTo(weak_self.blurView);
    }];
    
    if (ValidStr(title)) {
        UILabel *titleLable = [UILabel new];
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.font = [UIFont systemFontOfSize:16];
        titleLable.textColor = ZWYAlertTextColor;
        titleLable.text = title;
        titleLable.adjustsFontSizeToFitWidth = YES;//设置字体大小随字体数量变化

        [_alertView addSubview:titleLable];
        
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_alertView);
            make.top.equalTo(_alertView).with.offset(20);
            make.height.mas_equalTo(20);
        }];
        
        if (ValidStr(content)) {
            UILabel *contentLable = [UILabel new];
            contentLable.textColor = ZWYAlertTextColor;
            contentLable.textAlignment = NSTextAlignmentCenter;
            contentLable.text = content;
            contentLable.font = [UIFont systemFontOfSize:13];
            contentLable.adjustsFontSizeToFitWidth = YES;//设置字体大小随字体数量变化
            [_alertView addSubview:contentLable];
            
            [contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_alertView).with.offset(16);
                make.right.equalTo(_alertView).with.offset(-16);
                make.bottom.equalTo(_alertView).with.offset(-55);
                make.top.equalTo(titleLable.mas_bottom).with.offset(5);
            }];
        }
    }else{
        if (ValidStr(content)) {
            UILabel *contentLable = [UILabel new];
            contentLable.numberOfLines = 0;
            contentLable.textColor = ZWYAlertTextColor;
            contentLable.textAlignment = NSTextAlignmentCenter;
            contentLable.text = content;
            contentLable.font = [UIFont systemFontOfSize:15];
            [_alertView addSubview:contentLable];
            
            [contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_alertView).with.offset(16);
                make.right.equalTo(_alertView).with.offset(-16);
                make.bottom.equalTo(_alertView).with.offset(-44.5);
                make.top.equalTo(_alertView);
            }];
        }
    }
    
    
    
    
    UIView *horizLineView = [UIView new];
    horizLineView.backgroundColor = ColorWithRGB(238, 238, 238);
    [_alertView addSubview:horizLineView];
    [horizLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_alertView);
        make.bottom.equalTo(_alertView).with.offset(-44);
        make.height.mas_equalTo(0.5);
    }];
    
    
    UIButton *confirmButton = [UIButton new];
    [confirmButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        if (clickBlock) {
            clickBlock(1);
        }
        if (_blurEnable) {
            [weak_self hideBlurAnimated:YES];
        }
        
    }];
    confirmButton.backgroundColor = CommonAppColor;
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [confirmButton setTitle:confirmStr forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_alertView addSubview:confirmButton];
    
    if (ValidStr(cancleStr)) {
        UIButton *cancleButton = [UIButton new];
        [cancleButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
            if (clickBlock) {
                clickBlock(0);
            }
            if (_blurEnable) {
               [weak_self hideBlurAnimated:YES];
            }
            
        }];
        cancleButton.backgroundColor = [UIColor whiteColor];
        cancleButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancleButton setTitle:cancleStr forState:UIControlStateNormal];
        [cancleButton setTitleColor:ZWYAlertTextColor forState:UIControlStateNormal];
        [_alertView addSubview:cancleButton];
        
        [cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.equalTo(_alertView);
            make.size.mas_equalTo(CGSizeMake((MyKScreenWidth - 50) / 2, 44));
        }];
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(_alertView);
            make.size.mas_equalTo(cancleButton);
        }];

    }else{
        
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(_alertView);
            make.size.mas_equalTo(CGSizeMake(MyKScreenWidth - 50, 44));
        }];

    }
    
    
    
    
}
+ (NSString *)getStringReplaceColonWithSpace:(NSString *)originalStr{
    return [originalStr stringByReplacingOccurrencesOfString:@"：" withString:@""];
}
- (void)addPaidPercentViewToView:(UIView *)toView animated:(BOOL)animated{
    @weakify(self)
    [self addBlurViewToView:toView frame:CGRectZero withHideBlock:^{
        [weak_self hideBlurAnimated:YES];
    } animated:animated];
    _alertView = [UIView new];
    _alertView.backgroundColor = [UIColor whiteColor];
    _alertView.layer.cornerRadius = 10;
    _alertView.clipsToBounds = YES;
    [_blurView addSubview:_alertView];
    
    [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weak_self.blurView).with.offset(25);
        make.right.equalTo(weak_self.blurView).with.offset(-25);
        make.height.mas_equalTo(134);
        make.centerY.equalTo(weak_self.blurView);
    }];
    
    

}
- (void)addAlertToView:(UIView *)toView image:(UIImage *)image animated:(BOOL)animated{
    @weakify(self)
    [self addBlurViewToView:toView frame:CGRectZero withHideBlock:^{
        [weak_self hideBlurAnimated:YES];
    } animated:animated];
    
    _alertView = [UIView new];
    _alertView.backgroundColor = [UIColor clearColor];
    _alertView.clipsToBounds = YES;
    [_blurView addSubview:_alertView];
    _alertView.layer.contents = (id)image.CGImage;
    [_alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weak_self.blurView);
        make.size.mas_equalTo(image.size);
    }];
}
- (void)addRightNavBarButtonToViewController:(UIViewController *)toViewController title:(NSString *)title clickBlock:(rightNavButtonClickBlock)block{
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(navRightButtonClick:)];
    toViewController.navigationItem.rightBarButtonItem = rightBtnItem;
}
- (void)navRightButtonClick:(rightNavButtonClickBlock)block{
    if (block) {
        block();
    }
}
- (BOOL)stringIsNumber:(NSString *)str{
    return [str matchesRegex:@"\\[0-9\\]" options:NSRegularExpressionCaseInsensitive];
}
- (UIViewController *)getViewControllerFromStoryBoardName:(NSString *)name{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:name];
}
+ (BOOL)valiMobile:(NSString *)mobile{
    if (mobile.length < 11)
    {
        return NO;
    }else{
        /**
         * 移动号段正则表达式
         */
        NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
        /**
         * 联通号段正则表达式
         */
        NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
        /**
         * 电信号段正则表达式
         */
        NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
        NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM_NUM];
        BOOL isMatch1 = [pred1 evaluateWithObject:mobile];
        NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU_NUM];
        BOOL isMatch2 = [pred2 evaluateWithObject:mobile];
        NSPredicate *pred3 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT_NUM];
        BOOL isMatch3 = [pred3 evaluateWithObject:mobile];
        
        if (isMatch1 || isMatch2 || isMatch3) {
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}

-(void)startCountWithButton:(UIButton *)btn{
    [self fireTimeWithButton:btn];
    _fireButton = btn;
    _fireButton.backgroundColor = [UIColor lightGrayColor];
}
- (void)fireTimeWithButton:(UIButton*)btn
{
    _timerTarget = 120;
    _timerCount = 0;
    
    _vCodeTimeOut = 0;
    _vCode = nil;
    
    NSString *str = [NSString stringWithFormat:@"%d秒后重试", _timerTarget];
    
    btn.enabled = NO;
    [btn setTitle:str forState:UIControlStateDisabled];
    
    [self scheduleProcessTimer];
}
- (void)stopTime
{
    [_verfityEnableTimer invalidate];
}
- (void)scheduleProcessTimer{
    [_verfityEnableTimer invalidate];
    _verfityEnableTimer = [NSTimer scheduledTimerWithTimeInterval:1.f
                                                           target:self
                                                         selector:@selector(processTimerDidFire:)
                                                         userInfo:nil
                                                          repeats:YES];
}
- (void)processTimerDidFire:(id)sender {
    
    _timerCount++;
    if(_timerCount == _timerTarget)
    {
        _timerCount = 0;
        [_verfityEnableTimer invalidate];
        
        _fireButton.enabled = YES;
        [_fireButton setTitle:@"点击重试" forState:UIControlStateNormal];
        _fireButton.backgroundColor = CommonAppColor;
    }
    else
    {
        
        NSString *lab = [NSString stringWithFormat:@"%d秒后重试", _timerTarget - _timerCount];
        _fireButton.titleLabel.text = lab;
        [_fireButton setTitle:lab forState:UIControlStateDisabled];
        
        
    }
}

+ (NSString *)stringWithTimelineDate:(NSDate *)date {
    if (!date) return @"";
    
    static NSDateFormatter *formatterYesterday;
    static NSDateFormatter *formatterSameYear;
    static NSDateFormatter *formatterFullDate;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatterYesterday = [[NSDateFormatter alloc] init];
        [formatterYesterday setDateFormat:@"昨天 HH:mm"];
        [formatterYesterday setLocale:[NSLocale currentLocale]];
        
        formatterSameYear = [[NSDateFormatter alloc] init];
        [formatterSameYear setDateFormat:@"M-d"];
        [formatterSameYear setLocale:[NSLocale currentLocale]];
        
        formatterFullDate = [[NSDateFormatter alloc] init];
        [formatterFullDate setDateFormat:@"yy-M-dd"];
        [formatterFullDate setLocale:[NSLocale currentLocale]];
    });
    
    NSDate *now = [NSDate new];
    NSTimeInterval delta = now.timeIntervalSince1970 - date.timeIntervalSince1970;
    if (delta < -60 * 10) { // 本地时间有问题
        return [formatterFullDate stringFromDate:date];
    } else if (delta < 60 * 10) { // 10分钟内
        return @"刚刚";
    } else if (delta < 60 * 60) { // 1小时内
        return [NSString stringWithFormat:@"%d分钟前", (int)(delta / 60.0)];
    } else if (date.isToday) {
        return [NSString stringWithFormat:@"%d小时前", (int)(delta / 60.0 / 60.0)];
    } else if (date.isYesterday) {
        return [formatterYesterday stringFromDate:date];
    } else if (date.year == now.year) {
        return [formatterSameYear stringFromDate:date];
    } else {
        return [formatterFullDate stringFromDate:date];
    }
}
+ (NSString *)timeStampWithString:(NSString *)dateStr format:(NSString *)format{
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    NSDate *date = [NSDate dateWithString:dateStr format:format timeZone:timeZone locale:[NSLocale currentLocale]];
    ;

    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: date];
    
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    return @(localeDate.timeIntervalSince1970 * 1000).stringValue;
}
- (void)popToViewController:(Class)desVC withCurrentVC:(UIViewController *)currentVC{
    for (UIViewController*vc in [currentVC.navigationController viewControllers]) {
        if ([vc isKindOfClass: desVC]){
            [currentVC.navigationController popToViewController:vc animated:YES];
        }
    }
}
- (NSString *)getTimeStringWithTimeStamp:(long long)stamp{
    return [[NSDate dateWithTimeIntervalSince1970: stamp / 1000] stringWithFormat:@"yyyy-MM-dd"];
}
- (void)showImageInspectViewWithUrlArray:(NSArray *)imageArray withSourceViews:(NSArray *)sourceView clickView:(UIView *)clickView{
    
    NSObject *object = imageArray.firstObject;
    
    UIView *fromView = nil;
    
    NSMutableArray *items = [NSMutableArray array];
    
    NSArray *picArr = imageArray;
    
    for (NSInteger i = 0, max = picArr.count;i < max; i++) {
        UIView *currentSourceView;
        if (sourceView.count == 1) {
            currentSourceView = sourceView.firstObject;
        }else{
            currentSourceView = sourceView[i];
        }
        
        
        YYPhotoGroupItem *item = [YYPhotoGroupItem new];
        
        [items addObject:item];
        
        if ([object isKindOfClass:[UIImage class]]) {
            
            item.thumbView = currentSourceView;
            item.localImage = imageArray[i];
            if (i == [sourceView indexOfObject:clickView]) {
                fromView = currentSourceView;
            }
            
        }else if ([object isKindOfClass:[NSString class]]){
            
            item.largeImageURL = [NSURL URLWithString:ImageUrl(picArr[i])];
            fromView = currentSourceView;
        }
        
        
    
    }
    YYPhotoGroupView *v = [[YYPhotoGroupView alloc] initWithGroupItems:items];
    [v presentFromImageView:fromView toContainer:[ZWYHelper  rootTabbarViewController].view animated:YES completion:nil];
}
- (void)showMessage:(NSString *)message{
//    @weakify(self)
    [self addClearViewToView:[ZWYHelper rootTabbarViewController].view];
    
    CGSize messageSize = [message sizeWithFont:[UIFont systemFontOfSize:16] constrainedToWidth:MyKScreenWidth - 100];
    CGFloat width;
    CGFloat height;
    CGFloat minWidth = 100;
    CGFloat minHeight = 50;
    CGFloat topBottomMargin = 10;
    CGFloat leftRightPadding = 10;
    
    
    width = messageSize.width < minWidth ? minWidth : messageSize.width + 2 * leftRightPadding;
    height = messageSize.height < minHeight ? minHeight : messageSize.height + 2 * topBottomMargin;
    
    
    _messageView = [UIView new];
    _messageView.backgroundColor = CommonAppColor;
    _messageView.layer.cornerRadius = 5;
    _messageView.clipsToBounds = YES;
    [_clearView addSubview:_messageView];
    
    
    
    
    [_messageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(width, height));
        make.center.equalTo(_clearView);
    }];
    
    UILabel *textLable = [UILabel new];
    textLable.numberOfLines = 0;
    textLable.textColor = [UIColor whiteColor];
    textLable.text = message;
    textLable.font = [UIFont systemFontOfSize:16];
    [_messageView addSubview:textLable];
    [textLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(messageSize);
        make.center.equalTo(_clearView);
    }];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:2.0f animations:^{
            _messageView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [_messageView removeFromSuperview];
            [self hideClearView];
        }];
    });
}
- (void)showDebtDetailWith:(ZWYMapModel *)mapModel viewController:(UIViewController *)currentViewControllerl{
    
    ZWYGetDebtInfoRequestModel *request = [ZWYGetDebtInfoRequestModel new];
    request.orderId = mapModel.number;
    request.pageSize = 100;
    request.pageNo = 1;
    ZWYUser *user = [ZWYUserUtil sharedUtil].currentUser;
    [[APIManager sharedManager]commonRequestWithRequestModel:request success:^(NSObject *responseModel) {
        
        ZWYGetDebtInfoResponseModel *res = (ZWYGetDebtInfoResponseModel *)responseModel;
        DebtDetailContainerViewControllerType containerType;
        if (res.status.intValue == 1) {//1:普通债权人展示
            if (res.certStatus.intValue == 2) {//当前用户通过催收公司认证
                
                if (res.debtInfo.pid) {//个人或企业债权
                    
                        if (res.type.intValue >= 5 && [res.chooseId isEqualToString:user.pid]) {
                            containerType = DebtDetailContainerViewControllerTypeMoneyCollectorBeenAccepted;
                        }else{
                            containerType = DebtDetailContainerViewControllerTypeMoneyCollectorLook;
                        }
                }else{//资产包
                    if (res.type.intValue >= 5 && [res.chooseId isEqualToString:user.pid]) {
                        containerType = DebtDetailContainerViewControllerTypeMoneyCollectorZipBeenAccepted;
                    }else{
                        
                        
                        DebtDetailViewController *detail = [[DebtDetailViewController alloc]initWithType:DebtDetailViewControllerTypePublishDebtZipCmpLook];
                        detail.debtDetailInfo = res;
                        detail.orderId = mapModel.number;
                        [currentViewControllerl.navigationController pushViewController:detail animated:YES];
                        return;
                    }
                    
                }
                
                
            }else{
                if (res.debtInfo.pid){
                    
                    containerType = DebtDetailContainerViewControllerTypePerOrCmpLook;
                }else{
                    
//                    containerType = DebtDetailContainerViewControllerTypePerOrCmpLookZip;
                    
                    DebtDetailViewController *detail = [[DebtDetailViewController alloc]initWithType:DebtDetailViewControllerTypePublishDebtZipLook];
                    detail.debtDetailInfo = res;
                    detail.orderId = mapModel.number;
                    [currentViewControllerl.navigationController pushViewController:detail animated:YES];
                    return;
                }
                
                
            }
        }else if (res.status.intValue == 2){//2：发布此订单的债权人展示
            
            if (res.debtInfo.pid) {//个人或者企业债权
                if (res.type.intValue >= 5) {
                    
                    containerType = DebtDetailContainerViewControllerTypeSelfDebtBeenAccepted;
                }else{
                    if (res.type.intValue == 0 || res.type.intValue == 1) {
                        
                        containerType = DebtDetailContainerViewControllerTypePerOrCmpLook;
                    }else{
                        
                        containerType = DebtDetailContainerViewControllerTypeSelfDebt;
                    }
                    
                }
            }else{//资产包
                if (res.type.intValue >= 5) {
                    
                    containerType = DebtDetailContainerViewControllerTypeSelfDebtZipBeenAccepted;
                }else{
                    if (res.type.intValue == 0 || res.type.intValue == 1) {
                        
                        DebtDetailViewController *detail = [[DebtDetailViewController alloc]initWithType:DebtDetailViewControllerTypePublishDebtZipLook];
                        detail.debtDetailInfo = res;
                        detail.orderId = mapModel.number;
                        [currentViewControllerl.navigationController pushViewController:detail animated:YES];
                        return;
                    }else{
                    
                        containerType = DebtDetailContainerViewControllerTypeSelfDebtZip;
                    }
                    
                }
            }

        }else if (res.status.intValue == 3){//3：接单的催收公司展示
            if (res.debtInfo.pid) {
                if (res.type.intValue >= 5) {
                    
                    containerType = DebtDetailContainerViewControllerTypeMoneyCollectorBeenAccepted;
                }else{
                    
                    containerType = DebtDetailContainerViewControllerTypeMoneyCollectorLook;
                }
            }else{
                if (res.type.intValue >= 5) {
                    
                    containerType = DebtDetailContainerViewControllerTypeMoneyCollectorZipBeenAccepted;
                }else{
                    
                    containerType = DebtDetailContainerViewControllerTypeSelfDebtZip;
                }
            }
            
            
        }
        
        
        DebtDetailContainerViewController *detailContainer = [[DebtDetailContainerViewController alloc]initWithType:containerType];
        detailContainer.orderId = mapModel.number;
        detailContainer.debtDetailInfo = res;
        [currentViewControllerl.navigationController pushViewController:detailContainer animated:YES];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)addCsrzNoneViewToView:(UIView *)view message:(NSString *)message{
//    @weakify(self)
    _csrzNoneButton = [UIButton new];
    [_csrzNoneButton setImage:[UIImage imageNamed:@"zwy_csrz_none"] forState:UIControlStateNormal];
    [view addSubview:_csrzNoneButton];
    [_csrzNoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(view).with.offset(100);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    _csrzNoneLable = [UILabel new];
    _csrzNoneLable.font = [UIFont systemFontOfSize:14];
    _csrzNoneLable.textColor = [UIColor lightGrayColor];
    _csrzNoneLable.text = message;
    [view addSubview:_csrzNoneLable];
    [_csrzNoneLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(_csrzNoneButton.mas_bottom).with.offset(20);
    }];
}
- (void)removeNoneView{
    [_csrzNoneButton removeFromSuperview];
    _csrzNoneButton = nil;
    [_csrzNoneLable removeFromSuperview];
    _csrzNoneLable = nil;
}
- (void)addSearchHistory:(NSString *)searchStr{
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults]arrayForKey:ZWYSearchHistory]];
    if (arr.count < 3) {
        [arr insertObject:searchStr atIndex:0];
    }else{
        [arr replaceObjectAtIndex:0 withObject:searchStr];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:arr forKey:ZWYSearchHistory];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
- (NSArray *)getSearchHistory{
    return [[NSUserDefaults standardUserDefaults]arrayForKey:ZWYSearchHistory];
}
- (void)deleteAllHistory{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ZWYSearchHistory];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
- (NSString *)removeAllSpaceAndNewLine:(NSString *)str{
    
    NSString *temp = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}
- (BOOL)isString:(NSString*)originalString confirmFormat:(NSString *)format{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", format];
    return [pred evaluateWithObject:originalString];
}
- (NSDate *)getYesterday{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:[[NSDate alloc] init]];
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    NSDate *today = [cal dateByAddingComponents:components toDate:[[NSDate alloc] init] options:0]; //This variable should now be pointing at a date object that is the start of today (midnight);
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *yesterday = [cal dateByAddingComponents:components toDate: today options:0];
    return yesterday;
}
@end

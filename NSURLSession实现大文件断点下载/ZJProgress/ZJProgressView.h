//
//  ProgressView.h
//  圆形进度条
//
//  Created by ZJ on 16/10/7.
//  Copyright © 2016年 ZJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZJProgressView;

@protocol ZJProgressViewDelegate <NSObject>

@optional
/** 点击事件*/
- (void)ZJProgressViewdidSelected:(ZJProgressView *)progressView isPause:(BOOL)pause;

@end

@interface ZJProgressView : UIView<ZJProgressViewDelegate>

/** 中心颜色*/
@property (strong, nonatomic)UIColor *centerColor;
/** 圆环背景色*/
@property (strong, nonatomic)UIColor *arcBackColor;
/** 结束时的圆环色*/
@property (strong, nonatomic)UIColor *arcFinishColor;
/** 没有结束时的圆环颜色*/
@property (strong, nonatomic)UIColor *arcUnfinishColor;
/** 进度百分比数值（0-1）*/
@property (assign, nonatomic)float percent;
/** 圆环宽度*/
@property (assign, nonatomic)float width;
/** 文字的颜色*/
@property (nonatomic, strong) UIColor *labelColor;
/** 代理*/
@property (nonatomic, weak) id<ZJProgressViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame AndBeignImage:(UIImage *)beignImage AndPauseImage:(UIImage *)pauseImage;

@end

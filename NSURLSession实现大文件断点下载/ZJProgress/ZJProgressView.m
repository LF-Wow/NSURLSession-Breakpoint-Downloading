//
//  ProgressView.m
//  画圆
//
//  Created by 郭永亮 on 16/10/7.
//  Copyright © 2016年 郭永亮. All rights reserved.
//

#import "ZJProgressView.h"

@interface ZJProgressView()
/** 中央的图片*/
@property (nonatomic, strong) UIImageView *centerImageView;
/** 中央的文字*/
@property (nonatomic, strong) UILabel *percentLabel;
/** 开始时的图片*/
@property (nonatomic, strong) UIImage *beignImage;
/** 暂停时的图片*/
@property (nonatomic, strong) UIImage *pauseImage;
/** 状态*/
@property (nonatomic, assign) BOOL Pause;

@end

@implementation ZJProgressView

- (id)initWithFrame:(CGRect)frame AndBeignImage:(UIImage *)beignImage AndPauseImage:(UIImage *)pauseImage{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _percent = 0;
        _width = 0;
        _Pause = YES;
        
        _beignImage = beignImage;
        _pauseImage = pauseImage;
        
        CGFloat fontSize = frame.size.width / 4;
        
        _percentLabel = [[UILabel alloc] initWithFrame:(CGRect){5, (frame.size.height-fontSize)/2, frame.size.width-10, fontSize}];
        _percentLabel.textAlignment = NSTextAlignmentCenter;
        _percentLabel.font = [UIFont systemFontOfSize:fontSize];
        _percentLabel.hidden = YES;
        
        [self addSubview:_percentLabel];
        
        CGFloat imageWidth = frame.size.width / 3;
        
        _centerImageView = [[UIImageView alloc] initWithFrame:(CGRect){(frame.size.width - imageWidth) / 2, (frame.size.height - imageWidth)/2, imageWidth, imageWidth}];
        _centerImageView.image =  _beignImage ? _beignImage : [UIImage imageNamed:@"开始"];
        [self addSubview:_centerImageView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickProgressView)];
        [self addGestureRecognizer:tapGesture];
    }

    return self;
}

- (void)setPercent:(float)percent{
    _percent = percent;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        [self setNeedsDisplay];
    });
    
}

- (void)drawRect:(CGRect)rect{
    [self addArcBackColor];
    [self drawArc];
    [self addCenterBack];
    [self addCenterLabel];
}

/** 底层圈的颜色*/
- (void)addArcBackColor{
    CGColorRef color = (_arcBackColor == nil) ? [UIColor lightGrayColor].CGColor : _arcBackColor.CGColor;

    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGSize viewSize = self.bounds.size;
    CGPoint center = CGPointMake(viewSize.width / 2, viewSize.height / 2);

    // Draw the slices.
    CGFloat radius = viewSize.width / 2;
    CGContextBeginPath(contextRef);
    CGContextMoveToPoint(contextRef, center.x, center.y);
    CGContextAddArc(contextRef, center.x, center.y, radius,0,2*M_PI, 0);
    CGContextSetFillColorWithColor(contextRef, color);
    CGContextFillPath(contextRef);
}


- (void)drawArc{
    if (_percent == 0 || _percent > 1) {
        return;
    }

    if (_percent == 1) {/** 完成时的颜色*/
        CGColorRef color = (_arcFinishColor == nil) ? [UIColor redColor].CGColor : _arcFinishColor.CGColor;

        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGSize viewSize = self.bounds.size;
        CGPoint center = CGPointMake(viewSize.width / 2, viewSize.height / 2);
        // Draw the slices.
        CGFloat radius = viewSize.width / 2;
        CGContextBeginPath(contextRef);
        CGContextMoveToPoint(contextRef, center.x, center.y);
        CGContextAddArc(contextRef, center.x, center.y, radius,0,2*M_PI, 0);
        CGContextSetFillColorWithColor(contextRef, color);
        CGContextFillPath(contextRef);
    }else{/** 未完成时的颜色*/

        float endAngle = 2*M_PI*_percent;

        CGColorRef color = (_arcUnfinishColor == nil) ? [UIColor redColor].CGColor : _arcUnfinishColor.CGColor;
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        CGSize viewSize = self.bounds.size;
        CGPoint center = CGPointMake(viewSize.width / 2, viewSize.height / 2);
        // Draw the slices.
        CGFloat radius = viewSize.width / 2;
        CGContextBeginPath(contextRef);
        CGContextMoveToPoint(contextRef, center.x, center.y);
        CGContextAddArc(contextRef, center.x, center.y, radius,0,endAngle, 0);
        CGContextSetFillColorWithColor(contextRef, color);
        CGContextFillPath(contextRef);
    }

}

/** 背景色*/
-(void)addCenterBack{
    float width = (_width == 0) ? 3 : _width;

    CGColorRef color = (_centerColor == nil) ? [UIColor whiteColor].CGColor : _centerColor.CGColor;
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGSize viewSize = self.bounds.size;
    CGPoint center = CGPointMake(viewSize.width / 2, viewSize.height / 2);
    // Draw the slices.
    CGFloat radius = viewSize.width / 2 - width;
    CGContextBeginPath(contextRef);
    CGContextMoveToPoint(contextRef, center.x, center.y);
    CGContextAddArc(contextRef, center.x, center.y, radius,0,2*M_PI, 0);
    CGContextSetFillColorWithColor(contextRef, color);
    CGContextFillPath(contextRef);
}
/**
 * 改变进度文字
 */
- (void)addCenterLabel{
    
    _percentLabel.textColor = _labelColor ? _labelColor : [UIColor redColor];
    
    if (_percent == 1) {
        _percentLabel.text = @"100%";
        
    }else if(_percent < 1 && _percent >= 0){
        
        _percentLabel.text = [NSString stringWithFormat:@"%0.1f%%",_percent*100];
    }
}

#pragma mark - 手势点击事件
- (void)clickProgressView
{
    _centerImageView.image =  _pauseImage ? _pauseImage : [UIImage imageNamed:@"暂停"];
    
    if (_Pause)
    {

        _percentLabel.hidden = NO;
        _centerImageView.hidden = YES;
        _Pause = NO;
    }
    else
    {
        _percentLabel.hidden = YES;
        _centerImageView.hidden = NO;
        _Pause = YES;
    }
    
    if([_delegate respondsToSelector:@selector(ZJProgressViewdidSelected:isPause:)])
    {
        [_delegate ZJProgressViewdidSelected:self isPause:_Pause];
    }
    
}

@end

//
//  KUMRippleEffectView.m
//  RippleEffectView
//
//  Created by WEBSYSTEM-MAC4 on 2017/02/23.
//  Copyright © 2017年 kum-ap. All rights reserved.
//

#import "KUMRippleEffectView.h"

@implementation KUMRippleEffectView {
    CGFloat _startY;
    UIView *_fillView;
    CAShapeLayer *_maskLayer;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self afterInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self afterInit];
    }
    return self;
}

- (void)afterInit {
    _fillColor = [[UIColor purpleColor] colorWithAlphaComponent:0.25];
    _fillView = [[UIView alloc]initWithFrame:self.bounds];
    _fillView.alpha = 0;
    _fillView.userInteractionEnabled = NO;
    [self insertSubview:_fillView atIndex:0];
    
    _maskLayer = [[CAShapeLayer alloc] init];
    _maskLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
    _maskLayer.fillRule = kCAFillRuleEvenOdd;
    _maskLayer.fillColor = [UIColor blackColor].CGColor;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_maskLayer removeAllAnimations];
    
    CGPoint location = [[touches anyObject] locationInView:self];
    _startY = location.y;
    _fillView.frame = self.bounds;
    _maskLayer.frame = self.bounds;
    _fillView.backgroundColor = _fillColor;
    [UIView animateWithDuration:0.5 animations:^{
        _fillView.alpha = 1;
    }];
    _fillView.layer.mask = nil;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_startY == 0) {
        return;
    }
    CGPoint location = [[touches anyObject] locationInView:self];
    if (fabs(_startY - location.y) > 10) {
        [self touchesCancelled:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_startY == 0) {
        return;
    }
    [self touchesCancelled:touches withEvent:event];
    
    // event
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_startY == 0) {
        return;
    }
    CGPoint location = [[touches anyObject] locationInView:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        _fillView.alpha = 0;
    } completion:^(BOOL finished) {
        _fillView.layer.mask = nil;
    }];
    [self maskAnimation:location];
    _startY = 0;
}

- (void)maskAnimation:(CGPoint)center {
    UIBezierPath *initPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(center.x-25, center.y-25, 50, 50)];
    [initPath appendPath:[UIBezierPath bezierPathWithRect:self.bounds]];
    _maskLayer.path = initPath.CGPath;
    _fillView.layer.mask = _maskLayer;
    
    CGFloat oval = self.bounds.size.width > self.bounds.size.height ? self.bounds.size.width*0.5 : self.bounds.size.height*0.5;
    UIBezierPath *animPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(center.x - oval/2, center.y - oval/2, oval, oval)];
    [animPath appendPath:[UIBezierPath bezierPathWithRect:self.bounds]];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.duration = 0.5;
    animation.fromValue = (id)_maskLayer.path;
    animation.toValue = (id)animPath;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [_maskLayer addAnimation:animation forKey:@"animation"];
    _maskLayer.path = animPath.CGPath;
}
@end

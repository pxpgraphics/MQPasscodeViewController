//
//  MQPasscodeInputCirclesView.m
//  MQPasscodeViewController
//
// Created by Paris Pinkney on 08/20/14.
//

/**
 Copyright (C) 2014 by Thomas Heß

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "MQPasscodeInputCirclesView.h"
#import "MQPasscodeInputCircleView.h"

static NSUInteger const MQPasscodeInputCircleViewMaximumNumberOfShakes = 6;
static CGFloat const MQPasscodeInputCircleViewInitialShakeVelocity = 40.0f;

@interface MQPasscodeInputCirclesView ()

@property (nonatomic, strong) NSMutableArray *circleViews;
@property (nonatomic, readonly, assign) CGFloat circlePadding;

@property (nonatomic, assign) NSUInteger numberOfShakes;
@property (nonatomic, assign) NSInteger shakeDirection;
@property (nonatomic, assign) CGFloat shakeVelocity;
@property (nonatomic, strong) MQPasscodeInputCirclesViewCompletionBlock completionBlock;

@end

@implementation MQPasscodeInputCirclesView

- (instancetype)initWithPasscodeLength:(NSUInteger)passcodeLength
{
    self = [super init];
    if (self)
    {
        _passcodeLength = passcodeLength;
        
        _circleViews = [NSMutableArray array];
        NSMutableString *format = [NSMutableString stringWithString:@"H:|"];
        NSMutableDictionary *views = [NSMutableDictionary dictionary];
        
        for (NSUInteger i = 0; i < _passcodeLength; i++)
        {
            MQPasscodeInputCircleView *circleView = [[MQPasscodeInputCircleView alloc] init];
            circleView.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:circleView];
            [self addConstraint:[NSLayoutConstraint constraintWithItem:circleView attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self attribute:NSLayoutAttributeTop
                                                            multiplier:1.0f constant:0.0f]];
            [_circleViews addObject:circleView];
            NSString *name = [NSString stringWithFormat:@"circle%lu", (unsigned long)i];
            if (i > 0) {
                [format appendString:@"-(padding)-"];
            }
            [format appendFormat:@"[%@]", name];
            views[name] = circleView;
        }
        
        [format appendString:@"|"];
        NSDictionary *metrics = @{ @"padding" : @(self.circlePadding) };
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:metrics views:views]];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(self.passcodeLength * [MQPasscodeInputCircleView diameter] + (self.passcodeLength - 1) * self.circlePadding,
                      [MQPasscodeInputCircleView diameter]);
}

- (CGFloat)circlePadding
{
    return 2.0f * [MQPasscodeInputCircleView diameter];
}

- (void)fillCircleAtPosition:(NSUInteger)position
{
    NSParameterAssert(position < [self.circleViews count]);
    [self.circleViews[position] setFilled:YES];
}

- (void)unfillCircleAtPosition:(NSUInteger)position
{
    NSParameterAssert(position < [self.circleViews count]);
    [self.circleViews[position] setFilled:NO];
}

- (void)unfillAllCircles
{
    for (MQPasscodeInputCircleView *view in self.circleViews) {
        view.filled = NO;
    }
}

- (void)shakeWithCompletion:(MQPasscodeInputCirclesViewCompletionBlock)completion
{
    self.numberOfShakes = 0;
    self.shakeDirection = -1;
    self.shakeVelocity = MQPasscodeInputCircleViewMaximumNumberOfShakes;
    self.completionBlock = completion;
    [self performShake];
}

- (void)performShake
{
    [UIView animateWithDuration:0.03f animations:^ {
        self.transform = CGAffineTransformMakeTranslation(self.shakeDirection * self.shakeVelocity, 0.0f);
    } completion:^(BOOL finished) {
        if (self.numberOfShakes < MQPasscodeInputCircleViewMaximumNumberOfShakes)
        {
            self.numberOfShakes++;
            self.shakeDirection = -1 * self.shakeDirection;
            self.shakeVelocity = (MQPasscodeInputCircleViewMaximumNumberOfShakes - self.numberOfShakes) * (MQPasscodeInputCircleViewInitialShakeVelocity / MQPasscodeInputCircleViewMaximumNumberOfShakes);
            [self performShake];
        } else {
            self.transform = CGAffineTransformIdentity;
            if (self.completionBlock) {
                self.completionBlock();
                self.completionBlock = nil;
            }
        }
    }];
}

@end

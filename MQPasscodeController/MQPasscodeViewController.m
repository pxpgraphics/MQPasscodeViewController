//
//  MQPasscodeViewController.m
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

#import "MQPasscodeViewController.h"
#import "MQPasscodeView.h"
#import "MQPBlurView.h"

@interface MQPasscodeViewController () <MQPasscodeViewDelegate>

@property (nonatomic, strong) MQPasscodeView *pinView;
@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, assign) NSArray *blurViewContraints;

@end

@implementation MQPasscodeViewController

- (instancetype)initWithDelegate:(id<MQPasscodeViewControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
        _backgroundColor = [UIColor whiteColor];
        _translucentBackground = NO;
        _promptTitle = NSLocalizedStringFromTable(@"prompt_title", @"MQPasscodeViewController", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.translucentBackground) {
        self.view.backgroundColor = [UIColor clearColor];
        [self addBlurView];
    } else {
        self.view.backgroundColor = self.backgroundColor;
    }
    
    self.pinView = [[MQPasscodeView alloc] initWithDelegate:self];
    self.pinView.backgroundColor = self.view.backgroundColor;
    self.pinView.promptTitle = self.promptTitle;
    self.pinView.promptColor = self.promptColor;
    self.pinView.hideLetters = self.hideLetters;
    self.pinView.disableCancel = self.disableCancel;
    self.pinView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.pinView];
    // center pin view
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pinView attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f constant:0.0f]];
    CGFloat pinViewYOffset = 0.0f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        pinViewYOffset = -9.0f;
    } else {
        BOOL isFourInchScreen = (fabs(CGRectGetHeight([[UIScreen mainScreen] bounds]) - 568.0f) < DBL_EPSILON);
        if (isFourInchScreen) {
            pinViewYOffset = 25.5f;
        } else {
            pinViewYOffset = 18.5f;
        }
    }
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pinView attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f constant:pinViewYOffset]];
}

#pragma mark - Properties

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    if ([self.backgroundColor isEqual:backgroundColor]) {
        return;
    }
    _backgroundColor = backgroundColor;
    if (! self.translucentBackground) {
        self.view.backgroundColor = self.backgroundColor;
        self.pinView.backgroundColor = self.backgroundColor;
    }
}

- (void)setTranslucentBackground:(BOOL)translucentBackground
{
    if (self.translucentBackground == translucentBackground) {
        return;
    }
    _translucentBackground = translucentBackground;
    if (self.translucentBackground) {
        self.view.backgroundColor = [UIColor clearColor];
        self.pinView.backgroundColor = [UIColor clearColor];
        [self addBlurView];
    } else {
        self.view.backgroundColor = self.backgroundColor;
        self.pinView.backgroundColor = self.backgroundColor;
        [self removeBlurView];
    }
}

- (void)setPromptTitle:(NSString *)promptTitle
{
    if ([self.promptTitle isEqualToString:promptTitle]) {
        return;
    }
    _promptTitle = [promptTitle copy];
    self.pinView.promptTitle = self.promptTitle;
}

- (void)setPromptColor:(UIColor *)promptColor
{
    if ([self.promptColor isEqual:promptColor]) {
        return;
    }
    _promptColor = promptColor;
    self.pinView.promptColor = self.promptColor;
}

- (void)setHideLetters:(BOOL)hideLetters
{
    if (self.hideLetters == hideLetters) {
        return;
    }
    _hideLetters = hideLetters;
    self.pinView.hideLetters = self.hideLetters;
}

- (void)setDisableCancel:(BOOL)disableCancel
{
    if (self.disableCancel == disableCancel) {
        return;
    }
    _disableCancel = disableCancel;
    self.pinView.disableCancel = self.disableCancel;
}

#pragma mark - Blur

- (void)addBlurView
{
    self.blurView = [[UIImageView alloc] initWithImage:[self blurredContentImage]];
    self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:self.blurView belowSubview:self.pinView];
    NSDictionary *views = @{ @"blurView" : self.blurView };
    NSMutableArray *constraints =
    [NSMutableArray arrayWithArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|"
                                                                           options:0 metrics:nil views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|"
                                                                             options:0 metrics:nil views:views]];
    self.blurViewContraints = constraints;
    [self.view addConstraints:self.blurViewContraints];
}

- (void)removeBlurView
{
    [self.blurView removeFromSuperview];
    self.blurView = nil;
    [self.view removeConstraints:self.blurViewContraints];
    self.blurViewContraints = nil;
}

- (UIImage*)blurredContentImage
{
	NSLog(@"BLURRRRRR!!!!");
	return nil;
//    UIView *contentView = [[[UIApplication sharedApplication] keyWindow] viewWithTag:MQPasscodeViewControllerContentViewTag];
//    if (! contentView) {
//        return nil;
//    }
//    UIGraphicsBeginImageContext(self.view.bounds.size);
//    [contentView drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return [image applyBlurWithRadius:20.0f tintColor:[UIColor colorWithWhite:1.0f alpha:0.25f]
//                saturationDeltaFactor:1.8f maskImage:nil];
}

#pragma mark - MQPasscodeViewDelegate

- (NSUInteger)pinLengthForPinView:(MQPasscodeView *)pinView
{
    NSUInteger pinLength = [self.delegate pinLengthForPinViewController:self];
    NSAssert(pinLength > 0, @"PIN length must be greater than 0");
    return MAX(pinLength, (NSUInteger)1);
}

- (BOOL)pinView:(MQPasscodeView *)pinView isPinValid:(NSString *)pin
{
    return [self.delegate pinViewController:self isPinValid:pin];
}

- (void)cancelButtonTappedInPinView:(MQPasscodeView *)pinView
{
    if ([self.delegate respondsToSelector:@selector(pinViewControllerWillDismissAfterPinEntryWasCancelled:)]) {
        [self.delegate pinViewControllerWillDismissAfterPinEntryWasCancelled:self];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(pinViewControllerDidDismissAfterPinEntryWasCancelled:)]) {
            [self.delegate pinViewControllerDidDismissAfterPinEntryWasCancelled:self];
        }
    }];
}

- (void)correctPinWasEnteredInPinView:(MQPasscodeView *)pinView
{
    if ([self.delegate respondsToSelector:@selector(pinViewControllerWillDismissAfterPinEntryWasSuccessful:)]) {
        [self.delegate pinViewControllerWillDismissAfterPinEntryWasSuccessful:self];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(pinViewControllerDidDismissAfterPinEntryWasSuccessful:)]) {
            [self.delegate pinViewControllerDidDismissAfterPinEntryWasSuccessful:self];
        }
    }];
}

- (void)incorrectPinWasEnteredInPinView:(MQPasscodeView *)pinView
{
    if ([self.delegate userCanRetryInPinViewController:self]) {
        if ([self.delegate respondsToSelector:@selector(incorrectPinEnteredInPinViewController:)]) {
            [self.delegate incorrectPinEnteredInPinViewController:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:)]) {
            [self.delegate pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:self];
        }
        [self dismissViewControllerAnimated:YES completion:^{
            if ([self.delegate respondsToSelector:@selector(pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:)]) {
                [self.delegate pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:self];
            }
        }];
    }
}

@end

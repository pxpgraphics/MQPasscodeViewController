//
//  MQPasscodeViewController.h
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

#import <UIKit/UIKit.h>

@class MQPasscodeViewController;

// when using translucentBackground assign this tag to the view that should be blurred
static const NSInteger MQPasscodeViewControllerContentViewTag = 14742;

@protocol MQPasscodeViewControllerDelegate <NSObject>

@required
- (NSUInteger)pinLengthForPinViewController:(MQPasscodeViewController *)pinViewController;
- (BOOL)pinViewController:(MQPasscodeViewController *)pinViewController isPinValid:(NSString *)pin;
- (BOOL)userCanRetryInPinViewController:(MQPasscodeViewController *)pinViewController;

@optional
- (void)incorrectPinEnteredInPinViewController:(MQPasscodeViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasSuccessful:(MQPasscodeViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasSuccessful:(MQPasscodeViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasUnsuccessful:(MQPasscodeViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasUnsuccessful:(MQPasscodeViewController *)pinViewController;
- (void)pinViewControllerWillDismissAfterPinEntryWasCancelled:(MQPasscodeViewController *)pinViewController;
- (void)pinViewControllerDidDismissAfterPinEntryWasCancelled:(MQPasscodeViewController *)pinViewController;

@end

@interface MQPasscodeViewController : UIViewController

@property (nonatomic, weak) id<MQPasscodeViewControllerDelegate> delegate;
@property (nonatomic, strong) UIColor *backgroundColor; // is only used if translucentBackground == NO
@property (nonatomic, assign) BOOL translucentBackground;
@property (nonatomic, copy) NSString *promptTitle;
@property (nonatomic, strong) UIColor *promptColor;
@property (nonatomic, assign) BOOL hideLetters; // hides the letters on the number buttons
@property (nonatomic, assign) BOOL disableCancel; // hides the cancel button

- (instancetype)initWithDelegate:(id<MQPasscodeViewControllerDelegate>)delegate;

@end

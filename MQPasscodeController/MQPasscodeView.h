//
//  MQPasscodeView.h
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

@class MQPasscodeView;

@protocol MQPasscodeViewDelegate <NSObject>

@required
- (NSUInteger)pinLengthForPinView:(MQPasscodeView *)pinView;
- (BOOL)pinView:(MQPasscodeView *)pinView isPinValid:(NSString *)pin;
- (void)cancelButtonTappedInPinView:(MQPasscodeView *)pinView;
- (void)correctPinWasEnteredInPinView:(MQPasscodeView *)pinView;
- (void)incorrectPinWasEnteredInPinView:(MQPasscodeView *)pinView;

@end

@interface MQPasscodeView : UIView

@property (nonatomic, weak) id<MQPasscodeViewDelegate> delegate;
@property (nonatomic, copy) NSString *promptTitle;
@property (nonatomic, strong) UIColor *promptColor;
@property (nonatomic, assign) BOOL hideLetters;
@property (nonatomic, assign) BOOL disableCancel;

- (instancetype)initWithDelegate:(id<MQPasscodeViewDelegate>)delegate;

@end

//
//  MQPasscodeNumPadView.m
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

#import "MQPasscodeNumPadView.h"
#import "MQPasscodeNumPadButton.h"

@interface MQPasscodeNumPadView ()

@property (nonatomic, assign) CGFloat hPadding;
@property (nonatomic, assign) CGFloat vPadding;

@end

@implementation MQPasscodeNumPadView

- (instancetype)initWithDelegate:(id<MQPasscodeNumPadViewDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _hPadding = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 24.0f : 20.0f;
        _vPadding = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 19.0f : 13.0f;
        
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    // remove existing views
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableString *vFormat = [NSMutableString stringWithString:@"V:|"];
    NSMutableDictionary *rowViews = [NSMutableDictionary dictionary];
    
    for (NSUInteger row = 0; row < 4; row++)
    {
        UIView *rowView = [[UIView alloc] init];
        rowView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:rowView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:rowView attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f constant:0.0f]];
        
        NSString *rowName = [NSString stringWithFormat:@"row%lu", (unsigned long)row];
        if (row > 0) {
            [vFormat appendString:@"-(vPadding)-"];
        }
        [vFormat appendFormat:@"[%@(==rowHeight)]", rowName];
        rowViews[rowName] = rowView;
        
        NSMutableString *hFormat = [NSMutableString stringWithString:@"H:|"];
        NSMutableDictionary *buttonViews = [NSMutableDictionary dictionary];
        
        for (NSUInteger col = 0; col < 3; col++)
        {
            if (row == 3 && col != 1) {
                // only one button on last row
                continue;
            }
            
            NSUInteger number = (row < 3) ? row * 3 + col + 1 : 0;
            MQPasscodeNumPadButton *button = [[MQPasscodeNumPadButton alloc] initWithNumber:number
                                                                    letters:[self lettersForRow:row column:col]];
            button.translatesAutoresizingMaskIntoConstraints = NO;
            button.backgroundColor = self.backgroundColor;
            [button addTarget:self action:@selector(numberButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [rowView addSubview:button];
            
            NSString *buttonName = [NSString stringWithFormat:@"button%lu%lu", (unsigned long)row, (unsigned long)col];
            [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|[%@]|", buttonName]
                                                                            options:0 metrics:nil views:@{ buttonName : button }]];
            
            if (row < 3) {
                if ([buttonViews count] > 0) {
                    [hFormat appendString:@"-(hPadding)-"];
                }
                [hFormat appendFormat:@"[%@]", buttonName];
            } else {
                [hFormat appendFormat:@"-[%@]-", buttonName];
            }
            buttonViews[buttonName] = button;
        }
        
        [hFormat appendString:@"|"];
        NSDictionary *metrics = @{ @"hPadding" : @(_hPadding) };
        [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:hFormat options:0 metrics:metrics views:buttonViews]];
    }
    
    [vFormat appendString:@"|"];
    NSDictionary *metrics = @{ @"rowHeight" : @([MQPasscodeNumPadButton diameter]),
                               @"vPadding" : @(_vPadding) };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vFormat options:0 metrics:metrics views:rowViews]];
}

- (NSString *)lettersForRow:(NSUInteger)row column:(NSUInteger)col
{
    if (self.hideLetters) {
        return nil;
    }
    
    switch (row)
    {
        case 0:
        {
            switch (col)
            {
                case 0:
                    return @" "; // empty string to trigger shifted number position
                case 1:
                    return @"ABC";
                case 2:
                    return @"DEF";
            }
        }
        case 1:
        {
            switch (col)
            {
                case 0:
                    return @"GHI";
                case 1:
                    return @"JKL";
                case 2:
                    return @"MNO";
            }
        }
        case 2:
        {
            switch (col)
            {
                case 0:
                    return @"PQRS";
                case 1:
                    return @"TUV";
                case 2:
                    return @"WXYZ";
            }
        }
    }
    return nil;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(3.0f * [MQPasscodeNumPadButton diameter] + 2.0f * self.hPadding,
                      4.0f * [MQPasscodeNumPadButton diameter] + 3.0f * self.vPadding);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    for (UIView *rowView in self.subviews) {
        for (UIView *button in rowView.subviews) {
            button.backgroundColor = self.backgroundColor;
        }
    }
}

- (void)setHideLetters:(BOOL)hideLetters
{
    if (self.hideLetters == hideLetters) {
        return;
    }
    _hideLetters = hideLetters;
    [self setupViews];
}

- (void)numberButtonTapped:(id)sender
{
    [self.delegate pinNumPadView:self numberTapped:[(MQPasscodeNumPadButton *)sender number]];
}

@end

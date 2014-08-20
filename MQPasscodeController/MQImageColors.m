//
//  MQImageColors.m
//  MQPasscodeControllerSample
//
//  Created by Paris Pinkney on 8/20/14.
//

/*
 Copyright (c) 2013 timominous

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

#import "MQImageColors.h"
#import "MQCountedColor.h"

CGFloat const kMQImageColorsColorThresholdMinimumPercentage = 0.01;

static CGFloat const MQImageColorsScaledSize = 100.0;

@interface MQImageColors ()

@property (nonatomic, readwrite) NSUInteger count;
@property (nonatomic, strong, readwrite) NSArray *colors;
@property (nonatomic, strong) UIImage *scaledImage;

@end

@implementation MQImageColors

#pragma mark - Lifecycle

- (instancetype)initWithImage:(UIImage *)image count:(NSUInteger)count
{
	self = [super init];
	if (self) {
		_count = count;
		_colors = @[];
		CGSize scaledSize = CGSizeMake(MQImageColorsScaledSize, MQImageColorsScaledSize);
		_scaledImage = [UIImage imageWithImage:image scaledToSize:scaledSize];
		[self detectColorsFromImage:_scaledImage];
	}
	return self;
}

#pragma mark - Private methods

- (void)detectColorsFromImage:(UIImage *)image
{
	if (!image) {
		return;
	}

	NSCountedSet *imageColors;
	NSMutableArray *finalColors = [NSMutableArray array];
	[finalColors addObjectsFromArray:[self findColorsOfImage:image imageColors:&imageColors]];
	while (finalColors.count < self.count)
		[finalColors addObject:[UIColor whiteColor]];
	self.colors = [NSArray arrayWithArray:finalColors];
}

- (NSArray *)findColorsOfImage:(UIImage *)image imageColors:(NSCountedSet * __autoreleasing *)colors
{
	size_t width = CGImageGetWidth(image.CGImage);
	size_t height = CGImageGetHeight(image.CGImage);

	NSCountedSet *imageColors = [[NSCountedSet alloc] initWithCapacity:width * height];

	for (NSUInteger x = 0; x < width; x++) {
		for (NSUInteger y = 0; y < height; y++) {
			UIColor *color = [UIImage colorFromImage:image atPoint:CGPointMake(x, y)];
			[imageColors addObject:color];
		}
	}
	*colors = imageColors;

	NSEnumerator *enumerator = [imageColors objectEnumerator];
	UIColor *curColor = nil;
	NSMutableArray *sortedColors = [NSMutableArray arrayWithCapacity:imageColors.count];
	NSMutableArray *resultColors = [NSMutableArray array];

	while ((curColor = [enumerator nextObject]) != nil) {
		curColor = [curColor colorWithMinimumSaturation:0.15f];
		NSUInteger colorCount = [imageColors countForObject:curColor];
		[sortedColors addObject:[[MQCountedColor alloc] initWithColor:curColor count:colorCount]];
	}

	[sortedColors sortUsingSelector:@selector(compare:)];

	for (MQCountedColor *countedColor in sortedColors) {
		curColor = countedColor.color;
		BOOL continueFlag = NO;
		for (UIColor *c in resultColors) {
			if (![curColor isDistinct:c]) {
				continueFlag = YES;
				break;
			}
		}
		if (continueFlag) {
			continue;
		}
		if (resultColors.count < self.count) {
			[resultColors addObject:curColor];
		} else {
			break;
		}
	}
	return [NSArray arrayWithArray:resultColors];
}

@end

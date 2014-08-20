//
//  MQViewController.m
//  MQPasscodeControllerSample
//
//  Created by Paris Pinkney on 8/20/14.
//  Copyright (c) 2014 Marqeta, Inc. All rights reserved.
//

#import "MQViewController.h"
#import "MQPasscodeViewController.h"

static NSUInteger const MQViewControllerMaximumNumberOfPasscodeAttempts = 3;

@interface MQViewController () <MQPasscodeViewControllerDelegate>

@property (nonatomic) NSUInteger remainingAttempts;
@property (nonatomic, assign, getter = isLocked) BOOL locked;
@property (nonatomic, copy) NSString *correctPasscode;
@property (nonatomic, strong) UIButton *passcodeButton;

@end

@implementation MQViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.modalPresentationStyle = UIModalPresentationFullScreen;

	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unsplash_52bf2bb8d2dd0_1.jpg"]];
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	imageView.frame = self.view.bounds;
	imageView.tag = MQPasscodeViewControllerContentViewTag; // Tag to blur this view.
	[self.view addSubview:imageView];

	self.correctPasscode = @"12345";

	self.passcodeButton = [UIButton buttonWithType:UIButtonTypeSystem];
	self.passcodeButton.tintColor = [UIColor whiteColor];
	self.passcodeButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.passcodeButton setTitle:@"Enter Passcode" forState:UIControlStateNormal];
	[self.view addSubview:self.passcodeButton];

	NSLayoutConstraint *passcodeButtonHConstraint = [NSLayoutConstraint
													 constraintWithItem:self.passcodeButton attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
													 toItem:self.view attribute:NSLayoutAttributeCenterX
													 multiplier:1.0f constant:0.0f];
	[self.view addConstraint:passcodeButtonHConstraint];

	NSLayoutConstraint *passcodeButtonVConstraint = [NSLayoutConstraint
													 constraintWithItem:self.passcodeButton attribute:NSLayoutAttributeCenterY
													 relatedBy:NSLayoutRelationEqual
													 toItem:self.view attribute:NSLayoutAttributeTop
													 multiplier:1.0f constant:60.0f];
	[self.view addConstraint:passcodeButtonVConstraint];

	self.locked = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:)
												 name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification
												  object:nil];
}

#pragma mark - Custom accessors

- (void)setLocked:(BOOL)locked
{
	if (_locked == locked) {
		return;
	}

	_locked = locked;

	if (_locked) {
		self.remainingAttempts = MQViewControllerMaximumNumberOfPasscodeAttempts;
		[self.passcodeButton removeTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
		[self.passcodeButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
	} else {
		[self.passcodeButton removeTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
		[self.passcodeButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
	}
}

#pragma mark - MQPasscodeViewControllerDelegate

- (NSUInteger)passcodeLengthForpasscodeViewController:(MQPasscodeViewController *)passcodeViewController
{
	return 5;
}

- (BOOL)passcodeViewController:(MQPasscodeViewController *)passcodeViewController isPinValid:(NSString *)pin
{
	if ([pin isEqualToString:self.correctPasscode]) {
		return YES;
	}

	self.remainingAttempts--;
	return NO;
}

- (BOOL)userCanRetryInpasscodeViewController:(MQPasscodeViewController *)passcodeViewController
{
	return (self.remainingAttempts > 0);
}

- (void)incorrectPinEnteredInpasscodeViewController:(MQPasscodeViewController *)passcodeViewController
{
    if (self.remainingAttempts > MQViewControllerMaximumNumberOfPasscodeAttempts / 2) {
        return;
    }

	NSString *message;
	if (self.remainingAttempts == 1) {
		message = @"You can only try again once more!";
	} else {
		message = [NSString stringWithFormat:@"You can try again %lu times.", (unsigned long)self.remainingAttempts];
	}

	[[[UIAlertView alloc] initWithTitle:@"Incorrect Passcode"
								message:message
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];

}

- (void)passcodeViewControllerWillDismissAfterPinEntryWasSuccessful:(MQPasscodeViewController *)passcodeViewController
{
    self.locked = NO;
    [self.passcodeButton setTitle:@"Logout" forState:UIControlStateNormal];
}

- (void)passcodeViewControllerWillDismissAfterPinEntryWasUnsuccessful:(MQPasscodeViewController *)passcodeViewController
{
    self.locked = YES;
    [self.passcodeButton setTitle:@"Access Denied / Enter PIN" forState:UIControlStateNormal];
}

- (void)passcodeViewControllerWillDismissAfterPinEntryWasCancelled:(MQPasscodeViewController *)passcodeViewController
{
    if (!self.locked) {
        [self logout:self];
    }
}

#pragma mark - Private methods

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
	if ([self isLocked]) {
		return;
	}

	[self showPasscodeViewAnimated:NO];
}

- (void)login:(id)sender
{
	[self showPasscodeViewAnimated:NO];
}

- (void)logout:(id)sender
{
	self.locked = YES;
	[self.passcodeButton setTitle:@"Enter Passcode" forState:UIControlStateNormal];
}

- (void)showPasscodeViewAnimated:(BOOL)animated
{
	MQPasscodeViewController *passcodeVC = [[MQPasscodeViewController alloc] initWithDelegate:self];
	passcodeVC.promptTitle = @"Enter Passcode";
	passcodeVC.translucentBackground = YES;
	[self presentViewController:passcodeVC animated:animated completion:nil];
}

@end

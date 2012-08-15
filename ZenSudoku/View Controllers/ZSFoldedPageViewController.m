//
//  ZSFoldedPageViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 7/9/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSFoldedPageViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

@interface ZSFoldedPageViewController () {
	CGPoint _foldStartPoint;
	BOOL _foldedCornerTouchCrossedTapThreshold;

	dispatch_queue_t _screenshotRenderDispatchQueue;
	dispatch_group_t _screenshotRenderDispatchGroup;
	
	BOOL _deferScreenshotUpdate;
	BOOL _deferedScreenshotUpdateIsSychronous;
	
	AVAudioPlayer *_pageFlipAudioPlayer;
	AVAudioPlayer *_pageFlipAudioPlayer2;
	AVAudioPlayer *_pageFlipAudioPlayer3;
}

@end

@implementation ZSFoldedPageViewController

@synthesize animationDelegate;

@synthesize innerView;
@synthesize innerViewImage;
@synthesize foldedCornerViewController;
@synthesize foldedCornerVisibleOnLoad;
@synthesize animateCornerWhenPromoted;

@synthesize needsScreenshotUpdate;
@synthesize forceScreenshotUpdateOnDrag;

- (id)init {
	self = [super init];
	
	if (self) {
		foldedCornerVisibleOnLoad = NO;
		_foldedCornerTouchCrossedTapThreshold = NO;
		
		_screenshotRenderDispatchQueue = dispatch_queue_create("com.tenfoursoftware.screenshotRenderQueue", NULL);
		_screenshotRenderDispatchGroup = dispatch_group_create();
		
		innerViewImage = [UIImage imageNamed:@"ForwardsPage.png"];
		
		animateCornerWhenPromoted = YES;
	}
	
	return self;
}

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 314, 460)];
}

- (void)viewDidLoad {
	// Build the inner view.
	innerView = [[UIImageView alloc] initWithImage:self.innerViewImage];
	innerView.userInteractionEnabled = YES;
	innerView.frame = self.view.frame;
	[self.view addSubview:innerView];
	
	// Build the folded corner.
	foldedCornerViewController = [[ZSFoldedCornerViewController alloc] init];
	foldedCornerViewController.view.hidden = !self.foldedCornerVisibleOnLoad;
	foldedCornerViewController.touchDelegate = self;
	foldedCornerViewController.animationDelegate = self;
	[self.view addSubview:foldedCornerViewController.view];
	
	// Initialize the audio players.
	NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"PageFlip1" ofType:@"wav"];
	NSURL *newURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
	_pageFlipAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:newURL error:nil];
	
	NSString *soundFilePath2 = [[NSBundle mainBundle] pathForResource:@"PageFlip2" ofType:@"wav"];
	NSURL *newURL2 = [[NSURL alloc] initFileURLWithPath: soundFilePath2];
	_pageFlipAudioPlayer2 = [[AVAudioPlayer alloc] initWithContentsOfURL:newURL2 error:nil];
	
	NSString *soundFilePath3 = [[NSBundle mainBundle] pathForResource:@"PageFlip3" ofType:@"wav"];
	NSURL *newURL3 = [[NSURL alloc] initFileURLWithPath: soundFilePath3];
	_pageFlipAudioPlayer3 = [[AVAudioPlayer alloc] initWithContentsOfURL:newURL3 error:nil];
	
	// Reset to start.
	if (self.foldedCornerVisibleOnLoad) {
		[foldedCornerViewController resetToDefaultPosition];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	// Queue the screenshot for update.
	self.needsScreenshotUpdate = YES;
	[self updateScreenshotSynchronous:NO];
}

- (void)viewWasPromotedToFront {
	if (self.animateCornerWhenPromoted) {
		[self.foldedCornerViewController resetToStartPosition];
		[self.foldedCornerViewController animateStartFold];
	}
}

- (void)viewWasRemovedFromBook {
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[self.foldedCornerViewController pauseAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[self.foldedCornerViewController resumeAnimation];
}

- (UIImage *)getScreenshotImage {
    UIGraphicsBeginImageContextWithOptions(self.innerView.bounds.size, NO, 0.0f);
	
	[self.innerView.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return screenshot;
}

- (void)updateScreenshotSynchronous:(BOOL)synchronous {
	dispatch_group_async(_screenshotRenderDispatchGroup, _screenshotRenderDispatchQueue, ^{
		if (self.needsScreenshotUpdate) {
			if (self.innerView.hidden) {
				_deferScreenshotUpdate = YES;
				_deferedScreenshotUpdateIsSychronous = _deferedScreenshotUpdateIsSychronous || synchronous;
			} else {
				self.needsScreenshotUpdate = NO;
				
				[self.foldedCornerViewController setPageImage:[self getScreenshotImage]];
			}
		}
	});
	
	if (synchronous) {
		dispatch_group_wait(_screenshotRenderDispatchGroup, DISPATCH_TIME_FOREVER);
	}
}

- (void)setScreenshotVisible:(BOOL)visible {
	if (visible) {
		self.foldedCornerViewController.drawPage = YES;
		[self.foldedCornerViewController pushUpdate];
		
		self.innerView.hidden = YES;
	} else {
		self.innerView.hidden = NO;
		
		self.foldedCornerViewController.drawPage = NO;
		[self.foldedCornerViewController pushUpdate];
		
		if (_deferScreenshotUpdate) {
			BOOL synchronous = _deferedScreenshotUpdateIsSychronous;
			
			_deferScreenshotUpdate = NO;
			_deferedScreenshotUpdateIsSychronous = NO;
			
			[self updateScreenshotSynchronous:synchronous];
		}
	}
}

- (void)turnPage {
	[self updateScreenshotSynchronous:YES];
	
	[self setScreenshotVisible:YES];
	
	[self _playPageFlipSound];
	
	[self.foldedCornerViewController animatePageTurnSlower];
	
	self.innerView.hidden = YES;
}

- (void)foldedCornerRestoredToDefaultPoint {
	[self setScreenshotVisible:NO];
}

- (void)_playPageFlipSound {
	switch (arc4random() % 3) {
		default:
		case 0: [_pageFlipAudioPlayer play]; break;
		case 1: [_pageFlipAudioPlayer2 play]; break;
		case 2: [_pageFlipAudioPlayer3 play]; break;
	}
}

#pragma mark - ZSFoldedCornerViewControllerTouchDelegate Implementation

- (void)foldedCornerViewController:(ZSFoldedCornerViewController *)viewController touchStartedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions {
	_foldStartPoint = foldPoint;
	_foldedCornerTouchCrossedTapThreshold = NO;
	
	// Force a screenshot update if one is needed.
	if (self.forceScreenshotUpdateOnDrag) {
		self.needsScreenshotUpdate = YES;
	}
	
	[self updateScreenshotSynchronous:YES];
	
	[self setScreenshotVisible:YES];
}

- (void)foldedCornerViewController:(ZSFoldedCornerViewController *)viewController touchMovedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions {
	if (_foldedCornerTouchCrossedTapThreshold || (foldPoint.x - _foldStartPoint.x) * (foldPoint.x - _foldStartPoint.x) + (foldPoint.y - _foldStartPoint.y) * (foldPoint.y - _foldStartPoint.y) > 16) {
		_foldedCornerTouchCrossedTapThreshold = YES;
	}
}

- (void)foldedCornerViewController:(ZSFoldedCornerViewController *)viewController touchEndedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions {
	if (_foldedCornerTouchCrossedTapThreshold) {
		if (foldPoint.x > self.foldedCornerViewController.view.frame.size.width / 2) {
			[self _playPageFlipSound];
			[self.foldedCornerViewController animatePageTurn];
		} else {
			[self.foldedCornerViewController animateSendFoldBackToCorner];
		}
	} else {
		[self.foldedCornerViewController animateCornerTug];
	}
}

#pragma mark - ZSFoldedCornerViewControllerAnimationDelegate Implementation

- (void)pageTurnAnimationDidFinishWithViewController:(ZSFoldedCornerViewController *)viewController {
	if ([self.animationDelegate respondsToSelector: @selector(pageTurnAnimationDidFinishWithViewController:)]) {
		[self.animationDelegate pageTurnAnimationDidFinishWithViewController:self];
	}
}

- (void)sendFoldBackToCornerAnimationDidFinishWithViewController:(ZSFoldedCornerViewController *)viewController {
	[self foldedCornerRestoredToDefaultPoint];
	
	if ([self.animationDelegate respondsToSelector: @selector(sendFoldBackToCornerAnimationDidFinishWithViewController:)]) {
		[self.animationDelegate sendFoldBackToCornerAnimationDidFinishWithViewController:self];
	}
}

- (void)cornerTugAnimationDidFinishWithViewController:(ZSFoldedCornerViewController *)viewController {
	[self foldedCornerRestoredToDefaultPoint];
	
	if ([self.animationDelegate respondsToSelector: @selector(cornerTugAnimationDidFinishWithViewController:)]) {
		[self.animationDelegate cornerTugAnimationDidFinishWithViewController:self];
	}
}

- (void)startFoldAnimationDidFinishWithViewController:(ZSFoldedCornerViewController *)viewController {
	[self foldedCornerRestoredToDefaultPoint];
	
	if ([self.animationDelegate respondsToSelector: @selector(startFoldAnimationDidFinishWithViewController:)]) {
		[self.animationDelegate startFoldAnimationDidFinishWithViewController:self];
	}
}

@end

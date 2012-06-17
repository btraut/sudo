//
//  ZSFoldedCornerView.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSFoldedCornerView.h"

#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}

#define DEFAULT_WIDTH 48
#define DEFAULT_HEIGHT 51

@interface ZSFoldedCornerView () {
	CGPoint _touchStartPoint;
	CGPoint _foldStartPoint;
	CGPoint _foldPoint;
	
	UIImage *_cornerImage;
	UIImage *_shadowBlobImage;
	
	CGImageRef _cornerImageCG;
	CGImageRef _shadowBlobImageCG;
	
	CGGradientRef _dropShadowGradient;
	CGGradientRef _innerShadowGradient;
	
	CGFloat _frameHeightClipped;
	
	NSInteger graphicsMultipleFactor;
}

@end

@implementation ZSFoldedCornerView

@synthesize touchDelegate;
@synthesize H, phi, theta, cornerTranslation, frameDimensions, foldDimensions, shadowStart, underShadowDimensions, underShadowFoldedPageOffset;

- (id)init {
	return [self initWithFrame:CGRectMake(0, 0, 314, 460)];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self != nil) {
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
		self.clearsContextBeforeDrawing = YES;
		self.clipsToBounds = YES;
		self.contentMode = UIViewContentModeBottomLeft;
		
		if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && [UIScreen mainScreen].scale == 2.0) {
			// Retina Display
			graphicsMultipleFactor = 2;
		} else {
			// Non-Retina Display
			graphicsMultipleFactor = 1;
		}
		
		// Load the images.
		_cornerImage = [UIImage imageNamed:@"BackwardsPage.png"];
		_cornerImageCG = [_cornerImage CGImage];
		
		_shadowBlobImage = [UIImage imageNamed:@"ShadowBlobTest2.png"];
		_shadowBlobImageCG = [_shadowBlobImage CGImage];
		
		// Init the fold point defaults.
		_foldStartPoint = CGPointMake(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		_foldPoint = CGPointMake(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		
		// Cache the gradients.
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		
		CGFloat dropShadowGradientColors[] = {
			0.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0, 0.15,
			0.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0, 0.0,
		};
		_dropShadowGradient = CGGradientCreateWithColorComponents(rgb, dropShadowGradientColors, NULL, sizeof(dropShadowGradientColors) / (sizeof(dropShadowGradientColors[0]) * 4));
		
		CGFloat innerShadowGradientColors[] = {
			0.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0, 0.08,
			0.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0, 0.0,
		};
		_innerShadowGradient = CGGradientCreateWithColorComponents(rgb, innerShadowGradientColors, NULL, sizeof(innerShadowGradientColors) / (sizeof(innerShadowGradientColors[0]) * 4));
		
		CGColorSpaceRelease(rgb);
	}
	
	return self;
}

- (void)dealloc {
	CGGradientRelease(_dropShadowGradient);
}

- (void)recalculateDimensions {
	double cosPhi, sinPhi, tanPhi;
	
	// Start with the math.
	H = sqrt(_foldPoint.x * _foldPoint.x + _foldPoint.y * _foldPoint.y);
	
	if (_foldPoint.x < _foldPoint.y) {
		tanPhi = _foldPoint.x / _foldPoint.y;
		phi = atan(tanPhi);
		cosPhi = cos(phi);
		sinPhi = sin(phi);
		
		theta = (M_PI / 2) - 2 * phi;
		frameDimensions.width = H / (2 * sinPhi);
		frameDimensions.height = _foldPoint.y;
		cornerTranslation.x = frameDimensions.width - _foldPoint.x;
		cornerTranslation.y = 0;
		foldDimensions.width = frameDimensions.width;
		foldDimensions.height = frameDimensions.width * tanPhi;
		
		shadowStart.x = H * sinPhi / 2;
		shadowStart.y = -H * cosPhi / 2;
	} else {
		tanPhi = _foldPoint.y / _foldPoint.x;
		phi = atan(tanPhi);
		cosPhi = cos(phi);
		sinPhi = sin(phi);
		
		theta = - ((M_PI / 2) - 2 * phi);
		frameDimensions.width = _foldPoint.x;
		frameDimensions.height = H / (2 * sinPhi);
		cornerTranslation.x = 0;
		cornerTranslation.y = frameDimensions.height - _foldPoint.y;
		foldDimensions.width = frameDimensions.height * tanPhi;
		foldDimensions.height = frameDimensions.height;
		
		shadowStart.x = H * cosPhi / 2;
		shadowStart.y = -H * sinPhi / 2;
	}
	
//	if (foldDimensions.width > _cornerImage.size.width) {
//		foldDimensions.width = _cornerImage.size.width;
//	}
//	
//	if (foldDimensions.height > _cornerImage.size.height) {
//		foldDimensions.height = _cornerImage.size.height;
//	}
	
	underShadowDimensions.width = 1.22 * foldDimensions.height;
	underShadowDimensions.height = 1.22 * foldDimensions.width;
	
	double crossDimension = sqrt(0.0484 * (foldDimensions.width * foldDimensions.width + foldDimensions.height * foldDimensions.height));
	double crossAngle = atan(_foldPoint.x / _foldPoint.y);
	
	underShadowFoldedPageOffset.width = crossDimension * sin(crossAngle);
	underShadowFoldedPageOffset.height = crossDimension * cos(crossAngle);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if (point.x >= self.frame.size.width - _foldStartPoint.x && point.y <= _foldStartPoint.y) {
		return YES;
	}
	
	return NO;
}

- (void)drawRect:(CGRect)rect {
	// Initialize the context.
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	// Reset the context.
	CGAffineTransform resetContextTransform = CGContextGetCTM(context);
	resetContextTransform = CGAffineTransformInvert(resetContextTransform);
	resetContextTransform = CGAffineTransformScale(resetContextTransform, graphicsMultipleFactor, graphicsMultipleFactor);
	CGContextConcatCTM(context, resetContextTransform);
	
	// Shift context to the perspective of the folded paper (page tipped on its side and rotated to the angle based on the user's drag position). All
	// subsequent effects drawn will be relative to the result of this transform.
	CGAffineTransform cornerTransform = CGAffineTransformIdentity;
	cornerTransform = CGAffineTransformTranslate(cornerTransform, self.frame.size.width - (underShadowFoldedPageOffset.width + frameDimensions.width), self.frame.size.height - (underShadowFoldedPageOffset.height + frameDimensions.height));
	cornerTransform = CGAffineTransformTranslate(cornerTransform, underShadowFoldedPageOffset.width, underShadowFoldedPageOffset.height);
	cornerTransform = CGAffineTransformTranslate(cornerTransform, cornerTranslation.x, cornerTranslation.y);
	cornerTransform = CGAffineTransformRotate(cornerTransform, theta);
	cornerTransform = CGAffineTransformRotate(cornerTransform, M_PI / 2);
	CGContextConcatCTM(context, cornerTransform);
	
	// ===================================== Start of shadow drawing ===================================== //
	
	// Start a separate graphics context for the under shadow.
	CGContextSaveGState(context);
	
	// Transform the shadow blob.
	CGAffineTransform underShadowTransform = CGAffineTransformIdentity;
	underShadowTransform = CGAffineTransformTranslate(underShadowTransform, foldDimensions.width - underShadowDimensions.height, underShadowDimensions.width - foldDimensions.height);
	CGContextConcatCTM(context, underShadowTransform);
	
	// Cut the corner off the folded section.
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, underShadowDimensions.height, 0);
	CGContextAddLineToPoint(context, underShadowDimensions.height, foldDimensions.height - underShadowDimensions.width);
	CGContextAddLineToPoint(context, underShadowDimensions.height - foldDimensions.width, -underShadowDimensions.width);
	CGContextAddLineToPoint(context, 0, -underShadowDimensions.width);
	CGContextAddLineToPoint(context, 0, 0);
	CGContextClosePath(context);
	CGContextClip(context);
	
	// Resize and position the shadow graphic.
	underShadowTransform = CGAffineTransformIdentity;
	underShadowTransform = CGAffineTransformScale(underShadowTransform, underShadowDimensions.height, underShadowDimensions.width);
	underShadowTransform = CGAffineTransformScale(underShadowTransform, 1 / _shadowBlobImage.size.height, 1 / _shadowBlobImage.size.width);
	CGContextConcatCTM(context, underShadowTransform);
	
	// Draw the shadow blob image.
	CGContextDrawImage(context, CGRectMake(0, -_shadowBlobImage.size.height, _shadowBlobImage.size.width, _shadowBlobImage.size.height), _shadowBlobImageCG);
	
	// Finish up the graphics context for the under shadow.
	CGContextRestoreGState(context);
	
	// ====================================== End of shadow drawing ====================================== //
	
	// Draw the drop shadow gradient (the gradient that lies outside the folded corner to the top/right).
	CGContextDrawLinearGradient(context, _dropShadowGradient, shadowStart, CGPointMake(shadowStart.x * 7 / 4, shadowStart.y * 7 / 4), 0);
	
	// Cut the corner off the folded section.
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, foldDimensions.width, 0);
	CGContextAddLineToPoint(context, 0, -foldDimensions.height);
	CGContextAddLineToPoint(context, 0, 0);
	CGContextClosePath(context);
	CGContextClip(context);
		
	// Draw the folded corner image.
	CGContextDrawImage(context, CGRectMake(0, -_cornerImage.size.height, _cornerImage.size.width, _cornerImage.size.height), _cornerImageCG);

	// Draw the inner shadow gradient.
	CGContextDrawLinearGradient(context, _innerShadowGradient, shadowStart, CGPointMake(shadowStart.x * 1 / 4, shadowStart.y * 1 / 4), kCGGradientDrawsBeforeStartLocation);
	
	// Clean up.
	CGContextRestoreGState(context);
}

- (void)setEffectiveFoldPointForTouchPoint:(CGPoint)touchPoint {
	double parentWidth = self.superview.frame.size.width;
	
	CGPoint effectiveTouchPoint = touchPoint;
	if (effectiveTouchPoint.y < 0) {
		effectiveTouchPoint.y = 0;
	}
	
	CGPoint paperTipPoint = CGPointMake((parentWidth - _foldStartPoint.x) + (effectiveTouchPoint.x - _touchStartPoint.x), _foldStartPoint.y + (effectiveTouchPoint.y - _touchStartPoint.y));
	
	double touchLengthSquared = (paperTipPoint.x * paperTipPoint.x) + (paperTipPoint.y * paperTipPoint.y);
	double maxLengthSquared = parentWidth * parentWidth;
	
	// If the paper isn't folded too much by the current touch point, calculate an effective fold point that would lie within the fold limits.
	if (touchLengthSquared > maxLengthSquared) {
		double touchLength = sqrt(touchLengthSquared);
		double ratio = parentWidth / touchLength;
		paperTipPoint.x = paperTipPoint.x * ratio;
		paperTipPoint.y = paperTipPoint.y * ratio;
	}
	
	_foldPoint = CGPointMake(parentWidth - paperTipPoint.x, paperTipPoint.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	_touchStartPoint = [touch locationInView:[self superview]];
	
	CGPoint touchPoint = [touch locationInView:[self superview]];
	[self setEffectiveFoldPointForTouchPoint:touchPoint];
	
	[self redraw];
	
	[touchDelegate foldedCornerTouchStarted:_foldPoint];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:[self superview]];
	[self setEffectiveFoldPointForTouchPoint:touchPoint];
	
	[self redraw];
	
	[touchDelegate foldedCornerTouchMoved:_foldPoint];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	_foldPoint = _foldStartPoint;
	
	[self redraw];
	
	[touchDelegate foldedCornerTouchEnded];
}

- (void)redraw {
	[self recalculateDimensions];
	[super setNeedsDisplay];
}

@end

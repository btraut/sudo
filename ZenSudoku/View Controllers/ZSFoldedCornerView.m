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

#define DEFAULT_WIDTH 45
#define DEFAULT_HEIGHT 49

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
	return [self initWithFrame:CGRectMake(314 - 50, 0, 50, 50)];
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
		
		_shadowBlobImage = [UIImage imageNamed:@"ShadowBlob.png"];
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
		shadowStart.y = H * cosPhi / 2;
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
		shadowStart.y = H * sinPhi / 2;
	}
	
	underShadowDimensions.width = 1.22 * foldDimensions.height;
	underShadowDimensions.height = 1.22 * foldDimensions.width;
	
	double crossDimension = sqrt(0.0484 * (foldDimensions.width * foldDimensions.width + foldDimensions.height * foldDimensions.height));
	double crossAngle = atan(_foldPoint.x / _foldPoint.y);
	
	underShadowFoldedPageOffset.width = crossDimension * sin(crossAngle);
	underShadowFoldedPageOffset.height = crossDimension * cos(crossAngle);
}

- (void)resizeFrame {
	CGFloat frameHeight = underShadowFoldedPageOffset.height + frameDimensions.height;
	_frameHeightClipped = 0;
	
	if (frameHeight > self.superview.frame.size.height) {
		_frameHeightClipped = frameHeight - self.superview.frame.size.height;
		frameHeight = self.superview.frame.size.height;
	}
	
	self.frame = CGRectMake(314 - (underShadowFoldedPageOffset.width + frameDimensions.width), 0, underShadowFoldedPageOffset.width + frameDimensions.width, frameHeight);
}

- (void)drawRect:(CGRect)rect {
	// Initialize the context.
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	// Reset the context.
	CGAffineTransform t0 = CGContextGetCTM(context);
	t0 = CGAffineTransformInvert(t0);
	CGContextConcatCTM(context, t0);
	CGContextScaleCTM(context, graphicsMultipleFactor, graphicsMultipleFactor);
	
	// Position the folded corner image.
	CGAffineTransform cornerTransform = CGAffineTransformIdentity;
	cornerTransform = CGAffineTransformTranslate(cornerTransform, 0, -_frameHeightClipped);
	cornerTransform = CGAffineTransformTranslate(cornerTransform, underShadowFoldedPageOffset.width, underShadowFoldedPageOffset.height);
	cornerTransform = CGAffineTransformTranslate(cornerTransform, cornerTranslation.x, cornerTranslation.y);
	cornerTransform = CGAffineTransformRotate(cornerTransform, theta);
	cornerTransform = CGAffineTransformRotate(cornerTransform, M_PI / 2);
	cornerTransform = CGAffineTransformScale(cornerTransform, 1, -1);
	CGContextConcatCTM(context, cornerTransform);

	
	// Start a separate graphics context for the under shadow.
	CGContextSaveGState(context);
	
	// Transform the shadow blob.
	CGAffineTransform underShadowTransform = CGAffineTransformIdentity;
	underShadowTransform = CGAffineTransformTranslate(underShadowTransform, -0.22 * foldDimensions.width, -0.22 * foldDimensions.height);
	CGContextConcatCTM(context, underShadowTransform);
	
	// Cut the corner off the folded section.
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, 1.22 * foldDimensions.width, 0);
	CGContextAddLineToPoint(context, 1.22 * foldDimensions.width, 0.22 * foldDimensions.height);
	CGContextAddLineToPoint(context, 0.22 * foldDimensions.width, 1.22 * foldDimensions.height);
	CGContextAddLineToPoint(context, 0, 1.22 * foldDimensions.height);
	CGContextAddLineToPoint(context, 0, 0);
	CGContextClosePath(context);
	CGContextClip(context);
	
	underShadowTransform = CGAffineTransformIdentity;
	underShadowTransform = CGAffineTransformScale(underShadowTransform, underShadowDimensions.height, underShadowDimensions.width);
	underShadowTransform = CGAffineTransformScale(underShadowTransform, 1 / _shadowBlobImage.size.height, 1 / _shadowBlobImage.size.width);
	underShadowTransform = CGAffineTransformTranslate(underShadowTransform, 0, _shadowBlobImage.size.height);
	underShadowTransform = CGAffineTransformScale(underShadowTransform, 1, -1);
	CGContextConcatCTM(context, underShadowTransform);
	
	// Draw the shadow blob image.
	CGContextDrawImage(context, CGRectMake(0, 0, _shadowBlobImage.size.width, _shadowBlobImage.size.height), _shadowBlobImageCG);

	// Finish up the graphics context for the under shadow.
	CGContextRestoreGState(context);
	 
	// Draw the drop shadow gradient.
	CGContextDrawLinearGradient(context, _dropShadowGradient, shadowStart, CGPointMake(shadowStart.x * 7 / 4, shadowStart.y * 7 / 4), 0);
	
	// Cut the corner off the folded section.
	CGContextMoveToPoint(context, 0, 0);
	CGContextAddLineToPoint(context, foldDimensions.width, 0);
	CGContextAddLineToPoint(context, 0, foldDimensions.height);
	CGContextAddLineToPoint(context, 0, 0);
	CGContextClosePath(context);
	CGContextClip(context);
	
	// Start another context session.
	CGContextSaveGState(context);
	
	// CGContextDrawImage draws images upsidedown, so use a transform to fix it.
	cornerTransform = CGAffineTransformIdentity;
	cornerTransform = CGAffineTransformTranslate(cornerTransform, 0, _cornerImage.size.height);
	cornerTransform = CGAffineTransformScale(cornerTransform, 1, -1);
	CGContextConcatCTM(context, cornerTransform);
	
	// Draw the folded corner image.
	CGContextDrawImage(context, CGRectMake(0, 0, _cornerImage.size.width, _cornerImage.size.height), _cornerImageCG);
	
	// Restore the previous context.
	CGContextRestoreGState(context);
	
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
	[self resizeFrame];
	[super setNeedsDisplay];
}

@end

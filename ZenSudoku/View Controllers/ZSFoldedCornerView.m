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
	
	CGGradientRef _dropShadowGradient;
	CGGradientRef _innerShadowGradient;
	
	double H, phi, theta;
	CGPoint cornerTranslation;
	CGSize frameDimensions;
	CGSize foldDimensions;
	
	CGPoint shadowStart;
	CGSize underShadowDimensions;
	CGSize underShadowFoldedPageOffset;
	
	NSInteger graphicsMultipleFactor;
}

@end

@implementation ZSFoldedCornerView

@synthesize touchDelegate;

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
		_shadowBlobImage = [UIImage imageNamed:@"ShadowBlob.png"];
		
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
			0.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0, 0.05,
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
	// Start with the math.
	H = sqrt(_foldPoint.x * _foldPoint.x + _foldPoint.y * _foldPoint.y);
	
	if (_foldPoint.x < _foldPoint.y) {
		phi = atan(_foldPoint.x / _foldPoint.y);
		theta = (M_PI / 2) - 2 * phi;
		frameDimensions.width = H / (2 * sin(phi));
		frameDimensions.height = _foldPoint.y;
		cornerTranslation.x = frameDimensions.width - _foldPoint.x;
		cornerTranslation.y = 0;
		foldDimensions.width = frameDimensions.width;
		foldDimensions.height = frameDimensions.width * tan(phi);
		
		shadowStart.x = H * sin(phi) / 2;
		shadowStart.y = H * cos(phi) / 2;
	} else {
		phi = atan(_foldPoint.y / _foldPoint.x);
		theta = - ((M_PI / 2) - 2 * phi);
		frameDimensions.width = _foldPoint.x;
		frameDimensions.height = H / (2 * sin(phi));
		cornerTranslation.x = 0;
		cornerTranslation.y = frameDimensions.height - _foldPoint.y;
		foldDimensions.width = frameDimensions.height * tan(phi);
		foldDimensions.height = frameDimensions.height;
		
		shadowStart.x = H * cos(phi) / 2;
		shadowStart.y = H * sin(phi) / 2;
	}
	
	underShadowDimensions.width = 1.22 * foldDimensions.height;
	underShadowDimensions.height = 1.22 * foldDimensions.width;
	
	double crossDimension = sqrt(0.0484 * (foldDimensions.width * foldDimensions.width + foldDimensions.height * foldDimensions.height));
	double crossAngle = atan(_foldPoint.x / _foldPoint.y);
	
	underShadowFoldedPageOffset.width = crossDimension * sin(crossAngle);
	underShadowFoldedPageOffset.height = crossDimension * cos(crossAngle);
}

- (void)resizeFrame {
	// Resize the frame.
	self.frame = CGRectMake(314 - (underShadowFoldedPageOffset.width + frameDimensions.width), 0, underShadowFoldedPageOffset.width + frameDimensions.width, underShadowFoldedPageOffset.height + frameDimensions.height);
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
	CGContextConcatCTM(context, underShadowTransform);

	
	// Draw the shadow blob image.
	[_shadowBlobImage drawAtPoint:CGPointMake(0, 0)];
	
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
	
	// Draw the folded corner image.
	[_cornerImage drawAtPoint:CGPointMake(0, 0)];
	
	// Draw the inner shadow gradient.
	CGContextDrawLinearGradient(context, _innerShadowGradient, shadowStart, CGPointMake(shadowStart.x * 1 / 4, shadowStart.y * 1 / 4), kCGGradientDrawsBeforeStartLocation);
	
	// Clean up.
	CGContextRestoreGState(context);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	_touchStartPoint = [touch locationInView:[self superview]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:[self superview]];
	
	_foldPoint = CGPointMake(_foldStartPoint.x - (touchPoint.x - _touchStartPoint.x), _foldStartPoint.y + (touchPoint.y - _touchStartPoint.y));
	
	[self redraw];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	_foldPoint = _foldStartPoint;
	
	[self redraw];
}

- (void)redraw {
	[self recalculateDimensions];
	[self resizeFrame];
	[super setNeedsDisplay];
}

@end

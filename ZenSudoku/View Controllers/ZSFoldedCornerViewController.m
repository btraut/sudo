//
//  ZSFoldedCornerViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSFoldedCornerViewController.h"

#import "ZSGLSprite.h"
#import "ZSGLShape.h"

#define DEFAULT_WIDTH 48
#define DEFAULT_HEIGHT 51

typedef enum {
	ZSFoldedCornerViewControllerAnimationStateStopped,
	ZSFoldedCornerViewControllerAnimationStateUserAnimating,
	ZSFoldedCornerViewControllerAnimationStateSendFoldBackToCornerStage1,
	ZSFoldedCornerViewControllerAnimationStatePageTurnStage1,
	ZSFoldedCornerViewControllerAnimationStateStartFoldStage1,
	ZSFoldedCornerViewControllerAnimationStateCornerTugStage1,
	ZSFoldedCornerViewControllerAnimationStateCornerTugStage2,
	ZSFoldedCornerViewControllerAnimationStateCornerTugStage3,
	ZSFoldedCornerViewControllerAnimationStateCornerTugStage4
} ZSFoldedCornerViewControllerAnimationState;

@interface ZSFoldedCornerViewController () {
	CGPoint _touchStartPoint;
	CGPoint _foldStartPoint;
	CGPoint _foldPoint;
	
	GLKBaseEffect *_effect;
	
	ZSGLSprite *_cornerSprite;
	ZSGLSprite *_shadowBlobSprite;
	
	ZSGLShape *_foldGradient;
	ZSGLShape *_cornerGradient;
	
	ZSFoldedCornerViewControllerAnimationState _animationState;
	
	ZSPointAnimation *_animationHelper;
}

@property (strong, nonatomic) EAGLContext *context;

@end

@implementation ZSFoldedCornerViewController

@synthesize touchDelegate = _touchDelegate;
@synthesize context = _context;

- (id)init {
	self = [super init];
	
	if (self) {
		// Init the fold point defaults.
		_foldStartPoint = CGPointMake(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		_foldPoint = CGPointMake(DEFAULT_WIDTH, DEFAULT_HEIGHT);
		
		// Calculate dimensions for the first time.
		[self recalculateDimensions];
		
		// Set animation state;
		_animationState = ZSFoldedCornerViewControllerAnimationStateStopped;
		
		_animationHelper = [[ZSPointAnimation alloc] init];
		_animationHelper.delegate = self;
	}
	
	return self;
}

- (void)loadView {
	// Create the GLKView.
	ZSFoldedCornerGLView *view = [[ZSFoldedCornerGLView alloc] initWithFrame:CGRectMake(0, 0, 314, 460)];
	view.delegate = self;
	view.hitTestDelegate = self;
	self.view = view;
	
	// Set other view options.
	view.opaque = NO;
	view.alpha = 1.0f;
	view.hidden = NO;
	view.backgroundColor = [UIColor clearColor];
	view.enableSetNeedsDisplay = NO;
	view.drawableMultisample = GLKViewDrawableMultisample4X;
}

- (void)viewDidLoad {
	// Super!
    [super viewDidLoad];
	
	// Set up the context for the view.
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
	
    ZSFoldedCornerGLView *view = (ZSFoldedCornerGLView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
		
	// Load the effect.
	_effect = [[GLKBaseEffect alloc] init];
	GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, self.view.frame.size.width, 0, self.view.frame.size.height, -1024, 1024);
	_effect.transform.projectionMatrix = projectionMatrix;
	
	// Load the images.
	if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && [UIScreen mainScreen].scale == 2.0) {
		_cornerSprite = [[ZSGLSprite alloc] initWithFile:@"BackwardsPage@2x.png" effect:_effect];
		_shadowBlobSprite = [[ZSGLSprite alloc] initWithFile:@"ShadowBlobTest@2x.png" effect:_effect];
	} else {
		_cornerSprite = [[ZSGLSprite alloc] initWithFile:@"BackwardsPage.png" effect:_effect];
		_shadowBlobSprite = [[ZSGLSprite alloc] initWithFile:@"ShadowBlob.png" effect:_effect];
	}
	
	// Load the gradients.
	_foldGradient = [[ZSGLShape alloc] initWithEffect:_effect];
	_cornerGradient = [[ZSGLShape alloc] initWithEffect:_effect];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[(ZSFoldedCornerGLView *)self.view display];
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
		
	double crossDimension = sqrt(0.0484 * (foldDimensions.width * foldDimensions.width + foldDimensions.height * foldDimensions.height));
	double crossAngle = atan(_foldPoint.x / _foldPoint.y);
	
	underShadowFoldedPageOffset.width = crossDimension * sin(crossAngle);
	underShadowFoldedPageOffset.height = crossDimension * cos(crossAngle);
	
	underShadowDimensions.width = 1.22 * foldDimensions.width;
	underShadowDimensions.height = 1.22 * foldDimensions.height;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
	glClearColor(0, 0, 0, 0);
	glClear(GL_COLOR_BUFFER_BIT);    

	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	
    GLKMatrix4 baseMatrix = GLKMatrix4Identity;
	baseMatrix = GLKMatrix4Translate(baseMatrix, cornerTranslation.x, cornerTranslation.y, 0);
	baseMatrix = GLKMatrix4Translate(baseMatrix, -frameDimensions.width, -frameDimensions.height, 0);
	baseMatrix = GLKMatrix4Translate(baseMatrix, self.view.frame.size.width, self.view.frame.size.height, 0);
	baseMatrix = GLKMatrix4Rotate(baseMatrix, theta, 0, 0, 1);
	baseMatrix = GLKMatrix4Rotate(baseMatrix, M_PI / 2, 0, 0, 1);
	
	_foldGradient.transform = baseMatrix;
	_cornerGradient.transform = GLKMatrix4Identity;
	
	GLKMatrix4 foldedCornerMatrix = baseMatrix;
	foldedCornerMatrix = GLKMatrix4Translate(foldedCornerMatrix, 0, -_cornerSprite.contentSizeNormalized.height, 0);
	_cornerSprite.transform = foldedCornerMatrix;
		
    GLKMatrix4 shadowBlobMatrix = baseMatrix;
	shadowBlobMatrix = GLKMatrix4Translate(shadowBlobMatrix, 0, -_shadowBlobSprite.contentSizeNormalized.height, 0);
	shadowBlobMatrix = GLKMatrix4Translate(shadowBlobMatrix, foldDimensions.width - underShadowDimensions.width, underShadowDimensions.height - foldDimensions.height, 0);
	_shadowBlobSprite.transform = shadowBlobMatrix;
	
	// Draw the shadow blob.
	TexturedVertex shadowBlobTriangle[6];
	
	shadowBlobTriangle[0].geometryVertex = CGPointMake(0, _shadowBlobSprite.contentSizeNormalized.height);
	shadowBlobTriangle[1].geometryVertex = CGPointMake(underShadowDimensions.width, _shadowBlobSprite.contentSizeNormalized.height);
	shadowBlobTriangle[2].geometryVertex = CGPointMake(underShadowDimensions.width, _shadowBlobSprite.contentSizeNormalized.height - (underShadowDimensions.height - foldDimensions.height));
	shadowBlobTriangle[3].geometryVertex = CGPointMake(0, _shadowBlobSprite.contentSizeNormalized.height);
	shadowBlobTriangle[4].geometryVertex = CGPointMake(underShadowDimensions.width - foldDimensions.width, _shadowBlobSprite.contentSizeNormalized.height - underShadowDimensions.height);
	shadowBlobTriangle[5].geometryVertex = CGPointMake(0, _shadowBlobSprite.contentSizeNormalized.height - underShadowDimensions.height);
	
	shadowBlobTriangle[0].textureVertex = CGPointMake(0, 1);
	shadowBlobTriangle[1].textureVertex = CGPointMake(1, 1);
	shadowBlobTriangle[2].textureVertex = CGPointMake(1, 1 - ((underShadowDimensions.height - foldDimensions.height) / underShadowDimensions.height));
	shadowBlobTriangle[3].textureVertex = CGPointMake(0, 1);
	shadowBlobTriangle[4].textureVertex = CGPointMake((underShadowDimensions.width - foldDimensions.width) / underShadowDimensions.width, 0);
	shadowBlobTriangle[5].textureVertex = CGPointMake(0, 0);
	
	[_shadowBlobSprite renderTriangleStrip:shadowBlobTriangle ofSize:6];
	
	// Draw the folded corner.
	TexturedVertex foldedCornerTriangle[3];
	
	foldedCornerTriangle[0].geometryVertex = CGPointMake(0, _cornerSprite.contentSizeNormalized.height);
	foldedCornerTriangle[1].geometryVertex = CGPointMake(foldDimensions.width, _cornerSprite.contentSizeNormalized.height);
	foldedCornerTriangle[2].geometryVertex = CGPointMake(0, _cornerSprite.contentSizeNormalized.height - foldDimensions.height);
	
	foldedCornerTriangle[0].textureVertex = CGPointMake(0, 1);
	foldedCornerTriangle[1].textureVertex = CGPointMake((foldDimensions.width / _cornerSprite.contentSizeNormalized.width), 1);
	foldedCornerTriangle[2].textureVertex = CGPointMake(0, 1 - (foldDimensions.height / _cornerSprite.contentSizeNormalized.height));
	
	[_cornerSprite renderTriangleStrip:foldedCornerTriangle ofSize:3];
	
	// Draw the fold gradient.
	ColoredVertex foldGradientVertices[3];
	
	foldGradientVertices[0].position = CGPointMake(0, 0);
	foldGradientVertices[1].position = CGPointMake(foldDimensions.width, 0);
	foldGradientVertices[2].position = CGPointMake(0, -foldDimensions.height);
	
	foldGradientVertices[0].color = GLKVector4Make(1, 1, 1, 1.0f);
	foldGradientVertices[1].color = GLKVector4Make(0.95f, 0.95f, 0.95f, 1.0f);
	foldGradientVertices[2].color = GLKVector4Make(0.95f, 0.95f, 0.95f, 1.0f);
	
	_foldGradient.overlay = YES;
	[_foldGradient renderVertices:foldGradientVertices ofSize:3];
	
	// Draw the corner gradient.
	ColoredVertex cornerGradientVertices[3];
	
	cornerGradientVertices[0].position = CGPointMake(self.view.frame.size.width, self.view.frame.size.height);
	cornerGradientVertices[1].position = CGPointMake(self.view.frame.size.width - foldDimensions.width, self.view.frame.size.height);
	cornerGradientVertices[2].position = CGPointMake(self.view.frame.size.width, self.view.frame.size.height - foldDimensions.height);
	
	cornerGradientVertices[0].color = GLKVector4Make(0, 0, 0, 0.0f);
	cornerGradientVertices[1].color = GLKVector4Make(0, 0, 0, 0.35f);
	cornerGradientVertices[2].color = GLKVector4Make(0, 0, 0, 0.35f);
	
	[_cornerGradient renderVertices:cornerGradientVertices ofSize:3];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	if (_animationState != ZSFoldedCornerViewControllerAnimationStateStopped) {
		return NO;
	}
	
	if (point.x < self.view.frame.size.width - _foldStartPoint.x || point.y > _foldStartPoint.y) {
		return NO;
	}
	
	return YES;
}

- (void)setEffectiveFoldPointForTouchPoint:(CGPoint)touchPoint {
	double width = self.view.frame.size.width;
	
	CGPoint effectiveTouchPoint = touchPoint;
	if (effectiveTouchPoint.y < 0) {
		effectiveTouchPoint.y = 0;
	}
	
	CGPoint paperTipPoint = CGPointMake((width - _foldStartPoint.x) + (effectiveTouchPoint.x - _touchStartPoint.x), _foldStartPoint.y + (effectiveTouchPoint.y - _touchStartPoint.y));
	
	double touchLengthSquared = (paperTipPoint.x * paperTipPoint.x) + (paperTipPoint.y * paperTipPoint.y);
	double maxLengthSquared = width * width;
	
	// If the paper isn't folded too much by the current touch point, calculate an effective fold point that would lie within the fold limits.
	if (touchLengthSquared > maxLengthSquared) {
		double touchLength = sqrt(touchLengthSquared);
		double ratio = width / touchLength;
		paperTipPoint.x = paperTipPoint.x * ratio;
		paperTipPoint.y = paperTipPoint.y * ratio;
	}
	
	_foldPoint = CGPointMake(width - paperTipPoint.x, paperTipPoint.y);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	_animationState = ZSFoldedCornerViewControllerAnimationStateUserAnimating;
	
	UITouch *touch = [touches anyObject];
	_touchStartPoint = [touch locationInView:self.view];
	
	CGPoint touchPoint = [touch locationInView:self.view];
	[self setEffectiveFoldPointForTouchPoint:touchPoint];
	
	[self redraw];
	
	[_touchDelegate foldedCornerTouchStartedWithFoldPoint:_foldPoint foldDimensions:foldDimensions];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
	[self setEffectiveFoldPointForTouchPoint:touchPoint];
	
	[self redraw];
	
	[_touchDelegate foldedCornerTouchMovedWithFoldPoint:_foldPoint foldDimensions:foldDimensions];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	_animationState = ZSFoldedCornerViewControllerAnimationStateStopped;
	
	[_touchDelegate foldedCornerTouchEndedWithFoldPoint:_foldPoint foldDimensions:foldDimensions];
}

- (void)redraw {
	[self recalculateDimensions];
	[(ZSFoldedCornerGLView *)self.view display];
}

- (void)pushUpdate {
	[self redraw];
	[_touchDelegate foldedCornerTouchMovedWithFoldPoint:_foldPoint foldDimensions:foldDimensions];
}

- (void)animationAdvanced:(CGPoint)point progress:(float)progress {
	BOOL useAnimationFoldPoint = YES;
	
	if (_animationState == ZSFoldedCornerViewControllerAnimationStatePageTurnStage1) {
		[self _pageTurnAnimationAdvancedWithProgress:progress];
	} else if (_animationState == ZSFoldedCornerViewControllerAnimationStateStartFoldStage1) {
		[self _startFoldAnimationAdvancedWithProgress:progress];
		useAnimationFoldPoint = NO;
	}
	
	if (useAnimationFoldPoint) {
		_foldPoint = point;
		[self pushUpdate];
	}
}

- (void)animationDidFinish {
	switch (_animationState) {
		case ZSFoldedCornerViewControllerAnimationStateUserAnimating:
			_animationState = ZSFoldedCornerViewControllerAnimationStateStopped;
			break;
			
		case ZSFoldedCornerViewControllerAnimationStateSendFoldBackToCornerStage1:
			_animationState = ZSFoldedCornerViewControllerAnimationStateStopped;
			[_touchDelegate foldedCornerRestoredToStartPoint];
			break;
			
		case ZSFoldedCornerViewControllerAnimationStatePageTurnStage1:
			_animationState = ZSFoldedCornerViewControllerAnimationStateStopped;
			[_touchDelegate pageWasTurned];
			break;
			
		case ZSFoldedCornerViewControllerAnimationStateStartFoldStage1:
			_animationState = ZSFoldedCornerViewControllerAnimationStateStopped;
			[_touchDelegate foldedCornerRestoredToStartPoint];
			break;
			
		case ZSFoldedCornerViewControllerAnimationStateCornerTugStage1:
			[self _animateCornerTugStage2];
			break;
			
		case ZSFoldedCornerViewControllerAnimationStateCornerTugStage2:
			[self _animateCornerTugStage3];
			break;
			
		case ZSFoldedCornerViewControllerAnimationStateCornerTugStage3:
			[self _animateCornerTugStage4];
			break;
			
		case ZSFoldedCornerViewControllerAnimationStateCornerTugStage4:
			_animationState = ZSFoldedCornerViewControllerAnimationStateStopped;
			[_touchDelegate foldedCornerRestoredToStartPoint];
			break;
						
		case ZSFoldedCornerViewControllerAnimationStateStopped:
		default:
			break;
	}
}

- (void)animateSendFoldBackToCorner {
	// Only start the animation if we're not currently running an animation.
	if (_animationState != ZSFoldedCornerViewControllerAnimationStateStopped) {
		return;
	}
	
	_animationState = ZSFoldedCornerViewControllerAnimationStateSendFoldBackToCornerStage1;
	
	_animationHelper.duration = 0.4f;
	_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseOut;
	
	_animationHelper.startPoint = _foldPoint;
	_animationHelper.endPoint = _foldStartPoint;
	
	[_animationHelper start];
}

- (void)animatePageTurn {
	// Only start the animation if we're not currently running an animation.
	if (_animationState != ZSFoldedCornerViewControllerAnimationStateStopped) {
		return;
	}
	
	_animationState = ZSFoldedCornerViewControllerAnimationStatePageTurnStage1;
	
	_animationHelper.duration = 0.4f;
	_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseOut;
	
	_animationHelper.startPoint = _foldPoint;
	_animationHelper.endPoint = CGPointMake(628, 0.1f);
	
	[_animationHelper start];
}

- (void)_pageTurnAnimationAdvancedWithProgress:(float)progress {
	if (progress >= 0.8f) {
		self.view.alpha = 5 * (1 - progress);
	}
}

- (void)animateStartFold {
	// Only start the animation if we're not currently running an animation.
	if (_animationState != ZSFoldedCornerViewControllerAnimationStateStopped) {
		return;
	}
	
	_animationState = ZSFoldedCornerViewControllerAnimationStateStartFoldStage1;
	
	_animationHelper.duration = 0.4f;
	_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseOut;
	
	_animationHelper.startPoint = CGPointMake(0.01f, 0.01f);
	_animationHelper.endPoint = _foldStartPoint;
	
	[_animationHelper start];
}

- (void)_startFoldAnimationAdvancedWithProgress:(float)progress {
	if (self.view.hidden == YES) {
		self.view.hidden = NO;
	}
	
	if (progress == 1) {
		_foldPoint = _foldStartPoint;
	} else {
		CGFloat newX = _foldStartPoint.x - cosf(progress * M_PI / 2) * _foldStartPoint.x;
		CGFloat newY = sinf(progress * M_PI / 2) * _foldStartPoint.y;
		
		_foldPoint = CGPointMake(newX, newY);
	}
	
	[self pushUpdate];
}

- (void)animateCornerTug {
	// Only start the animation if we're not currently running an animation.
	if (_animationState != ZSFoldedCornerViewControllerAnimationStateStopped) {
		return;
	}
	
	[self _animateCornerTugStage1];
}

- (void)_animateCornerTugStage1 {
	_animationState = ZSFoldedCornerViewControllerAnimationStateCornerTugStage1;
	
	_animationHelper.duration = 0.12f;
	_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseInOut;
	
	_animationHelper.startPoint = _foldPoint;
	_animationHelper.endPoint = CGPointMake(_foldStartPoint.x + 7, _foldStartPoint.x + 11);
	
	[_animationHelper start];
}

- (void)_animateCornerTugStage2 {
	_animationState = ZSFoldedCornerViewControllerAnimationStateCornerTugStage2;
	
	_animationHelper.duration = 0.12f;
	_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseInOut;
	
	_animationHelper.startPoint = _foldPoint;
	_animationHelper.endPoint = _foldStartPoint;
	
	[_animationHelper start];
}

- (void)_animateCornerTugStage3 {
	_animationState = ZSFoldedCornerViewControllerAnimationStateCornerTugStage3;
	
	_animationHelper.duration = 0.14f;
	_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseInOut;
	
	_animationHelper.startPoint = _foldPoint;
	_animationHelper.endPoint = CGPointMake(_foldStartPoint.x + 7, _foldStartPoint.x + 11);
	
	[_animationHelper start];
}

- (void)_animateCornerTugStage4 {
	_animationState = ZSFoldedCornerViewControllerAnimationStateCornerTugStage4;
	
	_animationHelper.duration = 0.14f;
	_animationHelper.timingFunction = ZSAnimationTimingFunctionEaseInOut;
	
	_animationHelper.startPoint = _foldPoint;
	_animationHelper.endPoint = _foldStartPoint;
	
	[_animationHelper start];
}

@end

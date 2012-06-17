//
//  ZSFoldedCornerViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "ZSFoldedCornerGLView.h"

@protocol ZSFoldedCornerGLViewControllerTouchDelegate <NSObject>

- (void)foldedCornerTouchStartedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions;
- (void)foldedCornerTouchMovedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions;
- (void)foldedCornerTouchEndedWithFoldPoint:(CGPoint)foldPoint foldDimensions:(CGSize)foldDimensions;

@end

@interface ZSFoldedCornerViewController : UIViewController <GLKViewDelegate, ZSFoldedCornerGLHitTestDelegate> {
	double H, phi, theta;
	CGPoint cornerTranslation;
	CGSize frameDimensions;
	CGSize foldDimensions;
	
	CGPoint shadowStart;
	CGSize underShadowDimensions;
	CGSize underShadowFoldedPageOffset;
}

@property (nonatomic, strong) NSObject<ZSFoldedCornerGLViewControllerTouchDelegate> *touchDelegate;

- (void)pushUpdate;

@end

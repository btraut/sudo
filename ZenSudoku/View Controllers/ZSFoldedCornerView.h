//
//  ZSFoldedCornerView.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZSFoldedCornerTouchDelegate <NSObject>

- (void)foldedCornerTouchStarted:(CGPoint)startPoint;
- (void)foldedCornerTouchMoved:(CGPoint)touchPoint;
- (void)foldedCornerTouchEnded;

@end

@interface ZSFoldedCornerView : UIView {
	NSObject<ZSFoldedCornerTouchDelegate> *touchDelegate;
	
	double H, phi, theta;
	CGPoint cornerTranslation;
	CGSize frameDimensions;
	CGSize foldDimensions;
	
	CGPoint shadowStart;
	CGSize underShadowDimensions;
	CGSize underShadowFoldedPageOffset;
}

@property (nonatomic, assign) double H;
@property (nonatomic, assign) double phi;
@property (nonatomic, assign) double theta;

@property (nonatomic, assign) CGPoint cornerTranslation;
@property (nonatomic, assign) CGSize frameDimensions;
@property (nonatomic, assign) CGSize foldDimensions;

@property (nonatomic, assign) CGPoint shadowStart;
@property (nonatomic, assign) CGSize underShadowDimensions;
@property (nonatomic, assign) CGSize underShadowFoldedPageOffset;

@property (nonatomic, strong) NSObject<ZSFoldedCornerTouchDelegate> *touchDelegate;

- (void)redraw;

@end

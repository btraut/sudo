//
//  ZSFoldedCornerView.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/4/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@protocol ZSFoldedCornerViewHitTestDelegate <NSObject>

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end

@interface ZSFoldedCornerView : GLKView

@property (weak) id<ZSFoldedCornerViewHitTestDelegate> hitTestDelegate;

@end

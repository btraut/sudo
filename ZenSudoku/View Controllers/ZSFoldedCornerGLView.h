//
//  ZSFoldedCornerGLView.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@protocol ZSFoldedCornerGLHitTestDelegate <NSObject>

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end

@interface ZSFoldedCornerGLView : GLKView {
	NSObject<ZSFoldedCornerGLHitTestDelegate> *hitTestDelegate;
}

@property (nonatomic, strong) NSObject<ZSFoldedCornerGLHitTestDelegate> *hitTestDelegate;

@end

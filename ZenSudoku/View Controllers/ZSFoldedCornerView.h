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
}

@property (nonatomic, strong) NSObject<ZSFoldedCornerTouchDelegate> *touchDelegate;

- (void)redraw;

@end

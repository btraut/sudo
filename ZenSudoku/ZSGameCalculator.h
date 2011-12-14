//
//  ZSGameCalculator.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSGameBoard;

@interface ZSGameCalculator : UITextView {
	@protected
	
	ZSGameBoard *_gameBoard;
}

- (void)setSize:(NSInteger)newSize;

- (BOOL)isGuessValid:(NSInteger)guess atX:(NSInteger)x y:(NSInteger)y;
- (BOOL)isGuessValid:(NSInteger)guess rowAtX:(NSInteger)x;
- (BOOL)isGuessValid:(NSInteger)guess colAtY:(NSInteger)y;
- (BOOL)isGuessValid:(NSInteger)guess groupAtX:(NSInteger)x y:(NSInteger)y;

@end

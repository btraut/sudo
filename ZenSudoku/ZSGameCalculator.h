//
//  ZSGameCalculator.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSGameCalculator : UITextView {
	@protected
	
	NSInteger _size;
	
	NSInteger **_groupMap;
	NSInteger **_tiles;
	
	BOOL _allocated;
}

- (void)setSize:(NSInteger)newSize;
- (void)allocComponents;
- (void)deallocComponents;

- (void)print9x9Puzzle:(NSInteger **)tiles;

- (BOOL)isGuessValid:(NSInteger)guess atX:(NSInteger)x y:(NSInteger)y;
- (BOOL)isGuessValid:(NSInteger)guess rowAtX:(NSInteger)x;
- (BOOL)isGuessValid:(NSInteger)guess colAtY:(NSInteger)y;
- (BOOL)isGuessValid:(NSInteger)guess groupAtX:(NSInteger)x y:(NSInteger)y;

@end

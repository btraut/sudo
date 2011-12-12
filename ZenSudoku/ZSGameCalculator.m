//
//  ZSGameCalculator.m
//  ZenSudoku
//
//  Created by Brent Traut on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameCalculator.h"
#import "ZSGameController.h"

@implementation ZSGameCalculator

#pragma mark - Memory Handling

- (void)setSize:(NSInteger)newSize {
	if (_size != newSize) {
		// Free old memory.
		if (_allocated) {
			[self deallocComponents];
		}
		
		// Save the board size.
		_size = newSize;
		
		// Initialize new memory.
		[self allocComponents];
	}
}

- (void)allocComponents {
	_tiles = [ZSGameController alloc2DIntGridWithSize:_size];
	_groupMap = [ZSGameController alloc2DIntGridWithSize:_size];
	_allocated = YES;
}

- (void)deallocComponents {
	[ZSGameController free2DIntGrid:_tiles withSize:_size];
	[ZSGameController free2DIntGrid:_groupMap withSize:_size];
	_allocated = NO;
}

- (void)dealloc {
	[self deallocComponents];
	_size = 0;
}

#pragma mark - Querying

- (BOOL)isGuessValid:(NSInteger)guess atX:(NSInteger)x y:(NSInteger)y {
	// Cache the target tile's group.
	NSInteger targetGroup = _groupMap[x][y];
	
	// Loop over the entire puzzle to find tiles in the same group.
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			// Find all the tiles in the same row, col, or group as the target tile.
			if (row == x || col == y || _groupMap[row][col] == targetGroup) {
				// If the current tile matches the target's guess, the guess is invalid.
				if (_tiles[row][col] == guess) {
					return NO;
				}
			}
		}
	}
	
	// If we made it through the loop, the guess is valid.
	return YES;
}

- (BOOL)isGuessValid:(int)guess rowAtX:(int)x {
	for (NSInteger col = 0; col < 9; col++) {
		if (_tiles[x][col] == guess) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isGuessValid:(int)guess colAtY:(int)y {
	for (NSInteger row = 0; row < 9; row++) {
		if (_tiles[row][y] == guess) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isGuessValid:(int)guess groupAtX:(int)x y:(int)y {
	NSInteger targetGroup = _groupMap[x][y];
	
	// Loop over the entire puzzle to find tiles in the same group.
	for (NSInteger row = 0; row < _size; ++row) {
		for (NSInteger col = 0; col < _size; ++col) {
			// Find all the tiles in the same group (excluding the target tile itself).
			if (_groupMap[row][col] == targetGroup && !(row == x && col == y)) {
				if (_tiles[row][col] == guess) {
					return NO;
				}
			}
		}
	}
	
	return YES;
}

#pragma mark - Presentation

- (void)print9x9Puzzle:(NSInteger **)tiles {
	NSLog(@" ");
	for (NSInteger row = 0; row < 9; ++row) {
		NSLog(@" %i %i %i | %i %i %i | %i %i %i", tiles[row][0], tiles[row][1], tiles[row][2], tiles[row][3], tiles[row][4], tiles[row][5], tiles[row][6], tiles[row][7], tiles[row][8]);
		
		if (row == 2 || row == 5) {
			NSLog(@"-------+-------+-------");
		}
	}
	NSLog(@" ");
}

@end

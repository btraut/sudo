//
//  ZSGameCalculator.m
//  ZenSudoku
//
//  Created by Brent Traut on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameCalculator.h"
#import "ZSGameController.h"
#import "ZSGameBoard.h"
#import "ZSGameTile.h"

@implementation ZSGameCalculator

#pragma mark - Memory Handling

- (void)setSize:(NSInteger)newSize {
	if (newSize != _gameBoard.size) {
		_gameBoard = [[ZSGameBoard alloc] initWithSize:newSize];
	}
}

#pragma mark - Querying

- (BOOL)isGuessValid:(NSInteger)guess atX:(NSInteger)x y:(NSInteger)y {
	// Cache the target tile's group.
	NSInteger targetGroup = [_gameBoard getTileAtRow:x col:y].groupId;
	
	// Loop over the entire puzzle to find tiles in the same group.
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			ZSGameTile *iteratedTile = [_gameBoard getTileAtRow:row col:col];
			
			// Find all the tiles in the same row, col, or group as the target tile.
			if (row == x || col == y || iteratedTile.groupId == targetGroup) {
				// If the current tile matches the target's guess, the guess is invalid.
				if (iteratedTile.guess == guess) {
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
		if ([_gameBoard getTileAtRow:x col:col].guess == guess) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isGuessValid:(int)guess colAtY:(int)y {
	for (NSInteger row = 0; row < 9; row++) {
		if ([_gameBoard getTileAtRow:row col:y].guess == guess) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isGuessValid:(int)guess groupAtX:(int)x y:(int)y {
	// Cache the target tile's group.
	NSInteger targetGroup = [_gameBoard getTileAtRow:x col:y].groupId;
		
	// Loop over the entire puzzle to find tiles in the same group.
	for (NSInteger row = 0; row < _gameBoard.size; ++row) {
		for (NSInteger col = 0; col < _gameBoard.size; ++col) {
			ZSGameTile *iteratedTile = [_gameBoard getTileAtRow:row col:col];
			
			// Find all the tiles in the same group (excluding the target tile itself).
			if (iteratedTile.groupId == targetGroup && !(row == x && col == y)) {
				if (iteratedTile.guess == guess) {
					return NO;
				}
			}
		}
	}
	
	return YES;
}

@end

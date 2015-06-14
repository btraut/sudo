//
//  ZSHintGeneratorFixIncorrectGuesses.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorFixIncorrectGuesses.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorFixIncorrectGuesses () {
	BOOL _initialized;
	
	ZSHintGeneratorTileInstruction *_incorrectTiles;
	
	NSInteger _totalIncorrectTiles;
}

@end

@implementation ZSHintGeneratorFixIncorrectGuesses

- (id)init {
	self = [super init];
	
	if (self) {
		[self _allocTilesAndInstructions];
	}
	
	return self;
}

- (void)resetTilesAndInstructions {
	_totalIncorrectTiles = 0;
}

- (void)_allocTilesAndInstructions {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
	
	_incorrectTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 81);
	
	[self resetTilesAndInstructions];
}

- (void)_freeTilesAndInstructions {
	free(_incorrectTiles);
}

- (void)dealloc {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
}

- (void)addIncorrectGuess:(ZSHintGeneratorTileInstruction)tile {
	_incorrectTiles[_totalIncorrectTiles++] = tile;
}

- (NSArray *)generateHint {
	NSMutableArray *hintCards = [NSMutableArray array];
	
	// Step 1
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	
	NSString *isAreString = _totalIncorrectTiles == 1 ? @"is" : @"are";
	NSString *pluralGuessesString = _totalIncorrectTiles == 1 ? @"guess" : @"guesses";
	NSString *totalIncorrectTiles = _totalIncorrectTiles == 1 ? @"an" : [NSString stringWithFormat:@"%li", _totalIncorrectTiles];
	
	card1.text = [NSString stringWithFormat:@"There %@ %@ incorrect %@ on the board.", isAreString, totalIncorrectTiles, pluralGuessesString];
	
	[hintCards addObject:card1];
	
	// Step 2
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	
	NSString *itThemString = _totalIncorrectTiles == 1 ? @"it" : @"them";
	
	card2.text = [NSString stringWithFormat:@"The highlighted %@ %@ incorrect. Continue to clear %@.", pluralGuessesString, isAreString, itThemString];
	
	for (NSInteger i = 0; i < _totalIncorrectTiles; ++i) {
		[card2 addInstructionHighlightTileAtRow:_incorrectTiles[i].row col:_incorrectTiles[i].col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card2];
	
	// Step 3
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	
	NSString *hasHaveString = _totalIncorrectTiles == 1 ? @"has" : @"have";
	
	card3.text = [NSString stringWithFormat:@"The incorrect %@ %@ been cleared. Good luck!", pluralGuessesString, hasHaveString];
	
	for (NSInteger i = 0; i < _totalIncorrectTiles; ++i) {
		[card3 addInstructionRemoveGuessForTileAtRow:_incorrectTiles[i].row col:_incorrectTiles[i].col];
	}
	
	[hintCards addObject:card3];
	
	return hintCards;
}

@end

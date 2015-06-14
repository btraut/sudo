//
//  ZSHintGeneratorEliminatePencilsXWing.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorEliminatePencilsXWing.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorEliminatePencilsXWing () {
	BOOL _initialized;
	
	ZSHintGeneratorTileInstruction *_XWingTiles;
	ZSHintGeneratorTileInstruction *_pencilsToEliminate;
	
	NSInteger _totalXWingTiles;
	NSInteger _totalPencilsToEliminate;
}

- (void)_allocTilesAndInstructions;
- (void)_freeTilesAndInstructions;

@end

@implementation ZSHintGeneratorEliminatePencilsXWing

@synthesize scope, targetPencil, size;

- (id)init {
	self = [super init];
	
	if (self) {
		[self _allocTilesAndInstructions];
	}
	
	return self;
}

- (void)resetTilesAndInstructions {
	_totalXWingTiles = 0;
	_totalPencilsToEliminate = 0;
}

- (void)_allocTilesAndInstructions {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
	
	_XWingTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 16);
	_pencilsToEliminate = malloc(sizeof(ZSHintGeneratorTileInstruction) * 81);
	
	[self resetTilesAndInstructions];
}

- (void)_freeTilesAndInstructions {
	free(_pencilsToEliminate);
	free(_XWingTiles);
}

- (void)dealloc {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
}

- (void)addXWingTile:(ZSHintGeneratorTileInstruction)tile {
	_XWingTiles[_totalXWingTiles++] = tile;
}

- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile {
	_pencilsToEliminate[_totalPencilsToEliminate++] = tile;
}

- (NSArray *)generateHint {
	NSString *aAnTechniqueName = (self.size == 2 ? @"an" : @"an");
	NSString *techniqueName = (self.size == 2 ? @"X-Wing" : (self.size == 3 ? @"Swordfish" : @"Jellyfish"));
	NSString *scopeName = (scope == ZSHintGeneratorTileScopeRow ? @"row" : @"column");
	NSString *oppositeScopeName = (scope == ZSHintGeneratorTileScopeRow ? @"column" : @"row");
	
	NSMutableArray *hintCards = [NSMutableArray array];
	
	// Step 1: Highlight tiles.
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	
	card1.text = @"Examine the highlighted tiles. What is special about them?";
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_XWingTiles[i];
		[card1 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card1];
	
	// Step 2: Tiles form an X-Wing.
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	
	NSString *collectionOfRowsColsString = (self.size == 2 ? @"both" : (self.size == 3 ? @"all three" : @"all four"));
	NSString *numberOfSpotsString = (self.size == 2 ? @"two" : (self.size == 3 ? @"two or three" : @"two, three, or four"));
	card2.text = [NSString stringWithFormat:@"The possibility %li exists in the same spots in %@ %@s, and only in those %@ spots. This forms %@ %@ for %li.", self.targetPencil, collectionOfRowsColsString, scopeName, numberOfSpotsString, aAnTechniqueName, techniqueName, self.targetPencil];
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card2 addInstructionHighlightTileAtRow:_XWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeB];
			} else {
				[card2 addInstructionHighlightTileAtRow:j col:_XWingTiles[i].col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_XWingTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card2];
	
	// Step 3: Highlight tiles within scope.
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	
	if (self.size > 2) {
		card3.text = [NSString stringWithFormat:@"If a %li goes in one spot in one %@, it must go in each of the other spots in each of the other %@s.", self.targetPencil, scopeName, scopeName];
	} else {
		card3.text = [NSString stringWithFormat:@"If a %li goes in one spot in one %@, it must go in the other spot in the other %@.", self.targetPencil, scopeName, scopeName];
	}
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card3 addInstructionHighlightTileAtRow:_XWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeB];
			} else {
				[card3 addInstructionHighlightTileAtRow:j col:_XWingTiles[i].col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_XWingTiles[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card3];
	
	// Step 4: Highlight tiles within criss-cross scope.
	ZSHintCard *card4 = [[ZSHintCard alloc] init];
	
	NSString *numberOfRowsColsString = (self.size == 2 ? @"two" : (self.size == 3 ? @"three" : @"four"));
	card4.text = [NSString stringWithFormat:@"Either way, each %@ will have a %li somewhere within the %@ %@s.", oppositeScopeName, self.targetPencil, numberOfRowsColsString, scopeName];
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card4 addInstructionHighlightTileAtRow:j col:_XWingTiles[i].col highlightType:ZSTileHintHighlightTypeC];
			} else {
				[card4 addInstructionHighlightTileAtRow:_XWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeC];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card4 addInstructionHighlightTileAtRow:_XWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeB];
			} else {
				[card4 addInstructionHighlightTileAtRow:j col:_XWingTiles[i].col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_XWingTiles[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card4];
	
	// Step 5: Highlight tiles within criss-cross scope and highlight pencils to remove.
	ZSHintCard *card5 = [[ZSHintCard alloc] init];
	
	NSString *pencilsString = (_totalPencilsToEliminate == 1 ? @"pencil" : @"pencils");
	card5.text = [NSString stringWithFormat:@"This means %li can't exist anywhere else in the %@ %@s influenced by the %@. You can eliminate %li %@.", self.targetPencil, numberOfRowsColsString, oppositeScopeName, techniqueName, _totalPencilsToEliminate, pencilsString];
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card5 addInstructionHighlightTileAtRow:j col:_XWingTiles[i].col highlightType:ZSTileHintHighlightTypeC];
			} else {
				[card5 addInstructionHighlightTileAtRow:_XWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeC];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card5 addInstructionHighlightTileAtRow:_XWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeB];
			} else {
				[card5 addInstructionHighlightTileAtRow:j col:_XWingTiles[i].col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_XWingTiles[i];
		[card5 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card5 addInstructionHighlightPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col highlightType:ZSTilePencilTextHintHighlightTypeA];
	}
	
	[hintCards addObject:card5];
	
	// Step 6: Eliminate the pencils.
	ZSHintCard *card6 = [[ZSHintCard alloc] init];
	
	NSString *hasHaveString = (_totalPencilsToEliminate == 1 ? @"has" : @"have");
	
	card6.text = [NSString stringWithFormat:@"%li %@ %@ been eliminated.", _totalPencilsToEliminate, pencilsString, hasHaveString];
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card6 addInstructionHighlightTileAtRow:j col:_XWingTiles[i].col highlightType:ZSTileHintHighlightTypeC];
			} else {
				[card6 addInstructionHighlightTileAtRow:_XWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeC];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card6 addInstructionHighlightTileAtRow:_XWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeB];
			} else {
				[card6 addInstructionHighlightTileAtRow:j col:_XWingTiles[i].col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_XWingTiles[i];
		[card6 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card6 addInstructionHighlightPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col highlightType:ZSTilePencilTextHintHighlightTypeA];
		[card6 addInstructionRemovePencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col];
	}
	
	[hintCards addObject:card6];
	
	return hintCards;
}

@end

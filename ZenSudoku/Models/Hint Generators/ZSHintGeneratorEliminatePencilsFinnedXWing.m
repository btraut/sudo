//
//  ZSHintGeneratorEliminatePencilsFinnedXWing.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorEliminatePencilsFinnedXWing.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorEliminatePencilsFinnedXWing () {
	BOOL _initialized;
	
	ZSHintGeneratorTileInstruction *_finnedXWingTiles;
	ZSHintGeneratorTileInstruction *_finTiles;
	ZSHintGeneratorTileInstruction *_pencilsToEliminate;
	
	NSInteger _totalFinnedXWingTiles;
	NSInteger _totalFinTiles;
	NSInteger _totalPencilsToEliminate;
}

- (void)_allocTilesAndInstructions;
- (void)_freeTilesAndInstructions;

@end

@implementation ZSHintGeneratorEliminatePencilsFinnedXWing

@synthesize scope, targetPencil, size;

- (id)init {
	self = [super init];
	
	if (self) {
		[self _allocTilesAndInstructions];
	}
	
	return self;
}

- (void)resetTilesAndInstructions {
	_totalFinnedXWingTiles = 0;
	_totalFinTiles = 0;
	_totalPencilsToEliminate = 0;
}

- (void)_allocTilesAndInstructions {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
	
	_finnedXWingTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 16);
	_finTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 16);
	_pencilsToEliminate = malloc(sizeof(ZSHintGeneratorTileInstruction) * 81);
	
	[self resetTilesAndInstructions];
}

- (void)_freeTilesAndInstructions {
	free(_pencilsToEliminate);
	free(_finTiles);
	free(_finnedXWingTiles);
}

- (void)dealloc {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
}

- (void)addFinnedXWingTile:(ZSHintGeneratorTileInstruction)tile {
	_finnedXWingTiles[_totalFinnedXWingTiles++] = tile;
}

- (void)addFinTile:(ZSHintGeneratorTileInstruction)tile {
	_finTiles[_totalFinTiles++] = tile;
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
	
	// Step 1
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	
	card1.text = @"Examine the highlighted tiles. What is special about them?";
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finnedXWingTiles[i];
		[card1 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalFinTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finTiles[i];
		[card1 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeD];
	}
	
	[hintCards addObject:card1];
	
	// Step 2
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	
	card2.text = [NSString stringWithFormat:@"The possibility %i exists in each of the highlighted squares, and in only those spots within their %@s.", self.targetPencil, scopeName];
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card2 addInstructionHighlightTileAtRow:_finnedXWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeB];
			} else {
				[card2 addInstructionHighlightTileAtRow:j col:_finnedXWingTiles[i].col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finnedXWingTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalFinTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeD];
	}
	
	[hintCards addObject:card2];
	
	// Step 3
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	
	NSString *numberOfSpotsString = (self.size == 2 ? @"one or two" : (self.size == 3 ? @"one, two, or three" : @"one, two, three, or four"));
	
	card3.text = [NSString stringWithFormat:@"If the highlighted tiles in both %@s were in the same %@ %@s, they would form %@ %@.", scopeName, numberOfSpotsString, oppositeScopeName, aAnTechniqueName, techniqueName];
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card3 addInstructionHighlightTileAtRow:_finnedXWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeB];
			} else {
				[card3 addInstructionHighlightTileAtRow:j col:_finnedXWingTiles[i].col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finnedXWingTiles[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalFinTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finTiles[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeD];
	}
	
	[hintCards addObject:card3];
	
	// Step 4
	ZSHintCard *card4 = [[ZSHintCard alloc] init];
	
	NSString *malignedPossibilitiesString = (_totalFinTiles == 1 ? @"one" : (_totalFinTiles == 2 ? @"two" : @"three"));
	NSString *malignedPossibilitiesExistsString = (_totalFinTiles == 1 ? @"exists" : @"exist");
	NSString *differentRowColString = (_totalFinTiles == 1 ? @"in a different" : @"in different");
	NSString *oppositeScopePlural = (_totalFinTiles == 1 ? @"" : @"s");
	
	card4.text = [NSString stringWithFormat:@"This formation is not %@ %@ because %@ of the possibilities %@ %@ %@%@.", aAnTechniqueName, techniqueName, malignedPossibilitiesString, malignedPossibilitiesExistsString, differentRowColString, oppositeScopeName, oppositeScopePlural];
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card4 addInstructionHighlightTileAtRow:j col:_finnedXWingTiles[i].col highlightType:ZSTileHintHighlightTypeC];
			} else {
				[card4 addInstructionHighlightTileAtRow:_finnedXWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeC];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card4 addInstructionHighlightTileAtRow:_finnedXWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeB];
			} else {
				[card4 addInstructionHighlightTileAtRow:j col:_finnedXWingTiles[i].col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finnedXWingTiles[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalFinTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finTiles[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeD];
	}
	
	[hintCards addObject:card4];
	
	// Step 5
	ZSHintCard *card5 = [[ZSHintCard alloc] init];
	
	card5.text = [NSString stringWithFormat:@"When these maligned possibilities all exist within the same region, that region is called the \"fin\" and forms a Finned %@.", techniqueName];
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card5 addInstructionHighlightTileAtRow:j col:_finnedXWingTiles[i].col highlightType:ZSTileHintHighlightTypeC];
			} else {
				[card5 addInstructionHighlightTileAtRow:_finnedXWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeC];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card5 addInstructionHighlightTileAtRow:_finnedXWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeB];
			} else {
				[card5 addInstructionHighlightTileAtRow:j col:_finnedXWingTiles[i].col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finnedXWingTiles[i];
		[card5 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalFinTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finTiles[i];
		[card5 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeD];
	}
	
	[hintCards addObject:card5];
	
	// Step 6
	ZSHintCard *card6 = [[ZSHintCard alloc] init];
	
	card6.text = [NSString stringWithFormat:@"Like the %@, we can eliminate pencils in the intersecting %@s, but they must exist within the fin region.", techniqueName, oppositeScopeName];
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card6 addInstructionHighlightTileAtRow:j col:_finnedXWingTiles[i].col highlightType:ZSTileHintHighlightTypeC];
			} else {
				[card6 addInstructionHighlightTileAtRow:_finnedXWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeC];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card6 addInstructionHighlightTileAtRow:_finnedXWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeB];
			} else {
				[card6 addInstructionHighlightTileAtRow:j col:_finnedXWingTiles[i].col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finnedXWingTiles[i];
		[card6 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalFinTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finTiles[i];
		[card6 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeD];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card6 addInstructionHighlightPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col highlightType:ZSTilePencilTextHintHighlightTypeA];
	}
	
	[hintCards addObject:card6];
	
	// Step 7
	ZSHintCard *card7 = [[ZSHintCard alloc] init];
	
	NSString *pencilsString = (_totalPencilsToEliminate == 1 ? @"pencil" : @"pencils");
	NSString *hasHaveString = (_totalPencilsToEliminate == 1 ? @"has" : @"have");
	
	card7.text = [NSString stringWithFormat:@"%i %@ %@ been eliminated.", _totalPencilsToEliminate, pencilsString, hasHaveString];
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card7 addInstructionHighlightTileAtRow:j col:_finnedXWingTiles[i].col highlightType:ZSTileHintHighlightTypeC];
			} else {
				[card7 addInstructionHighlightTileAtRow:_finnedXWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeC];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		for (NSInteger j = 0; j < 9; ++j) {
			if (self.scope == ZSHintGeneratorTileScopeRow) {
				[card7 addInstructionHighlightTileAtRow:_finnedXWingTiles[i].row col:j highlightType:ZSTileHintHighlightTypeB];
			} else {
				[card7 addInstructionHighlightTileAtRow:j col:_finnedXWingTiles[i].col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	}
	
	for (NSInteger i = 0; i < _totalFinnedXWingTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finnedXWingTiles[i];
		[card7 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalFinTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_finTiles[i];
		[card7 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeD];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card7 addInstructionHighlightPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col highlightType:ZSTilePencilTextHintHighlightTypeA];
		[card7 addInstructionRemovePencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col];
	}
	
	[hintCards addObject:card7];
	
	return hintCards;
}

@end

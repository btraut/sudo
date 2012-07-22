//
//  ZSHintGeneratorEliminatePencilsPointingPairs.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorEliminatePencilsPointingPairs.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorEliminatePencilsPointingPairs () {
	BOOL _initialized;
	
	ZSHintGeneratorTileInstruction *_pointingPairTiles;
	ZSHintGeneratorTileInstruction *_groupTiles;
	ZSHintGeneratorTileInstruction *_rowOrColTiles;
	ZSHintGeneratorTileInstruction *_pencilsToEliminate;
	
	NSInteger _totalPointingPairTiles;
	NSInteger _totalGroupTiles;
	NSInteger _totalRowOrColTiles;
	NSInteger _totalPencilsToEliminate;
}

- (void)_allocTilesAndInstructions;
- (void)_freeTilesAndInstructions;

@end

@implementation ZSHintGeneratorEliminatePencilsPointingPairs

@synthesize scope, targetPencil;

- (id)init {
	self = [super init];
	
	if (self) {
		[self _allocTilesAndInstructions];
	}
	
	return self;
}

- (void)resetTilesAndInstructions {
	_totalPointingPairTiles = 0;
	_totalGroupTiles = 0;
	_totalRowOrColTiles = 0;
	_totalPencilsToEliminate = 0;
}

- (void)_allocTilesAndInstructions {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
	
	_pointingPairTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 3);
	_groupTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 9);
	_rowOrColTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 9);
	_pencilsToEliminate = malloc(sizeof(ZSHintGeneratorTileInstruction) * 6);
	
	[self resetTilesAndInstructions];
}

- (void)_freeTilesAndInstructions {
	free(_pencilsToEliminate);
	free(_rowOrColTiles);
	free(_groupTiles);
	free(_pointingPairTiles);
}

- (void)dealloc {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
}

- (void)addPointingPairTile:(ZSHintGeneratorTileInstruction)tile {
	_pointingPairTiles[_totalPointingPairTiles++] = tile;
}

- (void)addGroupTile:(ZSHintGeneratorTileInstruction)tile {
	_groupTiles[_totalGroupTiles++] = tile;
}

- (void)addRowOrColTile:(ZSHintGeneratorTileInstruction)tile {
	_rowOrColTiles[_totalRowOrColTiles++] = tile;
}

- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile {
	_pencilsToEliminate[_totalPencilsToEliminate++] = tile;
}

- (NSArray *)generateHint {
	NSString *scopeName = (scope == ZSHintGeneratorTileScopeRow ? @"row" : (scope == ZSHintGeneratorTileScopeCol ? @"column" : @"group"));
	
	NSMutableArray *hintCards = [NSMutableArray array];
	
	// Step 1: Highlight tiles.
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	card1.text = @"Examine the highlighted tiles. What is special about them?";
	
	for (NSInteger i = 0; i < _totalPointingPairTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pointingPairTiles[i];
		[card1 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card1];
	
	// Step 2: Tiles form a pointing pair.
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	card2.text = [NSString stringWithFormat:@"The highlighted tiles form a pointing pair. They are the only tiles in their region with possibility %i and they are in the same %@.", targetPencil, scopeName];
	
	for (NSInteger i = 0; i < _totalGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_groupTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalRowOrColTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_rowOrColTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalPointingPairTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pointingPairTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card2];
	
	// Step 3: Highlight pencils within scope.
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	NSString *totalPencilsPossibilities = (_totalPencilsToEliminate == 1 ? @"possibility" : @"possibilities");
	card3.text = [NSString stringWithFormat:@"The pointing pair helps eliminate %i %@ in the same %@.", _totalPencilsToEliminate, totalPencilsPossibilities, scopeName];
	
	for (NSInteger i = 0; i < _totalGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_groupTiles[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalRowOrColTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_rowOrColTiles[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalPointingPairTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pointingPairTiles[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card3 addInstructionHighlightPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col highlightType:ZSTilePencilTextHintHighlightTypeA];
	}
	
	[hintCards addObject:card3];
	
	// Step 4: Remove pencils.
	ZSHintCard *card4 = [[ZSHintCard alloc] init];
	NSString *totalPencilsWere = (_totalPencilsToEliminate == 1 ? @"was" : @"were");
	card4.text = [NSString stringWithFormat:@"%i %@ %@ eliminated from the %@.", _totalPencilsToEliminate, totalPencilsPossibilities, totalPencilsWere, scopeName];
	
	for (NSInteger i = 0; i < _totalGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_groupTiles[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalRowOrColTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_rowOrColTiles[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalPointingPairTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pointingPairTiles[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card4 addInstructionHighlightPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col highlightType:ZSTilePencilTextHintHighlightTypeA];
		[card4 addInstructionRemovePencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col];
	}
	
	[hintCards addObject:card4];
	
	return hintCards;
}

@end

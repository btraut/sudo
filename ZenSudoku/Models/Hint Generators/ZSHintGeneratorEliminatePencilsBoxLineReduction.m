//
//  ZSHintGeneratorEliminatePencilsBoxLineReduction.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorEliminatePencilsBoxLineReduction.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorEliminatePencilsBoxLineReduction () {
	BOOL _initialized;
	
	ZSHintGeneratorTileInstruction *_boxLineReductionTiles;
	ZSHintGeneratorTileInstruction *_groupTiles;
	ZSHintGeneratorTileInstruction *_rowOrColTiles;
	ZSHintGeneratorTileInstruction *_pencilsToEliminate;
	
	NSInteger _totalBoxLineReductionTiles;
	NSInteger _totalGroupTiles;
	NSInteger _totalRowOrColTiles;
	NSInteger _totalPencilsToEliminate;
}

- (void)_allocTilesAndInstructions;
- (void)_freeTilesAndInstructions;

@end

@implementation ZSHintGeneratorEliminatePencilsBoxLineReduction

@synthesize scope, targetPencil;

- (id)init {
	self = [super init];
	
	if (self) {
		[self _allocTilesAndInstructions];
	}
	
	return self;
}

- (void)resetTilesAndInstructions {
	_totalBoxLineReductionTiles = 0;
	_totalGroupTiles = 0;
	_totalRowOrColTiles = 0;
	_totalPencilsToEliminate = 0;
}

- (void)_allocTilesAndInstructions {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
	
	_boxLineReductionTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 3);
	_groupTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 9);
	_rowOrColTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 9);
	_pencilsToEliminate = malloc(sizeof(ZSHintGeneratorTileInstruction) * 6);
	
	[self resetTilesAndInstructions];
}

- (void)_freeTilesAndInstructions {
	free(_pencilsToEliminate);
	free(_rowOrColTiles);
	free(_groupTiles);
	free(_boxLineReductionTiles);
}

- (void)dealloc {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
}

- (void)addBoxLineReductionTile:(ZSHintGeneratorTileInstruction)tile {
	_boxLineReductionTiles[_totalBoxLineReductionTiles++] = tile;
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
	NSString *scopeName = (scope == ZSHintGeneratorTileScopeRow ? @"row" : (scope == ZSHintGeneratorTileScopeCol ? @"column" : @"region"));
	
	NSMutableArray *hintCards = [NSMutableArray array];
	
	// Step 1: Highlight tiles.
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	card1.text = @"Examine the highlighted tiles. What is special about them?";
	
	for (NSInteger i = 0; i < _totalBoxLineReductionTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_boxLineReductionTiles[i];
		[card1 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card1];
	
	// Step 2: Tiles form a pointing pair.
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	card2.text = [NSString stringWithFormat:@"The highlighted tiles form a box line reduction. They are the only tiles in their %@ with possibility %i, and they share a region.", scopeName, targetPencil];
	
	for (NSInteger i = 0; i < _totalGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_groupTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalRowOrColTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_rowOrColTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalBoxLineReductionTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_boxLineReductionTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card2];
	
	// Step 3: Highlight pencils within scope.
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	NSString *totalPencilsPossibilities = (_totalPencilsToEliminate == 1 ? @"possibility" : @"possibilities");
	card3.text = [NSString stringWithFormat:@"Because a %i must exist in the %@, it can't possibly exist elsewhere in the region. %i %@ can be eliminated.", targetPencil, scopeName, _totalPencilsToEliminate, totalPencilsPossibilities];
	
	for (NSInteger i = 0; i < _totalGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_groupTiles[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalRowOrColTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_rowOrColTiles[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalBoxLineReductionTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_boxLineReductionTiles[i];
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
	card4.text = [NSString stringWithFormat:@"%i %@ %@ eliminated from the region.", _totalPencilsToEliminate, totalPencilsPossibilities, totalPencilsWere];
	
	for (NSInteger i = 0; i < _totalGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_groupTiles[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalRowOrColTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_rowOrColTiles[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalBoxLineReductionTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_boxLineReductionTiles[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card4 addInstructionRemovePencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col];
	}
	
	[hintCards addObject:card4];
	
	return hintCards;
}

@end

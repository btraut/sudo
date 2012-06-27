//
//  ZSHintGeneratorEliminatePencilsHiddenSubgroup.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorEliminatePencilsHiddenSubgroup.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorEliminatePencilsHiddenSubgroup () {
	BOOL _initialized;
	NSInteger _subgroupSize;
	
	NSInteger _totalSubgroupPencils;
	NSInteger *_subgroupPencils;
	
	ZSHintGeneratorTileInstruction *_groupTiles;
	ZSHintGeneratorTileInstruction *_subGroupTiles;
	ZSHintGeneratorTileInstruction *_pencilsToEliminate;
	
	NSInteger _totalGroupTiles;
	NSInteger _totalSubGroupTiles;
	NSInteger _totalPencilsToEliminate;
}

- (void)_allocTilesAndInstructionsWithSubgroupSize:(NSInteger)size;
- (void)_freeTilesAndInstructions;

@end

@implementation ZSHintGeneratorEliminatePencilsHiddenSubgroup

@synthesize scope;

- (id)init {
	return [self initWithSubgroupSize:2];
}

- (id)initWithSubgroupSize:(NSInteger)size {
	self = [super init];
	
	if (self) {
		_subgroupSize = size;
		[self _allocTilesAndInstructionsWithSubgroupSize:size];
	}
	
	return self;
}

- (void)resetTilesAndInstructions {
	_totalSubgroupPencils = 0;
	
	_totalGroupTiles = 0;
	_totalSubGroupTiles = 0;
	_totalPencilsToEliminate = 0;
}

- (void)_allocTilesAndInstructionsWithSubgroupSize:(NSInteger)size {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
	
	_subgroupPencils = malloc(sizeof(NSInteger) * size);
	
	_groupTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 9 * 3);
	_subGroupTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * size * 3);
	_pencilsToEliminate = malloc(sizeof(ZSHintGeneratorTileInstruction) * 9 * 9 * 3);
	
	[self resetTilesAndInstructions];
}

- (void)_freeTilesAndInstructions {
	free(_pencilsToEliminate);
	free(_subGroupTiles);
	free(_groupTiles);
	
	free(_subgroupPencils);
}

- (void)dealloc {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
}

- (void)addSubgroupPencil:(NSInteger)pencil {
	_subgroupPencils[_totalSubgroupPencils++] = pencil;
}

- (void)addGroupTile:(ZSHintGeneratorTileInstruction)tile {
	_groupTiles[_totalGroupTiles++] = tile;
}

- (void)addSubgroupTile:(ZSHintGeneratorTileInstruction)tile {
	_subGroupTiles[_totalSubGroupTiles++] = tile;
}

- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile {
	_pencilsToEliminate[_totalPencilsToEliminate++] = tile;
}

- (NSArray *)generateHint {
	NSString *groupName = (scope == ZSHintGeneratorTileScopeRow ? @"row" : (scope == ZSHintGeneratorTileScopeCol ? @"column" : @"group"));
	
	NSString *subgroupName;
	NSString *possibilities;
	
	if (_subgroupSize == 2) {
		subgroupName = @"pair";
		possibilities = [NSString stringWithFormat:@"%i and %i", _subgroupPencils[0], _subgroupPencils[1]];
	} else if (_subgroupSize == 3) {
		subgroupName = @"triplet";
		possibilities = [NSString stringWithFormat:@"%i, %i, and/or %i", _subgroupPencils[0], _subgroupPencils[1], _subgroupPencils[2]];
	} else {
		subgroupName = @"quad";
		possibilities = [NSString stringWithFormat:@"%i, %i, %i, and/or %i", _subgroupPencils[0], _subgroupPencils[1], _subgroupPencils[2], _subgroupPencils[3]];
	}
	
	NSMutableArray *hintCards = [NSMutableArray array];
	
	// Step 1: Highlight tiles.
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	card1.text = @"Examine the highlighted tiles. What is special about them?";
	
	for (NSInteger i = 0; i < _totalSubGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_subGroupTiles[i];
		[card1 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card1];
	
	// Step 2: Tiles form a hidden pair/triplet/quad.
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	card2.text = [NSString stringWithFormat:@"The highlighted tiles form a hidden %@ because they are the only tiles in their %@ that have possibilities %@.", subgroupName, groupName, possibilities];
	
	for (NSInteger i = 0; i < _totalGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_groupTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalSubGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_subGroupTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card2];
	
	// Step 3: Highlight pencils within scope.
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	NSString *totalPencilsPossibilities = (_totalPencilsToEliminate == 1 ? @"possibility" : @"possibilities");
	card3.text = [NSString stringWithFormat:@"This allows us to eliminate %i %@ in the tiles that make up the hidden %@.", _totalPencilsToEliminate, totalPencilsPossibilities, subgroupName];
	
	for (NSInteger i = 0; i < _totalGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_groupTiles[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalSubGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_subGroupTiles[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card3 addInstructionHighlightPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col highlightType:ZSTilePencilTextHintHighlightTypeA];
	}
	
	[hintCards addObject:card3];
	
	// Step 4: Remove tiles.
	ZSHintCard *card4 = [[ZSHintCard alloc] init];
	NSString *totalPencilsWere = (_totalPencilsToEliminate == 1 ? @"was" : @"were");
	card4.text = [NSString stringWithFormat:@"%i %@ %@ eliminated.", _totalPencilsToEliminate, totalPencilsPossibilities, totalPencilsWere];
	
	for (NSInteger i = 0; i < _totalGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_groupTiles[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalSubGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_subGroupTiles[i];
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

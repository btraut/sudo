//
//  ZSHintGeneratorEliminatePencilsNakedSubgroup.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorEliminatePencilsNakedSubgroup.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorEliminatePencilsNakedSubgroup () {
	BOOL _initialized;
	NSInteger _subgroupSize;
	
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

@implementation ZSHintGeneratorEliminatePencilsNakedSubgroup

@synthesize subgroupExistsInSameRow, subgroupExistsInSameCol, subgroupExistsInSameGroup;

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
	_totalGroupTiles = 0;
	_totalSubGroupTiles = 0;
	_totalPencilsToEliminate = 0;
}

- (void)_allocTilesAndInstructionsWithSubgroupSize:(NSInteger)size {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
	
	_groupTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * 9 * 3);
	_subGroupTiles = malloc(sizeof(ZSHintGeneratorTileInstruction) * size * 3);
	_pencilsToEliminate = malloc(sizeof(ZSHintGeneratorTileInstruction) * 9 * 9 * 3);
	
	[self resetTilesAndInstructions];
}

- (void)_freeTilesAndInstructions {
	free(_pencilsToEliminate);
	free(_subGroupTiles);
	free(_groupTiles);
}

- (void)dealloc {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
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
	NSString *subgroupName = (_subgroupSize == 2 ? @"pair" : (_subgroupSize == 3 ? @"triplet" : @"quad"));
	
	NSMutableArray *hintCards = [NSMutableArray array];
	
	// Step 1: Highlight tiles.
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	card1.text = @"Examine the highlighted tiles. What is special about them?";
	
	for (NSInteger i = 0; i < _totalSubGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_subGroupTiles[i];
		[card1 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card1];
	
	// Step 2: Tiles form a naked pair/triplet/quad.
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	NSString *orFewerClause = (_subgroupSize == 2 ? @"" : @"(or fewer) ");
	card2.text = [NSString stringWithFormat:@"The highlighted tiles form a naked %@ because they contain the same %i %@possibilities.", subgroupName, _subgroupSize, orFewerClause];
	
	for (NSInteger i = 0; i < _totalSubGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_subGroupTiles[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	[hintCards addObject:card2];
	
	// Step 3: Highlight all tiles in same row/col and/or group.
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	NSString *mainGroupClause = subgroupExistsInSameRow ? @"row" : subgroupExistsInSameCol ? @"column" : @"";
	NSString *andClause = (subgroupExistsInSameRow || subgroupExistsInSameCol) && subgroupExistsInSameGroup ? @" and " : @"";
	NSString *groupClause = subgroupExistsInSameGroup ? @"group" : @"";
	card3.text = [NSString stringWithFormat:@"The possibilities that form the naked %@ can be eliminated from other tiles in the same %@%@%@.", subgroupName, mainGroupClause, andClause, groupClause];
	
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
	
	// Step 4: Highlight pencils within influenced tiles.
	ZSHintCard *card4 = [[ZSHintCard alloc] init];
	NSString *totalPencilsPossibilities = (_totalPencilsToEliminate == 1 ? @"possibility" : @"possibilities");
	card4.text = [NSString stringWithFormat:@"%i %@ in the same %@%@%@ as the naked %@ can be eliminated.", _totalPencilsToEliminate, totalPencilsPossibilities, mainGroupClause, andClause, groupClause, subgroupName];
	
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
		[card4 addInstructionHighlightPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col highlightType:ZSTilePencilTextHintHighlightTypeA];
	}
	
	[hintCards addObject:card4];
	
	// Step 5: Remove tiles.
	ZSHintCard *card5 = [[ZSHintCard alloc] init];
	NSString *totalPencilsWere = (_totalPencilsToEliminate == 1 ? @"was" : @"were");
	card5.text = [NSString stringWithFormat:@"%i %@ %@ eliminated.", _totalPencilsToEliminate, totalPencilsPossibilities, totalPencilsWere];
	
	for (NSInteger i = 0; i < _totalGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_groupTiles[i];
		[card5 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalSubGroupTiles; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_subGroupTiles[i];
		[card5 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeA];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card5 addInstructionRemovePencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col];
	}
	
	[hintCards addObject:card5];
		 
	return hintCards;
}

@end

//
//  ZSHintGeneratorEliminatePencilsYWing.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorEliminatePencilsYWing.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorEliminatePencilsYWing () {
	BOOL _initialized;
	
	ZSHintGeneratorTileInstruction *_pencilsToEliminate;
	
	NSInteger _totalPencilsToEliminate;
}

- (void)_allocTilesAndInstructions;
- (void)_freeTilesAndInstructions;

@end

@implementation ZSHintGeneratorEliminatePencilsYWing

@synthesize hingeTile;
@synthesize pincer1;
@synthesize pincer2;
@synthesize hingePencil1;
@synthesize hingePencil2;
@synthesize targetPencil;

- (id)init {
	self = [super init];
	
	if (self) {
		[self _allocTilesAndInstructions];
	}
	
	return self;
}

- (void)resetTilesAndInstructions {
	_totalPencilsToEliminate = 0;
}

- (void)_allocTilesAndInstructions {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
	
	_pencilsToEliminate = malloc(sizeof(ZSHintGeneratorTileInstruction) * 81);
	
	[self resetTilesAndInstructions];
}

- (void)_freeTilesAndInstructions {
	free(_pencilsToEliminate);
}

- (void)dealloc {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
}

- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile {
	_pencilsToEliminate[_totalPencilsToEliminate++] = tile;
}

- (NSArray *)generateHint {
	NSMutableArray *hintCards = [NSMutableArray array];
	
	// Step 1
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	
	card1.text = @"Examine the highlighted tiles. What is special about them?";
	
	[card1 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col	highlightType:ZSTileHintHighlightTypeA];
	[card1 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col	highlightType:ZSTileHintHighlightTypeA];
	[card1 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col	highlightType:ZSTileHintHighlightTypeA];
	
	[hintCards addObject:card1];
	
	// Step 2
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	
	card2.text = [NSString stringWithFormat:@"These tiles form a Y-Wing. The tile with possibilities %i and %i is called the \"hinge\" and the other two are called \"pincers\".", self.hingePencil1, self.hingePencil2];
	
	[card2 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col	highlightType:ZSTileHintHighlightTypeD];
	[card2 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col	highlightType:ZSTileHintHighlightTypeA];
	[card2 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col	highlightType:ZSTileHintHighlightTypeA];
	
	[hintCards addObject:card2];
	
	// Step 3
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	
	card3.text = [NSString stringWithFormat:@"If the hinge is a %i, one pincer will be a %i. If the hinge is a %i, the other pincer will be a %i. Either way, one of the pincers will be a %i.", self.hingePencil1, self.targetPencil, self.hingePencil2, self.targetPencil, self.targetPencil];
	
	[card3 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col	highlightType:ZSTileHintHighlightTypeD];
	[card3 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col	highlightType:ZSTileHintHighlightTypeA];
	[card3 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col	highlightType:ZSTileHintHighlightTypeA];
	
	[hintCards addObject:card3];
	
	// Step 4
	ZSHintCard *card4 = [[ZSHintCard alloc] init];
	
	card4.text = [NSString stringWithFormat:@"This means that no tile on the board that is influenced by both pincers can possibly be a %i.", self.targetPencil];
	
	[card4 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col	highlightType:ZSTileHintHighlightTypeD];
	[card4 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col	highlightType:ZSTileHintHighlightTypeA];
	[card4 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col	highlightType:ZSTileHintHighlightTypeA];
	
	[hintCards addObject:card4];
	
	// Step 5
	ZSHintCard *card5 = [[ZSHintCard alloc] init];
	
	NSString *tilesString = (_totalPencilsToEliminate == 1 ? @"tile" : @"tiles");
	
	card5.text = [NSString stringWithFormat:@"We can eliminate %i as a possibility in %i such %@.", self.targetPencil, _totalPencilsToEliminate, tilesString];
	
	[card5 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col	highlightType:ZSTileHintHighlightTypeD];
	[card5 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col	highlightType:ZSTileHintHighlightTypeA];
	[card5 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col	highlightType:ZSTileHintHighlightTypeA];
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card5 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card5 addInstructionHighlightPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col highlightType:ZSTilePencilTextHintHighlightTypeA];
	}
	
	[hintCards addObject:card5];
	
	// Step 6
	ZSHintCard *card6 = [[ZSHintCard alloc] init];
	
	NSString *pencilsString = (_totalPencilsToEliminate == 1 ? @"pencil" : @"pencils");
	NSString *hasHaveString = (_totalPencilsToEliminate == 1 ? @"has" : @"have");
	
	card6.text = [NSString stringWithFormat:@"%i %@ %@ been eliminated.", _totalPencilsToEliminate, pencilsString, hasHaveString];
	
	[card6 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col	highlightType:ZSTileHintHighlightTypeD];
	[card6 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col	highlightType:ZSTileHintHighlightTypeA];
	[card6 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col	highlightType:ZSTileHintHighlightTypeA];
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card6 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
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

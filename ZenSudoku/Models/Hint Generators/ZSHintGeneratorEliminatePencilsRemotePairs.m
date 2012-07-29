//
//  ZSHintGeneratorEliminatePencilsRemotePairs.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorEliminatePencilsRemotePairs.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorEliminatePencilsRemotePairs () {
	BOOL _initialized;
	
	ZSHintGeneratorTileInstruction *_evenChainLinks;
	ZSHintGeneratorTileInstruction *_oddChainLinks;
	
	ZSHintGeneratorTileInstruction *_pencilsToEliminate;
	
	NSInteger _totalEvenChainLinks;
	NSInteger _totalOddChainLinks;
	
	NSInteger _totalPencilsToEliminate;
}

- (void)_allocTilesAndInstructions;
- (void)_freeTilesAndInstructions;

@end

@implementation ZSHintGeneratorEliminatePencilsRemotePairs

@synthesize chainPencil1;
@synthesize chainPencil2;

- (id)init {
	self = [super init];
	
	if (self) {
		[self _allocTilesAndInstructions];
	}
	
	return self;
}

- (void)resetTilesAndInstructions {
	_totalPencilsToEliminate = 0;
	_totalEvenChainLinks = 0;
	_totalOddChainLinks = 0;
}

- (void)_allocTilesAndInstructions {
	if (_initialized) {
		[self _freeTilesAndInstructions];
	}
	
	_pencilsToEliminate = malloc(sizeof(ZSHintGeneratorTileInstruction) * 81);
	_evenChainLinks = malloc(sizeof(ZSHintGeneratorTileInstruction) * 81);
	_oddChainLinks = malloc(sizeof(ZSHintGeneratorTileInstruction) * 81);
	
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

- (void)addEvenChainLink:(ZSHintGeneratorTileInstruction)tile {
	_evenChainLinks[_totalEvenChainLinks++] = tile;
}

- (void)addOddChainLink:(ZSHintGeneratorTileInstruction)tile {
	_oddChainLinks[_totalOddChainLinks++] = tile;
}

- (NSArray *)generateHint {
	NSMutableArray *hintCards = [NSMutableArray array];
	
	// Step 1
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	
	card1.text = @"Examine the highlighted tiles. What is special about them?";
	
	for (NSInteger i = 0; i < _totalEvenChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_evenChainLinks[i];
		[card1 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalOddChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_oddChainLinks[i];
		[card1 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	[hintCards addObject:card1];
	
	// Step 2
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	
	card2.text = [NSString stringWithFormat:@"The highlighted tiles all have possibilities %i and %i and all influence each other in a chained fashion.", self.chainPencil1, self.chainPencil2];
	
	for (NSInteger i = 0; i < _totalEvenChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_evenChainLinks[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalOddChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_oddChainLinks[i];
		[card2 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	[hintCards addObject:card2];
	
	// Step 3
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	
	card3.text = [NSString stringWithFormat:@"If the yellow tile is a %i, its neighbors must be %is. The neighbors of those tiles then must be %is.", self.chainPencil1, self.chainPencil2, self.chainPencil1];
	
	for (NSInteger i = 0; i < _totalEvenChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_evenChainLinks[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalOddChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_oddChainLinks[i];
		[card3 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	[card3 addInstructionHighlightTileAtRow:_evenChainLinks[0].row col:_evenChainLinks[0].col highlightType:ZSTileHintHighlightTypeA];
	
	[hintCards addObject:card3];
	
	// Step 4
	ZSHintCard *card4 = [[ZSHintCard alloc] init];
	
	card4.text = [NSString stringWithFormat:@"If, instead, the yellow tile is a %i, each \"link\" in the chain is reversed.", self.chainPencil2];
	
	for (NSInteger i = 0; i < _totalEvenChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_evenChainLinks[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalOddChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_oddChainLinks[i];
		[card4 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	[card4 addInstructionHighlightTileAtRow:_evenChainLinks[0].row col:_evenChainLinks[0].col highlightType:ZSTileHintHighlightTypeA];
	
	[hintCards addObject:card4];
	
	// Step 5
	ZSHintCard *card5 = [[ZSHintCard alloc] init];
	
	card5.text = [NSString stringWithFormat:@"Either way, all the even links in the chain share an answer with other even links, and the odds with other odds."];
	
	for (NSInteger i = 0; i < _totalEvenChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_evenChainLinks[i];
		[card5 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalOddChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_oddChainLinks[i];
		[card5 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	[hintCards addObject:card5];
	
	// Step 6
	ZSHintCard *card6 = [[ZSHintCard alloc] init];
	
	NSString *tilesString = (_totalPencilsToEliminate == 1 ? @"tile" : @"tiles");
	
	card6.text = [NSString stringWithFormat:@"Now examine the orange %@.", tilesString];
	
	for (NSInteger i = 0; i < _totalEvenChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_evenChainLinks[i];
		[card6 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalOddChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_oddChainLinks[i];
		[card6 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card6 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeD];
	}
	
	[hintCards addObject:card6];
	
	// Step 7
	ZSHintCard *card7 = [[ZSHintCard alloc] init];
	
	NSString *itTheyString = (_totalPencilsToEliminate == 1 ? @"it" : @"they");
	NSString *isAreString = (_totalPencilsToEliminate == 1 ? @"is" : @"are");
	NSString *itThemString = (_totalPencilsToEliminate == 1 ? @"it" : @"them");
	
	card7.text = [NSString stringWithFormat:@"Because %@ %@ influenced by both even and odd links, both a %i and %i will influence %@.", itTheyString, isAreString, self.chainPencil1, self.chainPencil2, itThemString];
	
	for (NSInteger i = 0; i < _totalEvenChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_evenChainLinks[i];
		[card7 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalOddChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_oddChainLinks[i];
		[card7 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card7 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeD];
	}
	
	[hintCards addObject:card7];
	
	// Step 8
	ZSHintCard *card8 = [[ZSHintCard alloc] init];
	
	if (_totalPencilsToEliminate == 1) {
		card8.text = [NSString stringWithFormat:@"This means the orange tile cannot be a %i or a %i.", self.chainPencil1, self.chainPencil2];
	} else {
		card8.text = [NSString stringWithFormat:@"This means the orange tiles cannot be %is or %is.", self.chainPencil1, self.chainPencil2];
	}
	
	for (NSInteger i = 0; i < _totalEvenChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_evenChainLinks[i];
		[card8 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalOddChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_oddChainLinks[i];
		[card8 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card8 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeD];
		[card8 addInstructionHighlightPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col highlightType:ZSTilePencilTextHintHighlightTypeA];
	}
	
	[hintCards addObject:card8];
	
	// Step 9
	ZSHintCard *card9 = [[ZSHintCard alloc] init];
	
	NSString *pencilsString = (_totalPencilsToEliminate == 1 ? @"pencil" : @"pencils");
	NSString *hasHaveString = (_totalPencilsToEliminate == 1 ? @"has" : @"have");
	
	card9.text = [NSString stringWithFormat:@"%i %@ %@ been eliminated.", _totalPencilsToEliminate, pencilsString, hasHaveString];
	
	for (NSInteger i = 0; i < _totalEvenChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_evenChainLinks[i];
		[card9 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeC];
	}
	
	for (NSInteger i = 0; i < _totalOddChainLinks; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_oddChainLinks[i];
		[card9 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeB];
	}
	
	for (NSInteger i = 0; i < _totalPencilsToEliminate; ++i) {
		ZSHintGeneratorTileInstruction *instruction = &_pencilsToEliminate[i];
		[card9 addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSTileHintHighlightTypeD];
		[card9 addInstructionHighlightPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col highlightType:ZSTilePencilTextHintHighlightTypeA];
		[card9 addInstructionRemovePencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col];
	}
	
	[hintCards addObject:card9];
	
	return hintCards;
}

@end

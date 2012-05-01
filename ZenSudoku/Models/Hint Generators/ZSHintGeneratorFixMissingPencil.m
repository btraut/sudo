//
//  ZSHintGeneratorFixMissingPencil.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSHintGeneratorFixMissingPencil.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorFixMissingPencil () {
	ZSHintGeneratorFixMissingPencilInstruction *_missingPencilTiles;
	ZSHintGeneratorFixMissingPencilInstruction *_addPencilsTiles;
	
	NSInteger _totalMissingPencilTiles;
	NSInteger _totalAddPencilsTiles;
	
	NSInteger _totalTilesWithPencils;
}

@end

@implementation ZSHintGeneratorFixMissingPencil

- (id)init {
	return [self initWithSize:9];
}
	
- (id)initWithSize:(NSInteger)size {
	self = [super init];
	
	if (self) {
		_missingPencilTiles = malloc(size * size * size * sizeof(ZSHintGeneratorFixMissingPencilInstruction));
		_addPencilsTiles = malloc(size * size * size * sizeof(ZSHintGeneratorFixMissingPencilInstruction));
	}
	
	return self;
}

- (void)dealloc {
	free(_missingPencilTiles);
	free(_addPencilsTiles);
}

- (void)addMissingPencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col {
	_missingPencilTiles[_totalMissingPencilTiles].row = row;
	_missingPencilTiles[_totalMissingPencilTiles].col = col;
	_missingPencilTiles[_totalMissingPencilTiles].pencil = pencil;
	
	++_totalMissingPencilTiles;
}

- (void)addPencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col {
	_addPencilsTiles[_totalAddPencilsTiles].row = row;
	_addPencilsTiles[_totalAddPencilsTiles].col = col;
	_addPencilsTiles[_totalAddPencilsTiles].pencil = pencil;
	
	++_totalAddPencilsTiles;
}

- (void)setTotalTilesWithPencils:(NSInteger)totalTilesWithPencils {
	_totalTilesWithPencils = totalTilesWithPencils;
}

- (NSArray *)generateHint {
	NSMutableArray *hintCards = [NSMutableArray array];
	
	if (_totalTilesWithPencils) {
		ZSHintCard *card1 = [[ZSHintCard alloc] init];
		card1.text = @"Pencil marks are an important tool to solving Sudoku, but work best only when added completely.";
		[hintCards addObject:card1];
		
		if (_totalAddPencilsTiles) {
			ZSHintCard *card2a = [[ZSHintCard alloc] init];
			ZSHintCard *card2b = [[ZSHintCard alloc] init];
			
			if (_totalAddPencilsTiles == 1) {
				card2a.text = @"One of your tiles is missing pencil marks. Continue to automatically add pencils to it.";
			} else {
				card2a.text = @"Some of your tiles are missing pencil marks. Continue to automatically add pencils to them.";
			}
			
			card2b.text = @"Pencil marks have been added.";
			
			for (NSInteger i = 0; i < _totalAddPencilsTiles; ++i) {
				ZSHintGeneratorFixMissingPencilInstruction *instruction = &_addPencilsTiles[i];
				[card2a addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSGameBoardTileHintHighlightTypeA];
				[card2b addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSGameBoardTileHintHighlightTypeB];
				[card2b addInstructionAddPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col];
			}
			
			[hintCards addObject:card2a];
			[hintCards addObject:card2b];
		} else if (_totalMissingPencilTiles) {
			ZSHintCard *card2a = [[ZSHintCard alloc] init];
			ZSHintCard *card2b = [[ZSHintCard alloc] init];
			
			if (_totalMissingPencilTiles == 1) {
				card2a.text = @"One of your tiles with pencil marks is missing some numbers. Continue to automatically add them.";
			} else {
				card2a.text = @"Some of your tiles with pencil marks are missing numbers. Continue to automatically add to them.";
			}
			
			card2b.text = @"Pencil marks have been added.";
			
			for (NSInteger i = 0; i < _totalMissingPencilTiles; ++i) {
				ZSHintGeneratorFixMissingPencilInstruction *instruction = &_missingPencilTiles[i];
				[card2a addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSGameBoardTileHintHighlightTypeA];
				[card2b addInstructionHighlightTileAtRow:instruction->row col:instruction->col highlightType:ZSGameBoardTileHintHighlightTypeB];
				[card2b addInstructionAddPencil:instruction->pencil forTileAtRow:instruction->row col:instruction->col];
			}
			
			[hintCards addObject:card2a];
			[hintCards addObject:card2b];
		}
	} else {
		ZSHintCard *card1 = [[ZSHintCard alloc] init];
		card1.text = @"Pencil marks are an important tool to solving Sudoku. Continue to automatically add pencil marks to the puzzle.";
		[hintCards addObject:card1];
		
		ZSHintCard *card2 = [[ZSHintCard alloc] init];
		card2.text = @"Pencil marks have been added. Enjoy!";
		card2.setAutoPencil = YES;
		[hintCards addObject:card2];
	}
	
	return hintCards;
}

@end






//
//  ZSHintGeneratorSolveSinglePossibility.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSHintGeneratorSolveSinglePossibility.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorSolveSinglePossibility () {
	NSInteger _row;
	NSInteger _col;
	NSInteger _guess;
	ZSHintGeneratorSolveSinglePossibilityScope _scope;
}

@end

@implementation ZSHintGeneratorSolveSinglePossibility

- (void)setSinglePossibility:(NSInteger)guess forTileInRow:(NSInteger)row col:(NSInteger)col scope:(ZSHintGeneratorSolveSinglePossibilityScope)scope {
	_row = row;
	_col = col;
	_guess = guess;
	_scope = scope;
}

- (NSArray *)generateHint {
	NSMutableArray *hintCards = [NSMutableArray array];
	
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	
	if (_scope == ZSHintGeneratorSolveSinglePossibilityScopeRow) {
		card1.text = @"Check this row for any tiles with single possibilities.";
		card2.text = [NSString stringWithFormat:@"The number %i can only be placed in one spot in this row.", _guess];
		card3.text = [NSString stringWithFormat:@"The tile at [%i, %i] is the only tile in this row that can be a %i.", (_row + 1), (_col + 1), _guess];
		
		for (NSInteger i = 0; i < 9; ++i) {
			[card1 addInstructionHighlightTileAtRow:_row col:i highlightType:ZSGameBoardTileHintHighlightTypeB];
			[card2 addInstructionHighlightTileAtRow:_row col:i highlightType:ZSGameBoardTileHintHighlightTypeB];
			
			if (i == _col) {
				[card3 addInstructionHighlightTileAtRow:_row col:i highlightType:ZSGameBoardTileHintHighlightTypeA];
			} else {
				[card3 addInstructionHighlightTileAtRow:_row col:i highlightType:ZSGameBoardTileHintHighlightTypeB];
			}
		}
	} else if (_scope == ZSHintGeneratorSolveSinglePossibilityScopeCol) {
		card1.text = @"Check this column for any tiles with single possibilities.";
		card2.text = [NSString stringWithFormat:@"The number %i can only be placed in one spot in this column.", _guess];
		card3.text = [NSString stringWithFormat:@"The tile at [%i, %i] is the only tile in this column that can be a %i.", (_row + 1), (_col + 1), _guess];
		
		for (NSInteger i = 0; i < 9; ++i) {
			[card1 addInstructionHighlightTileAtRow:i col:_col highlightType:ZSGameBoardTileHintHighlightTypeB];
			[card2 addInstructionHighlightTileAtRow:i col:_col highlightType:ZSGameBoardTileHintHighlightTypeB];
			
			if (i == _row) {
				[card3 addInstructionHighlightTileAtRow:i col:_col highlightType:ZSGameBoardTileHintHighlightTypeA];
			} else {
				[card3 addInstructionHighlightTileAtRow:i col:_col highlightType:ZSGameBoardTileHintHighlightTypeB];
			}
		}
	} else {
		card1.text = @"Check this group for any tiles with single possibilities.";
		card2.text = [NSString stringWithFormat:@"The number %i can only be placed in one spot in this group.", _guess];
		card3.text = [NSString stringWithFormat:@"The tile at [%i, %i] is the only tile in this group that can be a %i.", (_row + 1), (_col + 1), _guess];
		
		NSInteger groupTopRow = (_row / 3) * 3;
		NSInteger groupLeftCol = (_col / 3) * 3;
		
		for (NSInteger i = 0; i < 3; ++i) {
			for (NSInteger j = 0; j < 3; ++j) {
				NSInteger currentRow = groupTopRow + i;
				NSInteger currentCol = groupLeftCol + j;
				
				[card1 addInstructionHighlightTileAtRow:currentRow col:currentCol highlightType:ZSGameBoardTileHintHighlightTypeB];
				[card2 addInstructionHighlightTileAtRow:currentRow col:currentCol highlightType:ZSGameBoardTileHintHighlightTypeB];
				
				if (currentRow == _row && currentCol == _col) {
					[card3 addInstructionHighlightTileAtRow:currentRow col:currentCol highlightType:ZSGameBoardTileHintHighlightTypeA];
				} else {
					[card3 addInstructionHighlightTileAtRow:currentRow col:currentCol highlightType:ZSGameBoardTileHintHighlightTypeB];
				}
			}
		}
	}
	
	[hintCards addObject:card1];
	[hintCards addObject:card2];
	[hintCards addObject:card3];
	
	ZSHintCard *card4 = [[ZSHintCard alloc] init];
	card4.text = [NSString stringWithFormat:@"%i has been set at [%i, %i].", _guess, (_row + 1), (_col + 1)];
	[card4 addInstructionSetGuess:_guess forTileAtRow:_row col:_col];
	[card4 addInstructionHighlightTileAtRow:_row col:_col highlightType:ZSGameBoardTileHintHighlightTypeA];
	[hintCards addObject:card4];
	
	return hintCards;
}

@end

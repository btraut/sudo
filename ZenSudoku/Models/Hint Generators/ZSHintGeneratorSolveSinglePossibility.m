//
//  ZSHintGeneratorSolveSinglePossibility.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorSolveSinglePossibility.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorSolveSinglePossibility () {
	NSInteger _row;
	NSInteger _col;
	NSInteger _guess;
	ZSHintGeneratorTileScope _scope;
}

@end

@implementation ZSHintGeneratorSolveSinglePossibility

- (void)setSinglePossibility:(NSInteger)guess forTileInRow:(NSInteger)row col:(NSInteger)col scope:(ZSHintGeneratorTileScope)scope {
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
	
	if (_scope == ZSHintGeneratorTileScopeRow) {
		card1.text = @"Examine the highlighted row for a tile with a unique possibility.";
		card2.text = [NSString stringWithFormat:@"The answer %li can only be placed in one spot in this row.", _guess];
		card3.text = [NSString stringWithFormat:@"The highlighted tile is the only one in its row that can be a %li.", _guess];
		
		for (NSInteger i = 0; i < 9; ++i) {
			[card1 addInstructionHighlightTileAtRow:_row col:i highlightType:ZSTileHintHighlightTypeB];
			[card2 addInstructionHighlightTileAtRow:_row col:i highlightType:ZSTileHintHighlightTypeB];
			
			if (i == _col) {
				[card3 addInstructionHighlightTileAtRow:_row col:i highlightType:ZSTileHintHighlightTypeA];
			} else {
				[card3 addInstructionHighlightTileAtRow:_row col:i highlightType:ZSTileHintHighlightTypeB];
			}
		}
	} else if (_scope == ZSHintGeneratorTileScopeCol) {
		card1.text = @"Examine the highlighted column for a tile with a unique possibility.";
		card2.text = [NSString stringWithFormat:@"The answer %li can only be placed in one spot in this column.", _guess];
		card3.text = [NSString stringWithFormat:@"The highlighted tile is the only one in its column that can be a %li.", _guess];
		
		for (NSInteger i = 0; i < 9; ++i) {
			[card1 addInstructionHighlightTileAtRow:i col:_col highlightType:ZSTileHintHighlightTypeB];
			[card2 addInstructionHighlightTileAtRow:i col:_col highlightType:ZSTileHintHighlightTypeB];
			
			if (i == _row) {
				[card3 addInstructionHighlightTileAtRow:i col:_col highlightType:ZSTileHintHighlightTypeA];
			} else {
				[card3 addInstructionHighlightTileAtRow:i col:_col highlightType:ZSTileHintHighlightTypeB];
			}
		}
	} else {
		card1.text = @"Examine the highlighted region for a tile with a unique possibility.";
		card2.text = [NSString stringWithFormat:@"The answer %li can only be placed in one spot in this region.", _guess];
		card3.text = [NSString stringWithFormat:@"The highlighted tile is the only one in its region that can be a %li.", _guess];
		
		NSInteger groupTopRow = (_row / 3) * 3;
		NSInteger groupLeftCol = (_col / 3) * 3;
		
		for (NSInteger i = 0; i < 3; ++i) {
			for (NSInteger j = 0; j < 3; ++j) {
				NSInteger currentRow = groupTopRow + i;
				NSInteger currentCol = groupLeftCol + j;
				
				[card1 addInstructionHighlightTileAtRow:currentRow col:currentCol highlightType:ZSTileHintHighlightTypeB];
				[card2 addInstructionHighlightTileAtRow:currentRow col:currentCol highlightType:ZSTileHintHighlightTypeB];
				
				if (currentRow == _row && currentCol == _col) {
					[card3 addInstructionHighlightTileAtRow:currentRow col:currentCol highlightType:ZSTileHintHighlightTypeA];
				} else {
					[card3 addInstructionHighlightTileAtRow:currentRow col:currentCol highlightType:ZSTileHintHighlightTypeB];
				}
			}
		}
	}
	
	[hintCards addObject:card1];
	[hintCards addObject:card2];
	[hintCards addObject:card3];
	
	ZSHintCard *card4 = [[ZSHintCard alloc] init];
	card4.text = [NSString stringWithFormat:@"%li has been set.", _guess];
	[card4 addInstructionSetGuess:_guess forTileAtRow:_row col:_col];
	[card4 addInstructionHighlightTileAtRow:_row col:_col highlightType:ZSTileHintHighlightTypeA];
	[hintCards addObject:card4];
	
	return hintCards;
}

@end

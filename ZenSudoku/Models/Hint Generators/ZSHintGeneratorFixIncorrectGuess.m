//
//  ZSHintGeneratorFixIncorrectGuess.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorFixIncorrectGuess.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorFixIncorrectGuess () {
	NSInteger _row;
	NSInteger _col;
}

@end

@implementation ZSHintGeneratorFixIncorrectGuess

- (void)setIncorrectTileRow:(NSInteger)row col:(NSInteger)col {
	_row = row;
	_col = col;
}

- (NSArray *)generateHint {
	NSMutableArray *hintCards = [NSMutableArray array];
	
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	card1.text = @"Look for an incorrect guess on the board.";
	[hintCards addObject:card1];
	
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	card2.text = [NSString stringWithFormat:@"The guess at [%i, %i] is incorrect. Continue to clear it.", (_row + 1), (_col + 1)];
	[card2 addInstructionHighlightTileAtRow:_row col:_col highlightType:ZSTileHintHighlightTypeA];
	[hintCards addObject:card2];
	
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	card3.text = [NSString stringWithFormat:@"The incorrect guess has been cleared. Good luck!"];
	[card3 addInstructionRemoveGuessForTileAtRow:_row col:_col];
	[hintCards addObject:card3];
	
	return hintCards;
}

@end

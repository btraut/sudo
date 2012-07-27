//
//  ZSHintGeneratorSolveOnlyChoice.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorSolveOnlyChoice.h"

#import "ZSHintCard.h"

@interface ZSHintGeneratorSolveOnlyChoice () {
	NSInteger _row;
	NSInteger _col;
	NSInteger _choice;
}

@end

@implementation ZSHintGeneratorSolveOnlyChoice

- (void)setOnlyChoice:(NSInteger)choice forTileInRow:(NSInteger)row col:(NSInteger)col {
	_row = row;
	_col = col;
	_choice = choice;
}

- (NSArray *)generateHint {
	NSMutableArray *hintCards = [NSMutableArray array];
	
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	card1.text = @"Examine the highlighted tile. What is special about it?";
	[card1 addInstructionHighlightTileAtRow:_row col:_col highlightType:ZSTileHintHighlightTypeB];
	[hintCards addObject:card1];
	
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	card2.text = @"Think about which answers could possibly fit for this tile.";
	[card2 addInstructionHighlightTileAtRow:_row col:_col highlightType:ZSTileHintHighlightTypeB];
	[hintCards addObject:card2];
	
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	card3.text = [NSString stringWithFormat:@"The tile must be a %i because it cannot be any other choice.", _choice];
	[card3 addInstructionSetGuess:_choice forTileAtRow:_row col:_col];
	[hintCards addObject:card3];
	
	return hintCards;
}

@end

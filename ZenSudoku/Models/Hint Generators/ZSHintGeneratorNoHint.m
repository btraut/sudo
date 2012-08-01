//
//  ZSHintGeneratorNoHint.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorNoHint.h"

#import "ZSHintCard.h"

@implementation ZSHintGeneratorNoHint

@synthesize randomEliminateInstruction;

- (NSArray *)generateHint {
	NSMutableArray *hintCards = [NSMutableArray array];
	
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	card1.text = @"Oh no! This puzzle is really tough! Sudo has run out of hints.";
	[hintCards addObject:card1];
	
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	card2.text = @"The use of logic techniques and shortcuts works on most puzzles, but others are simply too hard for most humans to solve without guessing.";
	[hintCards addObject:card2];
	
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	card3.text = @"For these puzzles, even computers are forced to guess, then check to see if the puzzle is valid, and backtrack if not.";
	[hintCards addObject:card3];
	
	ZSHintCard *card4 = [[ZSHintCard alloc] init];
	card4.text = @"This method works well for computers because they can make guesses and backtrack very quickly.";
	[hintCards addObject:card4];
	
	ZSHintCard *card5 = [[ZSHintCard alloc] init];
	card5.text = @"As a consolation, Sudo can eliminate a random possibility from the board to help you continue.";
	[hintCards addObject:card5];
	
	// Step 6 actually does some work.
	ZSHintCard *card6 = [[ZSHintCard alloc] init];
	
	card6.text = [NSString stringWithFormat:@"%i has been eliminated from the highlighted tile. Good luck!", self.randomEliminateInstruction.pencil];
	
	[card6 addInstructionHighlightTileAtRow:self.randomEliminateInstruction.row col:self.randomEliminateInstruction.col highlightType:ZSTileHintHighlightTypeA];
	[card6 addInstructionHighlightPencil:self.randomEliminateInstruction.pencil forTileAtRow:self.randomEliminateInstruction.row col:self.randomEliminateInstruction.col highlightType:ZSTilePencilTextHintHighlightTypeA];
	[card6 addInstructionRemovePencil:self.randomEliminateInstruction.pencil forTileAtRow:self.randomEliminateInstruction.row col:self.randomEliminateInstruction.col];
	
	[hintCards addObject:card6];
	
	return hintCards;
}

@end

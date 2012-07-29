//
//  ZSHintGeneratorEliminatePencilsAvoidableRectangles.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorEliminatePencilsAvoidableRectangles.h"

#import "ZSHintCard.h"

@implementation ZSHintGeneratorEliminatePencilsAvoidableRectangles

@synthesize hingeTile;
@synthesize pincer1;
@synthesize pincer2;
@synthesize eliminateInstruction;
@synthesize diagonalAnswer;
@synthesize impossibleAnswer;

- (NSArray *)generateHint {
	NSMutableArray *hintCards = [NSMutableArray array];
	
	// Step 1
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	
	card1.text = @"Examine the highlighted tiles. What is special about them?";
	
	[card1 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col highlightType:ZSTileHintHighlightTypeA];
	[card1 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col highlightType:ZSTileHintHighlightTypeA];
	[card1 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col highlightType:ZSTileHintHighlightTypeA];
	[card1 addInstructionHighlightTileAtRow:eliminateInstruction.row col:eliminateInstruction.col highlightType:ZSTileHintHighlightTypeD];
	
	[hintCards addObject:card1];
	
	// Step 2
	ZSHintCard *card2 = [[ZSHintCard alloc] init];
	
	card2.text = [NSString stringWithFormat:@"First, it's important to note that each Sudoku puzzle only has one unique solution."];
	
	[card2 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col highlightType:ZSTileHintHighlightTypeA];
	[card2 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col highlightType:ZSTileHintHighlightTypeA];
	[card2 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col highlightType:ZSTileHintHighlightTypeA];
	[card2 addInstructionHighlightTileAtRow:eliminateInstruction.row col:eliminateInstruction.col highlightType:ZSTileHintHighlightTypeD];
	
	[hintCards addObject:card2];
	
	// Step 3
	ZSHintCard *card3 = [[ZSHintCard alloc] init];
	
	card3.text = [NSString stringWithFormat:@"Let's pretend that %i is the answer in the empty tile and that the rest of the puzzle could be solved from that position.", self.impossibleAnswer];
	
	[card3 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col highlightType:ZSTileHintHighlightTypeA];
	[card3 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col highlightType:ZSTileHintHighlightTypeA];
	[card3 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col highlightType:ZSTileHintHighlightTypeA];
	[card3 addInstructionHighlightTileAtRow:eliminateInstruction.row col:eliminateInstruction.col highlightType:ZSTileHintHighlightTypeD];
	
	[hintCards addObject:card3];
	
	// Step 4
	ZSHintCard *card4 = [[ZSHintCard alloc] init];
	
	card4.text = [NSString stringWithFormat:@"Once the puzzle was solved, it would then be possible to swap the %is and %is and the puzzle would still be valid.", self.impossibleAnswer, self.diagonalAnswer];
	
	[card4 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col highlightType:ZSTileHintHighlightTypeA];
	[card4 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col highlightType:ZSTileHintHighlightTypeA];
	[card4 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col highlightType:ZSTileHintHighlightTypeA];
	[card4 addInstructionHighlightTileAtRow:eliminateInstruction.row col:eliminateInstruction.col highlightType:ZSTileHintHighlightTypeD];
	
	[hintCards addObject:card4];
	
	// Step 5
	ZSHintCard *card5 = [[ZSHintCard alloc] init];
	
	card5.text = [NSString stringWithFormat:@"This means the puzzle would have two solutions. Because each puzzle can only have one, this scenario is impossible!"];
	
	[card5 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col highlightType:ZSTileHintHighlightTypeA];
	[card5 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col highlightType:ZSTileHintHighlightTypeA];
	[card5 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col highlightType:ZSTileHintHighlightTypeA];
	[card5 addInstructionHighlightTileAtRow:eliminateInstruction.row col:eliminateInstruction.col highlightType:ZSTileHintHighlightTypeD];
	
	[hintCards addObject:card5];
	
	// Step 6
	ZSHintCard *card6 = [[ZSHintCard alloc] init];
	
	card6.text = [NSString stringWithFormat:@"Therefore, the empty tile cannot possibly be a %i. This is called an Avoidable Rectangle.", self.impossibleAnswer];
	
	[card6 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col highlightType:ZSTileHintHighlightTypeA];
	[card6 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col highlightType:ZSTileHintHighlightTypeA];
	[card6 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col highlightType:ZSTileHintHighlightTypeA];
	[card6 addInstructionHighlightTileAtRow:eliminateInstruction.row col:eliminateInstruction.col highlightType:ZSTileHintHighlightTypeD];
	
	[card6 addInstructionHighlightPencil:eliminateInstruction.pencil forTileAtRow:eliminateInstruction.row col:eliminateInstruction.col highlightType:ZSTilePencilTextHintHighlightTypeA];

	[hintCards addObject:card6];
	
	// Step 7
	ZSHintCard *card7 = [[ZSHintCard alloc] init];
	
	card7.text = [NSString stringWithFormat:@"%i has been eliminated as a possibility.", self.impossibleAnswer];
	
	[card7 addInstructionHighlightTileAtRow:hingeTile.row col:hingeTile.col highlightType:ZSTileHintHighlightTypeA];
	[card7 addInstructionHighlightTileAtRow:pincer1.row col:pincer1.col highlightType:ZSTileHintHighlightTypeA];
	[card7 addInstructionHighlightTileAtRow:pincer2.row col:pincer2.col highlightType:ZSTileHintHighlightTypeA];
	[card7 addInstructionHighlightTileAtRow:eliminateInstruction.row col:eliminateInstruction.col highlightType:ZSTileHintHighlightTypeD];
	
	[card7 addInstructionHighlightPencil:eliminateInstruction.pencil forTileAtRow:eliminateInstruction.row col:eliminateInstruction.col highlightType:ZSTilePencilTextHintHighlightTypeA];
	[card7 addInstructionRemovePencil:eliminateInstruction.pencil forTileAtRow:eliminateInstruction.row col:eliminateInstruction.col];
	
	[hintCards addObject:card7];
	
	return hintCards;
}

@end

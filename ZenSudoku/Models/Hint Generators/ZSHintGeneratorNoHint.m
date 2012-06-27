//
//  ZSHintGeneratorNoHint.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintGeneratorNoHint.h"

#import "ZSHintCard.h"
#import "ZSBoard.h"

@interface ZSHintGeneratorNoHint () {
	ZSBoard *_board;
}

- (void)_sendGameBoardToDevelopers;

@end

@implementation ZSHintGeneratorNoHint

- (void)setGameBoard:(ZSBoard *)board {
	_board = board;
}

- (void)_sendGameBoardToDevelopers {
	// Todo: Implement!
}

- (NSArray *)generateHint {
	[self _sendGameBoardToDevelopers];
	
	NSMutableArray *hintCards = [NSMutableArray array];
	
	ZSHintCard *card1 = [[ZSHintCard alloc] init];
	card1.text = @"Oh no! We've run out of hints! This puzzle will automatically be sent to the developers of ZenSudoku so that more hints can be made.";
	[hintCards addObject:card1];
	
	return hintCards;
}

@end

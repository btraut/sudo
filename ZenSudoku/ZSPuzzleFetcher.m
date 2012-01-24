//
//  ZSPuzzleFetcher.m
//  ZenSudoku
//
//  Created by Brent Traut on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSPuzzleFetcher.h"
#import "ZSAppDelegate.h"
#import "ZSFastGameSolver.h"

#import "FMDatabase.h"

NSString * const kSQLiteDBFileName = @"Sudoku.db3";

@implementation ZSPuzzleFetcher

+ (ZSGame *)fetchGameWithDifficulty:(ZSGameDifficulty)difficulty {
	ZSPuzzleFetcher *fetcher = [[self alloc] init];
	return [fetcher _fetchGameWithDifficulty:difficulty];
}

- (id)init {
	self = [super init];
	
	if (self) {
		// Fetch the path to the DB.
		ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSString *sqliteDBPath = [appDelegate getPathForFileName:kSQLiteDBFileName];
		
		// Create the DB.
		db = [FMDatabase databaseWithPath:sqliteDBPath];
		
		// Attempt to open the DB. If we can't, we're done here.
		if (![db open]) {
			return nil;
		}
	}
	
	return self;
}

- (void)dealloc {
	[db close];
}

- (ZSGame *)_fetchGameWithDifficulty:(ZSGameDifficulty)difficulty {
	NSString *puzzleString = [self getRandomPuzzleStringForDifficulty:difficulty];
	return [self createGameWithDifficulty:difficulty puzzleString:puzzleString];
}

- (NSInteger)getTotalPuzzlesForDifficulty:(ZSGameDifficulty)difficulty {
	NSInteger total = 0;
	
	FMResultSet *result = [db executeQuery:@"SELECT count(1) AS `count` FROM `puzzles` WHERE `puzzle_difficulty` = ?", [NSNumber numberWithInt:difficulty]];
	
	if ([result next]) {
		total = [result intForColumn:@"count"];
	}
	
	[result close];
	
	return total;
}

- (NSInteger)getTotalFreshPuzzlesForDifficulty:(ZSGameDifficulty)difficulty {
	NSInteger totalFresh = 0;
	
	FMResultSet *result = [db executeQuery:@"SELECT count(1) AS `count` FROM `puzzles` WHERE `puzzle_difficulty` = ? AND `puzzle_used` = 0", [NSNumber numberWithInt:difficulty]];
	
	if ([result next]) {
		totalFresh = [result intForColumn:@"count"];
	}
	
	[result close];  
	
	return totalFresh;
}

- (NSString *)getRandomPuzzleStringForDifficulty:(ZSGameDifficulty)difficulty {
	// Get some totals.
	NSInteger totalPuzzles = [self getTotalFreshPuzzlesForDifficulty:difficulty];
	BOOL requireFresh = YES;
	
	if (!totalPuzzles) {
		totalPuzzles = [self getTotalPuzzlesForDifficulty:difficulty];
		requireFresh = NO;
	}
	
	assert(totalPuzzles);
	
	// Pick a random puzzle from the remaining total.
	NSInteger puzzleNumber = arc4random() % totalPuzzles;
	
	// Build the query.
	NSString *puzzleQuery;
	
	if (requireFresh) {
		puzzleQuery = @"SELECT `puzzle_string` FROM `puzzles` WHERE `puzzle_used` = 0 AND `puzzle_difficulty` = ? LIMIT ?, 1";
	} else {
		puzzleQuery = @"SELECT `puzzle_string` FROM `puzzles` WHERE `puzzle_difficulty` = ? LIMIT ?, 1";
	}
	
	// Fetch the puzzle result.
	FMResultSet *result = [db executeQuery:puzzleQuery, [NSNumber numberWithInt:difficulty], [NSNumber numberWithInt:puzzleNumber]];
	
	NSString *puzzleString;

	if ([result next]) {
		puzzleString = [result stringForColumn:@"puzzle_string"];
	}
	
	[result close];
	
	assert([puzzleString length]);
	
	// Return the puzzle string.
	return puzzleString;
}

- (ZSGame *)createGameWithDifficulty:(ZSGameDifficulty)difficulty puzzleString:(NSString *)puzzleString {
	// Create a new game.
	ZSGame *game = [ZSGame emptyStandard9x9Game];
	
	game.difficulty = difficulty;
	game.type = ZSGameTypeTraditional;
	
	// Prepare the game board.
	[game.gameBoard copyGuessesFromString:puzzleString];
	ZSGameSolveResult result = [game solve];
	
	assert(result == ZSGameSolveResultSucceeded);
	
	[game.gameBoard lockGuesses];
	
	// Return the game.
	return game;
}

@end

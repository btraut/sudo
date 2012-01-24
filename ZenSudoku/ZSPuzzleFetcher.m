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
NSString * const kSQLiteDBFileNameResource = @"Sudoku";
NSString * const kSQLiteDBFileNameType = @"db3";

@implementation ZSPuzzleFetcher

+ (ZSGame *)fetchGameWithDifficulty:(ZSGameDifficulty)difficulty {
	ZSPuzzleFetcher *fetcher = [[self alloc] init];
	return [fetcher _fetchGameWithDifficulty:difficulty];
}

- (id)init {
	self = [super init];
	
	if (self) {
		// Create the DB.
		db = [self locateOrCreateDatabase];
		
		// Attempt to open the DB. If we can't, we're done here.
		if (![db open]) {
			return nil;
		}
	}
	
	return self;
}

- (FMDatabase *)locateOrCreateDatabase {
	ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *sqliteDBPath = [appDelegate getPathForFileName:kSQLiteDBFileName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:sqliteDBPath]) {
		NSString *resourcePath = [[NSBundle mainBundle] pathForResource:kSQLiteDBFileNameResource ofType:kSQLiteDBFileNameType];
		[fileManager copyItemAtPath:resourcePath toPath:sqliteDBPath error:nil];
	}
	
	return [FMDatabase databaseWithPath:sqliteDBPath];
}

- (void)dealloc {
	[db close];
}

- (ZSGame *)_fetchGameWithDifficulty:(ZSGameDifficulty)difficulty {
	NSString *puzzleString = [self getRandomPuzzleStringForDifficulty:difficulty];
	return [self createGameWithDifficulty:difficulty puzzleString:puzzleString];
}

- (void)markPuzzleUsed:(NSInteger)puzzleId {
	[db executeUpdate:@"UPDATE `puzzles` SET `puzzle_used` = 1 WHERE `puzzle_id` = ?", [NSNumber numberWithInt:puzzleId]];
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
		puzzleQuery = @"SELECT `puzzle_id`, `puzzle_string` FROM `puzzles` WHERE `puzzle_used` = 0 AND `puzzle_difficulty` = ? LIMIT ?, 1";
	} else {
		puzzleQuery = @"SELECT `puzzle_id`, `puzzle_string` FROM `puzzles` WHERE `puzzle_difficulty` = ? LIMIT ?, 1";
	}
	
	// Fetch the puzzle result.
	FMResultSet *result = [db executeQuery:puzzleQuery, [NSNumber numberWithInt:difficulty], [NSNumber numberWithInt:puzzleNumber]];
	
	NSString *puzzleString;
	NSInteger puzzleId;

	if ([result next]) {
		puzzleString = [result stringForColumn:@"puzzle_string"];
		puzzleId = [result intForColumn:@"puzzle_id"];
	}
	
	[result close];
	
	assert([puzzleString length]);
	
	// Mark the selected puzzle as used.
	[self markPuzzleUsed:puzzleId];
	
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

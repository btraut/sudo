//
//  ZSPuzzleFetcher.m
//  ZenSudoku
//
//  Created by Brent Traut on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSPuzzleFetcher.h"
#import "ZSAppDelegate.h"

#import "FMDatabase.h"

NSString * const kSQLiteDBFileName = @"Sudoku.db3";
NSString * const kSQLiteDBFileNameResource = @"Sudoku";
NSString * const kSQLiteDBFileNameType = @"db3";

NSString * const kDBPuzzleDefinitionIdKey = @"kDBPuzzleDefinitionIdKey";
NSString * const kDBPuzzleDefinitionTypeKey = @"kDBPuzzleDefinitionTypeKey";
NSString * const kDBPuzzleDefinitionSizeKey = @"kDBPuzzleDefinitionSizeKey";
NSString * const kDBPuzzleDefinitionDifficultyKey = @"kDBPuzzleDefinitionDifficultyKey";
NSString * const kDBPuzzleDefinitionGuessesKey = @"kDBPuzzleDefinitionGuessesKey";
NSString * const kDBPuzzleDefinitionAnswersKey = @"kDBPuzzleDefinitionAnswersKey";
NSString * const kDBPuzzleDefinitionGroupMapKey = @"kDBPuzzleDefinitionGroupMapKey";

@implementation ZSPuzzleFetcher

- (id)init {
	self = [super init];
	
	if (self) {
		// Locate the DB.
		NSString *sqliteDBPath = [[NSBundle mainBundle] pathForResource:kSQLiteDBFileNameResource ofType:kSQLiteDBFileNameType];
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

- (ZSGame *)fetchGameWithType:(ZSGameType)type size:(NSInteger)size difficulty:(ZSGameDifficulty)difficulty {
	NSDictionary *dict = [self getRandomPuzzleWithType:type size:size difficulty:difficulty];
	return [self createGameWithDictionary:dict];
}

- (NSDictionary *)getRandomPuzzleWithType:(ZSGameType)type size:(NSInteger)size difficulty:(ZSGameDifficulty)difficulty {
	// Get total puzzle count.
	NSInteger totalPuzzles = 0;
	
	NSString *totalPuzzleQuery = @"SELECT count(1) AS `count` FROM `puzzles` WHERE `puzzle_type` = ? AND `puzzle_size` = ? AND `puzzle_difficulty` = ?";
	FMResultSet *totalPuzzlesResult = [db executeQuery:totalPuzzleQuery, [NSNumber numberWithInt:type], [NSNumber numberWithInt:size], [NSNumber numberWithInt:difficulty]];
	
	if ([totalPuzzlesResult next]) {
		totalPuzzles = [totalPuzzlesResult intForColumn:@"count"];
	}
	
	[totalPuzzlesResult close];
	
	assert(totalPuzzles);
	
	// Pick a random puzzle from the remaining total.
	NSInteger puzzleNumber = arc4random() % totalPuzzles;
	
	// Fetch a puzzle.
	NSString *puzzleQuery = @"SELECT `puzzle_id`, `puzzle_guesses`, `puzzle_answers`, `puzzle_group_map` FROM `puzzles` WHERE `puzzle_type` = ? AND `puzzle_size` = ? AND `puzzle_difficulty` = ? LIMIT ?, 1";
	FMResultSet *result = [db executeQuery:puzzleQuery, [NSNumber numberWithInt:type], [NSNumber numberWithInt:size], [NSNumber numberWithInt:difficulty], [NSNumber numberWithInt:puzzleNumber]];
	
	NSMutableDictionary *puzzleDefinition = [NSMutableDictionary dictionary];
	
	if ([result next]) {
		[puzzleDefinition setObject:[NSNumber numberWithInt:[result intForColumn:@"puzzle_id"]] forKey:kDBPuzzleDefinitionIdKey];
		[puzzleDefinition setObject:[result stringForColumn:@"puzzle_guesses"] forKey:kDBPuzzleDefinitionGuessesKey];
		[puzzleDefinition setObject:[result stringForColumn:@"puzzle_answers"] forKey:kDBPuzzleDefinitionAnswersKey];
		[puzzleDefinition setObject:[result stringForColumn:@"puzzle_group_map"] forKey:kDBPuzzleDefinitionGroupMapKey];
		
		[puzzleDefinition setObject:[NSNumber numberWithInt:type] forKey:kDBPuzzleDefinitionTypeKey];
		[puzzleDefinition setObject:[NSNumber numberWithInt:size] forKey:kDBPuzzleDefinitionSizeKey];
		[puzzleDefinition setObject:[NSNumber numberWithInt:difficulty] forKey:kDBPuzzleDefinitionDifficultyKey];
	}
	
	[result close];
	
	assert([puzzleDefinition count]);
	
	// Return the puzzle string.
	return puzzleDefinition;
}

- (ZSGame *)createGameWithDictionary:dict {
	// Create a new game.
	ZSGame *game = [ZSGame emptyStandard9x9Game];
	
	game.difficulty = [[dict objectForKey:kDBPuzzleDefinitionDifficultyKey] intValue];
	game.type = [[dict objectForKey:kDBPuzzleDefinitionTypeKey] intValue];
	
	// Prepare the game board.
	[game.gameBoard copyGuessesFromString:[dict objectForKey:kDBPuzzleDefinitionGuessesKey]];
	[game.gameBoard copyAnswersFromString:[dict objectForKey:kDBPuzzleDefinitionAnswersKey]];
	[game.gameBoard copyGroupMapFromString:[dict objectForKey:kDBPuzzleDefinitionGroupMapKey]];
	
	[game.gameBoard lockGuesses];
	
	// Return the game.
	return game;
}

@end

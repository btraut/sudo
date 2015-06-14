//
//  ZSPuzzleFetcher.m
//  ZenSudoku
//
//  Created by Brent Traut on 1/23/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSPuzzleFetcher.h"
#import "ZSAppDelegate.h"

#import "FMDatabase.h"

NSString * const kSQLiteDBFileNameResource = @"Puzzles";
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

- (NSArray *)fetchGames:(NSInteger)howMany withDifficulty:(ZSGameDifficulty)difficulty {
	NSMutableArray *games = [NSMutableArray array];
	
	NSArray *puzzles = [self _getRandomPuzzles:howMany type:ZSGameTypeTraditional size:9 difficulty:difficulty];
	
	for (NSDictionary *dict in puzzles) {
		[games addObject:[self _createGameWithDictionary:dict]];
	}
	
	return games;
}

- (NSDictionary *)_getRandomPuzzleWithType:(ZSGameType)type size:(NSInteger)size difficulty:(ZSGameDifficulty)difficulty {
	return [[self _getRandomPuzzles:1 type:type size:size difficulty:difficulty] objectAtIndex:0];
}

- (NSArray *)_getRandomPuzzles:(NSInteger)howMany type:(ZSGameType)type size:(NSInteger)size difficulty:(ZSGameDifficulty)difficulty {
	// Initialize return array.
	NSMutableArray *puzzles = [NSMutableArray array];
	
	// Pick a specific puzzle (debug purposes).
	BOOL forcePuzzleById = NO;
	NSInteger puzzleId = 28201;
	
	// Fetch a puzzle.
	FMResultSet *result;
	
	if (forcePuzzleById) {
		// Fetch a specific puzzle.
		NSString *puzzleQuery = @"SELECT `puzzle_id`, `puzzle_guesses`, `puzzle_answers`, `puzzle_group_map` FROM `puzzles` WHERE `puzzle_id` = ?";
		result = [db executeQuery:puzzleQuery, [NSNumber numberWithInteger:puzzleId]];
	} else {
		// Fetch some number of random puzzles.
		NSString *puzzleQuery = @"SELECT `puzzle_id`, `puzzle_guesses`, `puzzle_answers`, `puzzle_group_map` FROM `puzzles` WHERE `puzzle_type` = ? AND `puzzle_size` = ? AND `puzzle_difficulty` = ? ORDER BY RANDOM() LIMIT ?";
		result = [db executeQuery:puzzleQuery, [NSNumber numberWithInteger:type], [NSNumber numberWithInteger:size], [NSNumber numberWithInteger:difficulty], [NSNumber numberWithInteger:howMany]];
	}
	
	// Load the puzzle row into a dictionary.
	while ([result next]) {
		NSMutableDictionary *puzzleDefinition = [NSMutableDictionary dictionary];
		
		[puzzleDefinition setObject:[NSNumber numberWithInteger:[result intForColumn:@"puzzle_id"]] forKey:kDBPuzzleDefinitionIdKey];
		[puzzleDefinition setObject:[result stringForColumn:@"puzzle_guesses"] forKey:kDBPuzzleDefinitionGuessesKey];
		[puzzleDefinition setObject:[result stringForColumn:@"puzzle_answers"] forKey:kDBPuzzleDefinitionAnswersKey];
		[puzzleDefinition setObject:[result stringForColumn:@"puzzle_group_map"] forKey:kDBPuzzleDefinitionGroupMapKey];
		
		[puzzleDefinition setObject:[NSNumber numberWithInt:type] forKey:kDBPuzzleDefinitionTypeKey];
		[puzzleDefinition setObject:[NSNumber numberWithInteger:size] forKey:kDBPuzzleDefinitionSizeKey];
		[puzzleDefinition setObject:[NSNumber numberWithInt:difficulty] forKey:kDBPuzzleDefinitionDifficultyKey];
		
		[puzzles addObject:puzzleDefinition];
	}
	
	[result close];
	
	// Return the array of puzzle dictionaries.
	return puzzles;
}

- (ZSGame *)_createGameWithDictionary:dict {
	// Create a new game.
	ZSGame *game = [ZSGame emptyStandard9x9Game];
	
	game.difficulty = [[dict objectForKey:kDBPuzzleDefinitionDifficultyKey] intValue];
	game.type = [[dict objectForKey:kDBPuzzleDefinitionTypeKey] intValue];
	
	// Prepare the game board.
	[game.board copyGuessesFromString:[dict objectForKey:kDBPuzzleDefinitionGuessesKey]];
	[game.board copyAnswersFromString:[dict objectForKey:kDBPuzzleDefinitionAnswersKey]];
	[game.board copyGroupMapFromString:[dict objectForKey:kDBPuzzleDefinitionGroupMapKey]];
	
	[game.board lockGuesses];
	
	// Return the game.
	return game;
}

@end

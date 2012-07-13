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
	
	// Fetch a puzzle.
	FMResultSet *result;
	
	if (forcePuzzleById) {
		NSInteger puzzleId = 16241;
		
		NSString *puzzleQuery = @"SELECT `puzzle_id`, `puzzle_guesses`, `puzzle_answers`, `puzzle_group_map` FROM `puzzles` WHERE `puzzle_id` = ?";
		result = [db executeQuery:puzzleQuery, [NSNumber numberWithInt:puzzleId]];
	} else {
		// Get total puzzle count.
		NSInteger totalPuzzles = 0;
		
		NSString *totalPuzzleQuery = @"SELECT count(1) AS `count` FROM `puzzles` WHERE `puzzle_type` = ? AND `puzzle_size` = ? AND `puzzle_difficulty` = ?";
		FMResultSet *totalPuzzlesResult = [db executeQuery:totalPuzzleQuery, [NSNumber numberWithInt:type], [NSNumber numberWithInt:size], [NSNumber numberWithInt:difficulty]];
		
		if ([totalPuzzlesResult next]) {
			totalPuzzles = [totalPuzzlesResult intForColumn:@"count"];
		}
		
		[totalPuzzlesResult close];
		
		assert(totalPuzzles);
		
		// TODO: Randomize better. Right now, the cache will pick a random starting point but will use the next 10 sequential puzzles from that point.
		
		// Pick a random puzzle from the remaining total.
		NSInteger puzzleNumber = arc4random() % totalPuzzles;
		
		NSString *puzzleQuery = @"SELECT `puzzle_id`, `puzzle_guesses`, `puzzle_answers`, `puzzle_group_map` FROM `puzzles` WHERE `puzzle_type` = ? AND `puzzle_size` = ? AND `puzzle_difficulty` = ? LIMIT ?, ?";
		result = [db executeQuery:puzzleQuery, [NSNumber numberWithInt:type], [NSNumber numberWithInt:size], [NSNumber numberWithInt:difficulty], [NSNumber numberWithInt:puzzleNumber], [NSNumber numberWithInt:howMany]];
	}
	
	// Load the puzzle row into a dictionary.
	while ([result next]) {
		NSMutableDictionary *puzzleDefinition = [NSMutableDictionary dictionary];
		
		[puzzleDefinition setObject:[NSNumber numberWithInt:[result intForColumn:@"puzzle_id"]] forKey:kDBPuzzleDefinitionIdKey];
		[puzzleDefinition setObject:[result stringForColumn:@"puzzle_guesses"] forKey:kDBPuzzleDefinitionGuessesKey];
		[puzzleDefinition setObject:[result stringForColumn:@"puzzle_answers"] forKey:kDBPuzzleDefinitionAnswersKey];
		[puzzleDefinition setObject:[result stringForColumn:@"puzzle_group_map"] forKey:kDBPuzzleDefinitionGroupMapKey];
		
		[puzzleDefinition setObject:[NSNumber numberWithInt:type] forKey:kDBPuzzleDefinitionTypeKey];
		[puzzleDefinition setObject:[NSNumber numberWithInt:size] forKey:kDBPuzzleDefinitionSizeKey];
		[puzzleDefinition setObject:[NSNumber numberWithInt:difficulty] forKey:kDBPuzzleDefinitionDifficultyKey];
		
		[puzzles addObject:puzzleDefinition];
	}
	
	[result close];
	
	assert(puzzles.count);
	
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

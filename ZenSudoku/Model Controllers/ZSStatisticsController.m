//
//  ZSStatisticsController.m
//  ZenSudoku
//
//  Created by Brent Traut on 1/15/12.
//  Copyright 2012 Ten Four Software, LLC. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://blog.mugunthkumar.com)
//  More information about this template on the post http://mk.sg/89	
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import "ZSStatisticsController.h"
#import "ZSAppDelegate.h"

NSString * const kStatsFileName = @"Stats.plist";

// Dictionary Representation Keys:
// Games
NSString * const kTotalStartedGamesKey = @"kTotalStartedGamesKey";
NSString * const kTotalSolvedGamesKey = @"kTotalSolvedGamesKey";

NSString * const kGamesSolvedPerEasyKey = @"kGamesSolvedPerEasyKey";
NSString * const kGamesSolvedPerModerateKey = @"kGamesSolvedPerModerateKey";
NSString * const kGamesSolvedPerChallengingKey = @"kGamesSolvedPerChallengingKey";
NSString * const kGamesSolvedPerDiabolicalKey = @"kGamesSolvedPerDiabolicalKey";
NSString * const kGamesSolvedPerInsaneKey = @"kGamesSolvedPerInsaneKey";

// Answers
NSString * const kTotalEnteredAnswersKey = @"kTotalEnteredAnswersKey";
NSString * const kTotalStrikesKey = @"kTotalStrikesKey";
NSString * const kTotalUndosKey = @"kTotalUndosKey";
NSString * const kTotalRedosKey = @"kTotalRedosKey";
NSString * const kTotalHintsKey = @"kTotalHintsKey";

// Time
NSString * const kTotalTimePlayedKey = @"kTotalTimePlayedKey";

NSString * const kTotalTimePlayedPerEasyKey = @"kTotalTimePlayedPerEasyKey";
NSString * const kTotalTimePlayedPerModerateKey = @"kTotalTimePlayedPerModerateKey";
NSString * const kTotalTimePlayedPerChallengingKey = @"kTotalTimePlayedPerChallengingKey";
NSString * const kTotalTimePlayedPerDiabolicalKey = @"kTotalTimePlayedPerDiabolicalKey";
NSString * const kTotalTimePlayedPerInsaneKey = @"kTotalTimePlayedPerInsaneKey";

NSString * const kFastestGamePerEasyKey = @"kFastestGamePerEasyKey";
NSString * const kFastestGamePerModerateKey = @"kFastestGamePerModerateKey";
NSString * const kFastestGamePerChallengingKey = @"kFastestGamePerChallengingKey";
NSString * const kFastestGamePerDiabolicalKey = @"kFastestGamePerDiabolicalKey";
NSString * const kFastestGamePerInsaneKey = @"kFastestGamePerInsaneKey";


@implementation ZSStatisticsController

@synthesize totalStartedGames, totalSolvedGames, gamesSolvedPerEasy, gamesSolvedPerModerate, gamesSolvedPerChallenging, gamesSolvedPerDiabolical, gamesSolvedPerInsane;
@synthesize totalEnteredAnswers, totalStrikes, totalUndos, totalRedos, totalHints;
@synthesize totalTimePlayed, totalTimePlayedPerEasy, totalTimePlayedPerModerate, totalTimePlayedPerChallenging, totalTimePlayedPerDiabolical, totalTimePlayedPerInsane;
@synthesize fastestGamePerEasy, fastestGamePerModerate, fastestGamePerChallenging, fastestGamePerDiabolical, fastestGamePerInsane;
@synthesize lastGameWasTimeRecord;

- (id)init {
	self = [super init];
	
	if (self) {
		if ([self statsFileExists]) {
			[self loadStats];
		} else {
			[self resetStats];
			[self saveStats];
		}
	}
	
	return self;
}

- (void)resetStats {
	// Games
	totalStartedGames = 0;
	totalSolvedGames = 0;
	
	gamesSolvedPerEasy = 0;
	gamesSolvedPerModerate = 0;
	gamesSolvedPerChallenging = 0;
	gamesSolvedPerDiabolical = 0;
	gamesSolvedPerInsane = 0;
	
	// Answers
	totalEnteredAnswers = 0;
	totalStrikes = 0;
	totalUndos = 0;
	totalRedos = 0;
	totalHints = 0;
	
	// Time
	totalTimePlayed = 0;
	
	totalTimePlayedPerEasy = 0;
	totalTimePlayedPerModerate = 0;
	totalTimePlayedPerChallenging = 0;
	totalTimePlayedPerDiabolical = 0;
	totalTimePlayedPerInsane = 0;
	
	fastestGamePerEasy = 0;
	fastestGamePerModerate = 0;
	fastestGamePerChallenging = 0;
	fastestGamePerDiabolical = 0;
	fastestGamePerInsane = 0;
}

#pragma mark Dictionary Representation

- (void)initWithDictionaryRepresentation:(NSDictionary *)dict {
	// Games
	totalStartedGames = [[dict objectForKey:kTotalStartedGamesKey] intValue];
	totalSolvedGames = [[dict objectForKey:kTotalSolvedGamesKey] intValue];
	
	gamesSolvedPerEasy = [[dict objectForKey:kGamesSolvedPerEasyKey] intValue];
	gamesSolvedPerModerate = [[dict objectForKey:kGamesSolvedPerModerateKey] intValue];
	gamesSolvedPerChallenging = [[dict objectForKey:kGamesSolvedPerChallengingKey] intValue];
	gamesSolvedPerDiabolical = [[dict objectForKey:kGamesSolvedPerDiabolicalKey] intValue];
	gamesSolvedPerInsane = [[dict objectForKey:kGamesSolvedPerInsaneKey] intValue];
	
	// Answers
	totalEnteredAnswers = [[dict objectForKey:kTotalEnteredAnswersKey] intValue];
	totalStrikes = [[dict objectForKey:kTotalStrikesKey] intValue];
	totalUndos = [[dict objectForKey:kTotalUndosKey] intValue];
	totalRedos = [[dict objectForKey:kTotalRedosKey] intValue];
	totalHints = [[dict objectForKey:kTotalHintsKey] intValue];
	
	// Time
	totalTimePlayed = [[dict objectForKey:kTotalTimePlayedKey] intValue];
	
	totalTimePlayedPerEasy = [[dict objectForKey:kTotalTimePlayedPerEasyKey] intValue];
	totalTimePlayedPerModerate = [[dict objectForKey:kTotalTimePlayedPerModerateKey] intValue];
	totalTimePlayedPerChallenging = [[dict objectForKey:kTotalTimePlayedPerChallengingKey] intValue];
	totalTimePlayedPerDiabolical = [[dict objectForKey:kTotalTimePlayedPerDiabolicalKey] intValue];
	totalTimePlayedPerInsane = [[dict objectForKey:kTotalTimePlayedPerInsaneKey] intValue];
	
	fastestGamePerEasy = [[dict objectForKey:kFastestGamePerEasyKey] intValue];
	fastestGamePerModerate = [[dict objectForKey:kFastestGamePerModerateKey] intValue];
	fastestGamePerChallenging = [[dict objectForKey:kFastestGamePerChallengingKey] intValue];
	fastestGamePerDiabolical = [[dict objectForKey:kFastestGamePerDiabolicalKey] intValue];
	fastestGamePerInsane = [[dict objectForKey:kFastestGamePerInsaneKey] intValue];
}

- (NSDictionary *)getDictionaryRepresentation {
	// Games
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObject:[NSNumber numberWithInteger:totalStartedGames] forKey:kTotalStartedGamesKey];
	[dict setObject:[NSNumber numberWithInteger:totalSolvedGames] forKey:kTotalSolvedGamesKey];
	
	[dict setObject:[NSNumber numberWithInteger:gamesSolvedPerEasy] forKey:kGamesSolvedPerEasyKey];
	[dict setObject:[NSNumber numberWithInteger:gamesSolvedPerModerate] forKey:kGamesSolvedPerModerateKey];
	[dict setObject:[NSNumber numberWithInteger:gamesSolvedPerChallenging] forKey:kGamesSolvedPerChallengingKey];
	[dict setObject:[NSNumber numberWithInteger:gamesSolvedPerDiabolical] forKey:kGamesSolvedPerDiabolicalKey];
	[dict setObject:[NSNumber numberWithInteger:gamesSolvedPerInsane] forKey:kGamesSolvedPerInsaneKey];
	
	// Answers
	[dict setObject:[NSNumber numberWithInteger:totalEnteredAnswers] forKey:kTotalEnteredAnswersKey];
	[dict setObject:[NSNumber numberWithInteger:totalStrikes] forKey:kTotalStrikesKey];
	[dict setObject:[NSNumber numberWithInteger:totalUndos] forKey:kTotalUndosKey];
	[dict setObject:[NSNumber numberWithInteger:totalRedos] forKey:kTotalRedosKey];
	[dict setObject:[NSNumber numberWithInteger:totalHints] forKey:kTotalHintsKey];
	
	// Time
	[dict setObject:[NSNumber numberWithInteger:totalTimePlayed] forKey:kTotalTimePlayedKey];
	
	[dict setObject:[NSNumber numberWithInteger:totalTimePlayedPerEasy] forKey:kTotalTimePlayedPerEasyKey];
	[dict setObject:[NSNumber numberWithInteger:totalTimePlayedPerModerate] forKey:kTotalTimePlayedPerModerateKey];
	[dict setObject:[NSNumber numberWithInteger:totalTimePlayedPerChallenging] forKey:kTotalTimePlayedPerChallengingKey];
	[dict setObject:[NSNumber numberWithInteger:totalTimePlayedPerDiabolical] forKey:kTotalTimePlayedPerDiabolicalKey];
	[dict setObject:[NSNumber numberWithInteger:totalTimePlayedPerInsane] forKey:kTotalTimePlayedPerInsaneKey];
	
	[dict setObject:[NSNumber numberWithInteger:fastestGamePerEasy] forKey:kFastestGamePerEasyKey];
	[dict setObject:[NSNumber numberWithInteger:fastestGamePerModerate] forKey:kFastestGamePerModerateKey];
	[dict setObject:[NSNumber numberWithInteger:fastestGamePerChallenging] forKey:kFastestGamePerChallengingKey];
	[dict setObject:[NSNumber numberWithInteger:fastestGamePerDiabolical] forKey:kFastestGamePerDiabolicalKey];
	[dict setObject:[NSNumber numberWithInteger:fastestGamePerInsane] forKey:kFastestGamePerInsaneKey];
	
	return dict;
}

#pragma mark Game Events

- (void)gameStartedWithDifficulty:(ZSGameDifficulty)difficulty {
	++totalStartedGames;
}

- (void)gameSolvedWithDifficulty:(ZSGameDifficulty)difficulty totalTime:(NSInteger)seconds {
	// Total Solved Games
	++totalSolvedGames;
	
	// Total Solved Per Difficulty
	switch (difficulty) {
		case ZSGameDifficultyEasy: ++gamesSolvedPerEasy; break;
		case ZSGameDifficultyModerate: ++gamesSolvedPerModerate; break;
		case ZSGameDifficultyChallenging: ++gamesSolvedPerChallenging; break;
		case ZSGameDifficultyDiabolical: ++gamesSolvedPerDiabolical; break;
		case ZSGameDifficultyInsane: ++gamesSolvedPerInsane; break;
	}
	
	NSInteger totalSolvedPerDifficulty = 0;
	
	switch (difficulty) {
		case ZSGameDifficultyEasy: totalSolvedPerDifficulty = gamesSolvedPerEasy; break;
		case ZSGameDifficultyModerate: totalSolvedPerDifficulty = gamesSolvedPerModerate; break;
		case ZSGameDifficultyChallenging: totalSolvedPerDifficulty = gamesSolvedPerChallenging; break;
		case ZSGameDifficultyDiabolical: totalSolvedPerDifficulty = gamesSolvedPerDiabolical; break;
		case ZSGameDifficultyInsane: totalSolvedPerDifficulty = gamesSolvedPerInsane; break;
	}
	
	// Fastest Solved Per Difficulty
	NSInteger fastestGameTimePerDifficulty = 0;
	
	switch (difficulty) {
		case ZSGameDifficultyEasy: fastestGameTimePerDifficulty = fastestGamePerEasy; break;
		case ZSGameDifficultyModerate: fastestGameTimePerDifficulty = fastestGamePerModerate; break;
		case ZSGameDifficultyChallenging: fastestGameTimePerDifficulty = fastestGamePerChallenging; break;
		case ZSGameDifficultyDiabolical: fastestGameTimePerDifficulty = fastestGamePerDiabolical; break;
		case ZSGameDifficultyInsane: fastestGameTimePerDifficulty = fastestGamePerInsane; break;
	}
	
	if (seconds < fastestGameTimePerDifficulty || totalSolvedPerDifficulty == 1) {
		switch (difficulty) {
			case ZSGameDifficultyEasy: fastestGamePerEasy = seconds; break;
			case ZSGameDifficultyModerate: fastestGamePerModerate = seconds; break;
			case ZSGameDifficultyChallenging: fastestGamePerChallenging = seconds; break;
			case ZSGameDifficultyDiabolical: fastestGamePerDiabolical = seconds; break;
			case ZSGameDifficultyInsane: fastestGamePerInsane = seconds; break;
		}
		
		lastGameWasTimeRecord = YES;
	} else {
		lastGameWasTimeRecord = NO;
	}
}

- (void)answerEntered {
	++totalEnteredAnswers;
}

- (void)strikeEntered {
	++totalStrikes;
}

- (void)userUsedUndo {
	++totalUndos;
}

- (void)userUsedRedo {
	++totalRedos;
}

- (void)userUsedHint {
	++totalHints;
}

- (void)timeElapsed:(NSInteger)seconds inGameWithDifficulty:(ZSGameDifficulty)difficulty {
	totalTimePlayed += seconds;
	
	switch (difficulty) {
		case ZSGameDifficultyEasy: totalTimePlayedPerEasy += seconds; break;
		case ZSGameDifficultyModerate: totalTimePlayedPerModerate += seconds; break;
		case ZSGameDifficultyChallenging: totalTimePlayedPerChallenging += seconds; break;
		case ZSGameDifficultyDiabolical: totalTimePlayedPerDiabolical += seconds; break;
		case ZSGameDifficultyInsane: totalTimePlayedPerInsane += seconds; break;
	}
}

#pragma mark File Management

- (BOOL)statsFileExists {
	ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *statsFilePath = [appDelegate getPathForFileName:kStatsFileName];
	return [[NSFileManager defaultManager] fileExistsAtPath:statsFilePath];
}

- (void)loadStats {
	ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *statsFilePath = [appDelegate getPathForFileName:kStatsFileName];
	
	NSDictionary *dictionaryRepresentation = [[NSDictionary alloc] initWithContentsOfFile:statsFilePath];
	[self initWithDictionaryRepresentation:dictionaryRepresentation];
}

- (void)saveStats {
	ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *statsFilePath = [appDelegate getPathForFileName:kStatsFileName];
	
	NSDictionary *dictionaryRepresentation = [self getDictionaryRepresentation];
	[dictionaryRepresentation writeToFile:statsFilePath atomically:YES];
}

- (void)clearStats {
	ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *statsFilePath = [appDelegate getPathForFileName:kStatsFileName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:statsFilePath error:NULL];
}

#pragma mark Singleton Methods

+ (id)sharedInstance {
	static ZSStatisticsController *_sharedInstance;
	
	if (!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
		});
	}
	
	return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
	return self;	
}

@end

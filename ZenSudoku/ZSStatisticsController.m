//
//  ZSStatisticsController.m
//  ZenSudoku
//
//  Created by Brent Traut on 1/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
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
@synthesize totalEnteredAnswers, totalStrikes, totalUndos, totalRedos;
@synthesize totalTimePlayed, totalTimePlayedPerEasy, totalTimePlayedPerModerate, totalTimePlayedPerChallenging, totalTimePlayedPerDiabolical, totalTimePlayedPerInsane;
@synthesize fastestGamePerEasy, fastestGamePerModerate, fastestGamePerChallenging, fastestGamePerDiabolical, fastestGamePerInsane;

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
	
	[dict setObject:[NSNumber numberWithInt:totalStartedGames] forKey:kTotalStartedGamesKey];
	[dict setObject:[NSNumber numberWithInt:totalSolvedGames] forKey:kTotalSolvedGamesKey];
	
	[dict setObject:[NSNumber numberWithInt:gamesSolvedPerEasy] forKey:kGamesSolvedPerEasyKey];
	[dict setObject:[NSNumber numberWithInt:gamesSolvedPerModerate] forKey:kGamesSolvedPerModerateKey];
	[dict setObject:[NSNumber numberWithInt:gamesSolvedPerChallenging] forKey:kGamesSolvedPerChallengingKey];
	[dict setObject:[NSNumber numberWithInt:gamesSolvedPerDiabolical] forKey:kGamesSolvedPerDiabolicalKey];
	[dict setObject:[NSNumber numberWithInt:gamesSolvedPerInsane] forKey:kGamesSolvedPerInsaneKey];
	
	// Answers
	[dict setObject:[NSNumber numberWithInt:totalEnteredAnswers] forKey:kTotalEnteredAnswersKey];
	[dict setObject:[NSNumber numberWithInt:totalStrikes] forKey:kTotalStrikesKey];
	[dict setObject:[NSNumber numberWithInt:totalUndos] forKey:kTotalUndosKey];
	[dict setObject:[NSNumber numberWithInt:totalRedos] forKey:kTotalRedosKey];
	
	// Time
	[dict setObject:[NSNumber numberWithInt:totalTimePlayed] forKey:kTotalTimePlayedKey];
	
	[dict setObject:[NSNumber numberWithInt:totalTimePlayedPerEasy] forKey:kTotalTimePlayedPerEasyKey];
	[dict setObject:[NSNumber numberWithInt:totalTimePlayedPerModerate] forKey:kTotalTimePlayedPerModerateKey];
	[dict setObject:[NSNumber numberWithInt:totalTimePlayedPerChallenging] forKey:kTotalTimePlayedPerChallengingKey];
	[dict setObject:[NSNumber numberWithInt:totalTimePlayedPerDiabolical] forKey:kTotalTimePlayedPerDiabolicalKey];
	[dict setObject:[NSNumber numberWithInt:totalTimePlayedPerInsane] forKey:kTotalTimePlayedPerInsaneKey];
	
	[dict setObject:[NSNumber numberWithInt:fastestGamePerEasy] forKey:kFastestGamePerEasyKey];
	[dict setObject:[NSNumber numberWithInt:fastestGamePerModerate] forKey:kFastestGamePerModerateKey];
	[dict setObject:[NSNumber numberWithInt:fastestGamePerChallenging] forKey:kFastestGamePerChallengingKey];
	[dict setObject:[NSNumber numberWithInt:fastestGamePerDiabolical] forKey:kFastestGamePerDiabolicalKey];
	[dict setObject:[NSNumber numberWithInt:fastestGamePerInsane] forKey:kFastestGamePerInsaneKey];
	
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
	
	// Fastest Solved Per Difficulty
	NSInteger *fastestGameTimePtr = nil;
	
	switch (difficulty) {
		case ZSGameDifficultyEasy: fastestGameTimePtr = &fastestGamePerEasy; break;
		case ZSGameDifficultyModerate: fastestGameTimePtr = &fastestGamePerModerate; break;
		case ZSGameDifficultyChallenging: fastestGameTimePtr = &fastestGamePerChallenging; break;
		case ZSGameDifficultyDiabolical: fastestGameTimePtr = &fastestGamePerDiabolical; break;
		case ZSGameDifficultyInsane: fastestGameTimePtr = &fastestGamePerInsane; break;
	}
	
	if (seconds < *fastestGameTimePtr) {
		++(*fastestGameTimePtr);
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

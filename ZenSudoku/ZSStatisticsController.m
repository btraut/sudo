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
NSString * const kGamesSolvedPerMediumKey = @"kGamesSolvedPerMediumKey";
NSString * const kGamesSolvedPerHardKey = @"kGamesSolvedPerHardKey";
NSString * const kGamesSolvedPerExpertKey = @"kGamesSolvedPerExpertKey";

// Answers
NSString * const kTotalEnteredAnswersKey = @"kTotalEnteredAnswersKey";
NSString * const kTotalStrikesKey = @"kTotalStrikesKey";
NSString * const kTotalUndosKey = @"kTotalUndosKey";
NSString * const kTotalRedosKey = @"kTotalRedosKey";

// Time
NSString * const kTotalTimePlayedKey = @"kTotalTimePlayedKey";

NSString * const kTotalTimePlayedPerEasyKey = @"kTotalTimePlayedPerEasyKey";
NSString * const kTotalTimePlayedPerMediumKey = @"kTotalTimePlayedPerMediumKey";
NSString * const kTotalTimePlayedPerHardKey = @"kTotalTimePlayedPerHardKey";
NSString * const kTotalTimePlayedPerExpertKey = @"kTotalTimePlayedPerExpertKey";

NSString * const kFastestGamePerEasyKey = @"kFastestGamePerEasyKey";
NSString * const kFastestGamePerMediumKey = @"kFastestGamePerMediumKey";
NSString * const kFastestGamePerHardKey = @"kFastestGamePerHardKey";
NSString * const kFastestGamePerExpertKey = @"kFastestGamePerExpertKey";


@implementation ZSStatisticsController

@synthesize totalStartedGames, totalSolvedGames, gamesSolvedPerEasy, gamesSolvedPerMedium, gamesSolvedPerHard, gamesSolvedPerExpert;
@synthesize totalEnteredAnswers, totalStrikes, totalUndos, totalRedos;
@synthesize totalTimePlayed, totalTimePlayedPerEasy, totalTimePlayedPerMedium, totalTimePlayedPerHard, totalTimePlayedPerExpert;
@synthesize fastestGamePerEasy, fastestGamePerMedium, fastestGamePerHard, fastestGamePerExpert;

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
	gamesSolvedPerMedium = 0;
	gamesSolvedPerHard = 0;
	gamesSolvedPerExpert = 0;
	
	// Answers
	totalEnteredAnswers = 0;
	totalStrikes = 0;
	totalUndos = 0;
	totalRedos = 0;
	
	// Time
	totalTimePlayed = 0;
	
	totalTimePlayedPerEasy = 0;
	totalTimePlayedPerMedium = 0;
	totalTimePlayedPerHard = 0;
	totalTimePlayedPerExpert = 0;
	
	fastestGamePerEasy = 0;
	fastestGamePerMedium = 0;
	fastestGamePerHard = 0;
	fastestGamePerExpert = 0;
}

#pragma mark Dictionary Representation

- (void)initWithDictionaryRepresentation:(NSDictionary *)dict {
	// Games
	totalStartedGames = [[dict objectForKey:kTotalStartedGamesKey] intValue];
	totalSolvedGames = [[dict objectForKey:kTotalSolvedGamesKey] intValue];
	
	gamesSolvedPerEasy = [[dict objectForKey:kGamesSolvedPerEasyKey] intValue];
	gamesSolvedPerMedium = [[dict objectForKey:kGamesSolvedPerMediumKey] intValue];
	gamesSolvedPerHard = [[dict objectForKey:kGamesSolvedPerHardKey] intValue];
	gamesSolvedPerExpert = [[dict objectForKey:kGamesSolvedPerExpertKey] intValue];
	
	// Answers
	totalEnteredAnswers = [[dict objectForKey:kTotalEnteredAnswersKey] intValue];
	totalStrikes = [[dict objectForKey:kTotalStrikesKey] intValue];
	totalUndos = [[dict objectForKey:kTotalUndosKey] intValue];
	totalRedos = [[dict objectForKey:kTotalRedosKey] intValue];
	
	// Time
	totalTimePlayed = [[dict objectForKey:kTotalTimePlayedKey] intValue];
	
	totalTimePlayedPerEasy = [[dict objectForKey:kTotalTimePlayedPerEasyKey] intValue];
	totalTimePlayedPerMedium = [[dict objectForKey:kTotalTimePlayedPerMediumKey] intValue];
	totalTimePlayedPerHard = [[dict objectForKey:kTotalTimePlayedPerHardKey] intValue];
	totalTimePlayedPerExpert = [[dict objectForKey:kTotalTimePlayedPerExpertKey] intValue];
	
	fastestGamePerEasy = [[dict objectForKey:kFastestGamePerEasyKey] intValue];
	fastestGamePerMedium = [[dict objectForKey:kFastestGamePerMediumKey] intValue];
	fastestGamePerHard = [[dict objectForKey:kFastestGamePerHardKey] intValue];
	fastestGamePerExpert = [[dict objectForKey:kFastestGamePerExpertKey] intValue];
}

- (NSDictionary *)getDictionaryRepresentation {
	// Games
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObject:[NSNumber numberWithInt:totalStartedGames] forKey:kTotalStartedGamesKey];
	[dict setObject:[NSNumber numberWithInt:totalSolvedGames] forKey:kTotalSolvedGamesKey];
	
	[dict setObject:[NSNumber numberWithInt:gamesSolvedPerEasy] forKey:kGamesSolvedPerEasyKey];
	[dict setObject:[NSNumber numberWithInt:gamesSolvedPerMedium] forKey:kGamesSolvedPerMediumKey];
	[dict setObject:[NSNumber numberWithInt:gamesSolvedPerHard] forKey:kGamesSolvedPerHardKey];
	[dict setObject:[NSNumber numberWithInt:gamesSolvedPerExpert] forKey:kGamesSolvedPerExpertKey];
	
	// Answers
	[dict setObject:[NSNumber numberWithInt:totalEnteredAnswers] forKey:kTotalEnteredAnswersKey];
	[dict setObject:[NSNumber numberWithInt:totalStrikes] forKey:kTotalStrikesKey];
	[dict setObject:[NSNumber numberWithInt:totalUndos] forKey:kTotalUndosKey];
	[dict setObject:[NSNumber numberWithInt:totalRedos] forKey:kTotalRedosKey];
	
	// Time
	[dict setObject:[NSNumber numberWithInt:totalTimePlayed] forKey:kTotalTimePlayedKey];
	
	[dict setObject:[NSNumber numberWithInt:totalTimePlayedPerEasy] forKey:kTotalTimePlayedPerEasyKey];
	[dict setObject:[NSNumber numberWithInt:totalTimePlayedPerMedium] forKey:kTotalTimePlayedPerMediumKey];
	[dict setObject:[NSNumber numberWithInt:totalTimePlayedPerHard] forKey:kTotalTimePlayedPerHardKey];
	[dict setObject:[NSNumber numberWithInt:totalTimePlayedPerExpert] forKey:kTotalTimePlayedPerExpertKey];
	
	[dict setObject:[NSNumber numberWithInt:fastestGamePerEasy] forKey:kFastestGamePerEasyKey];
	[dict setObject:[NSNumber numberWithInt:fastestGamePerMedium] forKey:kFastestGamePerMediumKey];
	[dict setObject:[NSNumber numberWithInt:fastestGamePerHard] forKey:kFastestGamePerHardKey];
	[dict setObject:[NSNumber numberWithInt:fastestGamePerExpert] forKey:kFastestGamePerExpertKey];
	
	return dict;
}

#pragma mark Game Events

- (void)gameStartedWithDifficulty:(ZSGameDifficulty)difficulty {
	++totalStartedGames;
}

- (void)gameSolvedWithDifficulty:(ZSGameDifficulty)difficulty totalTime:(int)seconds {
	// Total Solved Games
	++totalSolvedGames;
	
	// Total Solved Per Difficulty
	switch (difficulty) {
		case ZSGameDifficultyEasy: ++gamesSolvedPerEasy; break;
		case ZSGameDifficultyMedium: ++gamesSolvedPerMedium; break;
		case ZSGameDifficultyHard: ++gamesSolvedPerHard; break;
		case ZSGameDifficultyExpert: ++gamesSolvedPerExpert; break;
	}
	
	// Fastest Solved Per Difficulty
	int *fastestGameTimePtr = nil;
	
	switch (difficulty) {
		case ZSGameDifficultyEasy: fastestGameTimePtr = &fastestGamePerEasy; break;
		case ZSGameDifficultyMedium: fastestGameTimePtr = &fastestGamePerMedium; break;
		case ZSGameDifficultyHard: fastestGameTimePtr = &fastestGamePerHard; break;
		case ZSGameDifficultyExpert: fastestGameTimePtr = &fastestGamePerExpert; break;
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

- (void)timeElapsed:(int)seconds inGameWithDifficulty:(ZSGameDifficulty)difficulty {
	totalTimePlayed += seconds;
	
	switch (difficulty) {
		case ZSGameDifficultyEasy: totalTimePlayedPerEasy += seconds; break;
		case ZSGameDifficultyMedium: totalTimePlayedPerMedium += seconds; break;
		case ZSGameDifficultyHard: totalTimePlayedPerHard += seconds; break;
		case ZSGameDifficultyExpert: totalTimePlayedPerExpert += seconds; break;
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

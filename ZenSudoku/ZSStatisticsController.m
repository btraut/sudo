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

// Dictionary Representation Keys
NSString * const kTotalStartedGamesKey = @"kTotalStartedGamesKey";
NSString * const kTotalSolvedGamesKey = @"kTotalSolvedGamesKey";
NSString * const kGamesSolvedPerDifficultyKey = @"kGamesSolvedPerDifficultyKey";

NSString * const kTotalEnteredAnswersKey = @"kTotalEnteredAnswersKey";
NSString * const kTotalStrikesKey = @"kTotalStrikesKey";
NSString * const kTotalUndosKey = @"kTotalUndosKey";
NSString * const kTotalRedosKey = @"kTotalRedosKey";

NSString * const kTotalTimePlayedKey = @"kTotalTimePlayedKey";
NSString * const kTotalTimePlayedPerDifficultyKey = @"kTotalTimePlayedPerDifficultyKey";
NSString * const kFastedGamePerDifficultyKey = @"kFastedGamePerDifficultyKey";


@implementation ZSStatisticsController

@synthesize totalStartedGames, totalSolvedGames, gamesSolvedPerDifficulty;
@synthesize totalEnteredAnswers, totalStrikes, totalUndos, totalRedos;
@synthesize totalTimePlayed, totalTimePlayedPerDifficulty, fastestGamePerDifficulty;

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
	totalStartedGames = 0;
	totalSolvedGames = 0;
	
	gamesSolvedPerDifficulty = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInt:0], kGameDifficultyNameEasy,
								[NSNumber numberWithInt:0], kGameDifficultyNameMedium,
								[NSNumber numberWithInt:0], kGameDifficultyNameHard,
								[NSNumber numberWithInt:0], kGameDifficultyNameExpert,
								nil];
	
	// Answers
	totalEnteredAnswers = 0;
	totalStrikes = 0;
	totalUndos = 0;
	totalRedos = 0;
	
	// Time
	totalTimePlayed = 0;
	totalTimePlayedPerDifficulty = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithInt:0], kGameDifficultyNameEasy,
									[NSNumber numberWithInt:0], kGameDifficultyNameMedium,
									[NSNumber numberWithInt:0], kGameDifficultyNameHard,
									[NSNumber numberWithInt:0], kGameDifficultyNameExpert,
									nil];
	fastestGamePerDifficulty = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInt:0], kGameDifficultyNameEasy,
								[NSNumber numberWithInt:0], kGameDifficultyNameMedium,
								[NSNumber numberWithInt:0], kGameDifficultyNameHard,
								[NSNumber numberWithInt:0], kGameDifficultyNameExpert,
								nil];
}

#pragma mark Dictionary Representation

- (void)initWithDictionaryRepresentation:(NSDictionary *)dict {
	// Games
	totalStartedGames = [[dict objectForKey:kTotalStartedGamesKey] intValue];
	totalSolvedGames = [[dict objectForKey:kTotalSolvedGamesKey] intValue];
	
	NSDictionary *tempGamesSolvedPerDifficulty = [dict objectForKey:kGamesSolvedPerDifficultyKey];
	[gamesSolvedPerDifficulty setObject:[NSNumber numberWithInt:[[tempGamesSolvedPerDifficulty objectForKey:kGameDifficultyNameEasy] intValue]] forKey:kGameDifficultyNameEasy];
	[gamesSolvedPerDifficulty setObject:[NSNumber numberWithInt:[[tempGamesSolvedPerDifficulty objectForKey:kGameDifficultyNameMedium] intValue]] forKey:kGameDifficultyNameMedium];
	[gamesSolvedPerDifficulty setObject:[NSNumber numberWithInt:[[tempGamesSolvedPerDifficulty objectForKey:kGameDifficultyNameHard] intValue]] forKey:kGameDifficultyNameHard];
	[gamesSolvedPerDifficulty setObject:[NSNumber numberWithInt:[[tempGamesSolvedPerDifficulty objectForKey:kGameDifficultyNameExpert] intValue]] forKey:kGameDifficultyNameExpert];
	
	// Answers
	totalEnteredAnswers = [[dict objectForKey:kTotalEnteredAnswersKey] intValue];
	totalStrikes = [[dict objectForKey:kTotalStrikesKey] intValue];
	totalUndos = [[dict objectForKey:kTotalUndosKey] intValue];
	totalRedos = [[dict objectForKey:kTotalRedosKey] intValue];
	
	// Time
	totalTimePlayed = [[dict objectForKey:kTotalTimePlayedKey] intValue];
	
	NSDictionary *tempTotalTimePlayedPerDifficulty = [dict objectForKey:kTotalTimePlayedPerDifficultyKey];
	[totalTimePlayedPerDifficulty setObject:[NSNumber numberWithInt:[[tempTotalTimePlayedPerDifficulty objectForKey:kGameDifficultyNameEasy] intValue]] forKey:kGameDifficultyNameEasy];
	[totalTimePlayedPerDifficulty setObject:[NSNumber numberWithInt:[[tempTotalTimePlayedPerDifficulty objectForKey:kGameDifficultyNameMedium] intValue]] forKey:kGameDifficultyNameMedium];
	[totalTimePlayedPerDifficulty setObject:[NSNumber numberWithInt:[[tempTotalTimePlayedPerDifficulty objectForKey:kGameDifficultyNameHard] intValue]] forKey:kGameDifficultyNameHard];
	[totalTimePlayedPerDifficulty setObject:[NSNumber numberWithInt:[[tempTotalTimePlayedPerDifficulty objectForKey:kGameDifficultyNameExpert] intValue]] forKey:kGameDifficultyNameExpert];
	
	NSDictionary *tempFastestGamePerDifficulty = [dict objectForKey:kFastedGamePerDifficultyKey];
	[fastestGamePerDifficulty setObject:[NSNumber numberWithInt:[[tempFastestGamePerDifficulty objectForKey:kGameDifficultyNameEasy] intValue]] forKey:kGameDifficultyNameEasy];
	[fastestGamePerDifficulty setObject:[NSNumber numberWithInt:[[tempFastestGamePerDifficulty objectForKey:kGameDifficultyNameMedium] intValue]] forKey:kGameDifficultyNameMedium];
	[fastestGamePerDifficulty setObject:[NSNumber numberWithInt:[[tempFastestGamePerDifficulty objectForKey:kGameDifficultyNameHard] intValue]] forKey:kGameDifficultyNameHard];
	[fastestGamePerDifficulty setObject:[NSNumber numberWithInt:[[tempFastestGamePerDifficulty objectForKey:kGameDifficultyNameExpert] intValue]] forKey:kGameDifficultyNameExpert];
}

- (NSDictionary *)getDictionaryRepresentation {
	// Games
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setObject:[NSNumber numberWithInt:totalStartedGames] forKey:kTotalStartedGamesKey];
	[dict setObject:[NSNumber numberWithInt:totalSolvedGames] forKey:kTotalSolvedGamesKey];
	
	NSMutableDictionary *tempGamesSolvedPerDifficulty = [NSMutableDictionary dictionaryWithObjectsAndKeys:
														 [NSNumber numberWithInt:[[gamesSolvedPerDifficulty objectForKey:kGameDifficultyNameEasy] intValue]], kGameDifficultyNameEasy,
														 [NSNumber numberWithInt:[[gamesSolvedPerDifficulty objectForKey:kGameDifficultyNameMedium] intValue]], kGameDifficultyNameMedium,
														 [NSNumber numberWithInt:[[gamesSolvedPerDifficulty objectForKey:kGameDifficultyNameHard] intValue]], kGameDifficultyNameHard,
														 [NSNumber numberWithInt:[[gamesSolvedPerDifficulty objectForKey:kGameDifficultyNameExpert] intValue]], kGameDifficultyNameExpert,
														 nil];
	[dict setObject:tempGamesSolvedPerDifficulty forKey:kGamesSolvedPerDifficultyKey];
	
	// Answers
	[dict setObject:[NSNumber numberWithInt:totalEnteredAnswers] forKey:kTotalEnteredAnswersKey];
	[dict setObject:[NSNumber numberWithInt:totalStrikes] forKey:kTotalStrikesKey];
	[dict setObject:[NSNumber numberWithInt:totalUndos] forKey:kTotalUndosKey];
	[dict setObject:[NSNumber numberWithInt:totalRedos] forKey:kTotalRedosKey];
	
	// Time
	[dict setObject:[NSNumber numberWithInt:totalTimePlayed] forKey:kTotalTimePlayedKey];
	
	NSMutableDictionary *tempTotalTimePlayedPerDifficulty = [NSMutableDictionary dictionaryWithObjectsAndKeys:
															 [NSNumber numberWithInt:[[totalTimePlayedPerDifficulty objectForKey:kGameDifficultyNameEasy] intValue]], kGameDifficultyNameEasy,
															 [NSNumber numberWithInt:[[totalTimePlayedPerDifficulty objectForKey:kGameDifficultyNameMedium] intValue]], kGameDifficultyNameMedium,
															 [NSNumber numberWithInt:[[totalTimePlayedPerDifficulty objectForKey:kGameDifficultyNameHard] intValue]], kGameDifficultyNameHard,
															 [NSNumber numberWithInt:[[totalTimePlayedPerDifficulty objectForKey:kGameDifficultyNameExpert] intValue]], kGameDifficultyNameExpert,
															 nil];
	[dict setObject:tempTotalTimePlayedPerDifficulty forKey:kTotalTimePlayedPerDifficultyKey];
	
	NSMutableDictionary *tempFastestGamePerDifficulty = [NSMutableDictionary dictionaryWithObjectsAndKeys:
														 [NSNumber numberWithInt:[[fastestGamePerDifficulty objectForKey:kGameDifficultyNameEasy] intValue]], kGameDifficultyNameEasy,
														 [NSNumber numberWithInt:[[fastestGamePerDifficulty objectForKey:kGameDifficultyNameMedium] intValue]], kGameDifficultyNameMedium,
														 [NSNumber numberWithInt:[[fastestGamePerDifficulty objectForKey:kGameDifficultyNameHard] intValue]], kGameDifficultyNameHard,
														 [NSNumber numberWithInt:[[fastestGamePerDifficulty objectForKey:kGameDifficultyNameExpert] intValue]], kGameDifficultyNameExpert,
														 nil];
	[dict setObject:tempFastestGamePerDifficulty forKey:kFastedGamePerDifficultyKey];
	
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
	NSString *difficultyName;
	
	switch (difficulty) {
		case ZSGameDifficultyEasy:
			difficultyName = [NSString stringWithString:kGameDifficultyNameEasy];
			break;
			
		case ZSGameDifficultyMedium:
			difficultyName = [NSString stringWithString:kGameDifficultyNameMedium];
			break;
			
		case ZSGameDifficultyHard:
			difficultyName = [NSString stringWithString:kGameDifficultyNameHard];
			break;
			
		case ZSGameDifficultyExpert:
			difficultyName = [NSString stringWithString:kGameDifficultyNameExpert];
			break;
	}
	
	NSInteger totalGamesSolvedPerDifficulty = [[gamesSolvedPerDifficulty objectForKey:difficultyName] intValue];
	[gamesSolvedPerDifficulty setObject:[NSNumber numberWithInt:(totalGamesSolvedPerDifficulty + 1)] forKey:difficultyName];
	
	// Fastest Solved Per Difficulty
	NSInteger fastestGame = [[fastestGamePerDifficulty objectForKey:difficultyName] intValue];
	
	if (seconds < fastestGame) {
		[fastestGamePerDifficulty setObject:[NSNumber numberWithInt:seconds] forKey:difficultyName];
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
	
	NSString *difficultyName;
	
	switch (difficulty) {
		case ZSGameDifficultyEasy:
			difficultyName = [NSString stringWithString:kGameDifficultyNameEasy];
			break;
			
		case ZSGameDifficultyMedium:
			difficultyName = [NSString stringWithString:kGameDifficultyNameMedium];
			break;
			
		case ZSGameDifficultyHard:
			difficultyName = [NSString stringWithString:kGameDifficultyNameHard];
			break;
			
		case ZSGameDifficultyExpert:
			difficultyName = [NSString stringWithString:kGameDifficultyNameExpert];
			break;
	}
	
	NSInteger time = [[totalTimePlayedPerDifficulty objectForKey:difficultyName] intValue];
	[gamesSolvedPerDifficulty setObject:[NSNumber numberWithInt:(time + seconds)] forKey:difficultyName];
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

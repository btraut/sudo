//
//  ZSStatisticsController.h
//  ZenSudoku
//
//  Created by Brent Traut on 1/15/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//	File created using Singleton XCode Template by Mugunth Kumar (http://blog.mugunthkumar.com)
//  More information about this template on the post http://mk.sg/89
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above

#import <Foundation/Foundation.h>
#import "ZSGameController.h"

@interface ZSStatisticsController : NSObject {
	// Games
	NSInteger totalStartedGames;
	NSInteger totalSolvedGames;
	NSMutableDictionary *gamesSolvedPerDifficulty;
	
	// Answers
	NSInteger totalEnteredAnswers;
	NSInteger totalStrikes;
	NSInteger totalUndos;
	NSInteger totalRedos;
	
	// Time
	NSInteger totalTimePlayed;
	NSMutableDictionary *totalTimePlayedPerDifficulty;
	NSMutableDictionary *fastestGamePerDifficulty;
}

@property (nonatomic, readonly) NSInteger totalStartedGames;
@property (nonatomic, readonly) NSInteger totalSolvedGames;
@property (nonatomic, strong) NSMutableDictionary *gamesSolvedPerDifficulty;

@property (nonatomic, readonly) NSInteger totalEnteredAnswers;
@property (nonatomic, readonly) NSInteger totalStrikes;
@property (nonatomic, readonly) NSInteger totalUndos;
@property (nonatomic, readonly) NSInteger totalRedos;

@property (nonatomic, readonly) NSInteger totalTimePlayed;
@property (nonatomic, strong) NSMutableDictionary *totalTimePlayedPerDifficulty;
@property (nonatomic, strong) NSMutableDictionary *fastestGamePerDifficulty;

+ (id)sharedInstance;

- (id)init;
- (void)resetStats;

- (void)gameStartedWithDifficulty:(ZSGameDifficulty)difficulty;
- (void)gameSolvedWithDifficulty:(ZSGameDifficulty)difficulty totalTime:(NSInteger)seconds;
- (void)answerEntered;
- (void)strikeEntered;
- (void)userUsedUndo;
- (void)userUsedRedo;
- (void)timeElapsed:(NSInteger)seconds inGameWithDifficulty:(ZSGameDifficulty)difficulty;

- (void)initWithDictionaryRepresentation:(NSDictionary *)dict;
- (NSDictionary *)getDictionaryRepresentation;

- (BOOL)statsFileExists;
- (void)loadStats;
- (void)saveStats;
- (void)clearStats;

@end

extern NSString * const kStatsFileName;

// Dictionary Representation Keys
extern NSString * const kTotalStartedGamesKey;
extern NSString * const kTotalSolvedGamesKey;
extern NSString * const kGamesSolvedPerDifficultyKey;

extern NSString * const kTotalEnteredAnswersKey;
extern NSString * const kTotalStrikesKey;
extern NSString * const kTotalUndosKey;
extern NSString * const kTotalRedosKey;

extern NSString * const kTotalTimePlayedKey;
extern NSString * const kTotalTimePlayedPerDifficultyKey;
extern NSString * const kFastedGamePerDifficultyKey;

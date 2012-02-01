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
	int totalStartedGames;
	int totalSolvedGames;
	
	int gamesSolvedPerEasy;
	int gamesSolvedPerMedium;
	int gamesSolvedPerHard;
	int gamesSolvedPerExpert;
	
	// Answers
	int totalEnteredAnswers;
	int totalStrikes;
	int totalUndos;
	int totalRedos;
	
	// Time
	int totalTimePlayed;
	
	int totalTimePlayedPerEasy;
	int totalTimePlayedPerMedium;
	int totalTimePlayedPerHard;
	int totalTimePlayedPerExpert;
	
	int fastestGamePerEasy;
	int fastestGamePerMedium;
	int fastestGamePerHard;
	int fastestGamePerExpert;
}

// Games
@property (nonatomic, readonly) int totalStartedGames;
@property (nonatomic, readonly) int totalSolvedGames;

@property (nonatomic, readonly) int gamesSolvedPerEasy;
@property (nonatomic, readonly) int gamesSolvedPerMedium;
@property (nonatomic, readonly) int gamesSolvedPerHard;
@property (nonatomic, readonly) int gamesSolvedPerExpert;

// Answers
@property (nonatomic, readonly) int totalEnteredAnswers;
@property (nonatomic, readonly) int totalStrikes;
@property (nonatomic, readonly) int totalUndos;
@property (nonatomic, readonly) int totalRedos;

// Time
@property (nonatomic, readonly) int totalTimePlayed;

@property (nonatomic, readonly) int totalTimePlayedPerEasy;
@property (nonatomic, readonly) int totalTimePlayedPerMedium;
@property (nonatomic, readonly) int totalTimePlayedPerHard;
@property (nonatomic, readonly) int totalTimePlayedPerExpert;

@property (nonatomic, readonly) int fastestGamePerEasy;
@property (nonatomic, readonly) int fastestGamePerMedium;
@property (nonatomic, readonly) int fastestGamePerHard;
@property (nonatomic, readonly) int fastestGamePerExpert;

+ (id)sharedInstance;

- (id)init;
- (void)resetStats;

- (void)gameStartedWithDifficulty:(ZSGameDifficulty)difficulty;
- (void)gameSolvedWithDifficulty:(ZSGameDifficulty)difficulty totalTime:(int)seconds;
- (void)answerEntered;
- (void)strikeEntered;
- (void)userUsedUndo;
- (void)userUsedRedo;
- (void)timeElapsed:(int)seconds inGameWithDifficulty:(ZSGameDifficulty)difficulty;

- (void)initWithDictionaryRepresentation:(NSDictionary *)dict;
- (NSDictionary *)getDictionaryRepresentation;

- (BOOL)statsFileExists;
- (void)loadStats;
- (void)saveStats;
- (void)clearStats;

@end

extern NSString * const kStatsFileName;

// Dictionary Representation Keys:
// Games
extern NSString * const kTotalStartedGamesKey;
extern NSString * const kTotalSolvedGamesKey;

extern NSString * const kGamesSolvedPerEasyKey;
extern NSString * const kGamesSolvedPerMediumKey;
extern NSString * const kGamesSolvedPerHardKey;
extern NSString * const kGamesSolvedPerExpertKey;

// Answers
extern NSString * const kTotalEnteredAnswersKey;
extern NSString * const kTotalStrikesKey;
extern NSString * const kTotalUndosKey;
extern NSString * const kTotalRedosKey;

// Time
extern NSString * const kTotalTimePlayedKey;

extern NSString * const kTotalTimePlayedPerEasyKey;
extern NSString * const kTotalTimePlayedPerMediumKey;
extern NSString * const kTotalTimePlayedPerHardKey;
extern NSString * const kTotalTimePlayedPerExpertKey;

extern NSString * const kFastestGamePerEasyKey;
extern NSString * const kFastestGamePerMediumKey;
extern NSString * const kFastestGamePerHardKey;
extern NSString * const kFastestGamePerExpertKey;

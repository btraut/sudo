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
	
	NSInteger gamesSolvedPerEasy;
	NSInteger gamesSolvedPerMedium;
	NSInteger gamesSolvedPerHard;
	NSInteger gamesSolvedPerExpert;
	
	// Answers
	NSInteger totalEnteredAnswers;
	NSInteger totalStrikes;
	NSInteger totalUndos;
	NSInteger totalRedos;
	
	// Time
	NSInteger totalTimePlayed;
	
	NSInteger totalTimePlayedPerEasy;
	NSInteger totalTimePlayedPerMedium;
	NSInteger totalTimePlayedPerHard;
	NSInteger totalTimePlayedPerExpert;
	
	NSInteger fastestGamePerEasy;
	NSInteger fastestGamePerMedium;
	NSInteger fastestGamePerHard;
	NSInteger fastestGamePerExpert;
}

// Games
@property (nonatomic, readonly) NSInteger totalStartedGames;
@property (nonatomic, readonly) NSInteger totalSolvedGames;

@property (nonatomic, readonly) NSInteger gamesSolvedPerEasy;
@property (nonatomic, readonly) NSInteger gamesSolvedPerMedium;
@property (nonatomic, readonly) NSInteger gamesSolvedPerHard;
@property (nonatomic, readonly) NSInteger gamesSolvedPerExpert;

// Answers
@property (nonatomic, readonly) NSInteger totalEnteredAnswers;
@property (nonatomic, readonly) NSInteger totalStrikes;
@property (nonatomic, readonly) NSInteger totalUndos;
@property (nonatomic, readonly) NSInteger totalRedos;

// Time
@property (nonatomic, readonly) NSInteger totalTimePlayed;

@property (nonatomic, readonly) NSInteger totalTimePlayedPerEasy;
@property (nonatomic, readonly) NSInteger totalTimePlayedPerMedium;
@property (nonatomic, readonly) NSInteger totalTimePlayedPerHard;
@property (nonatomic, readonly) NSInteger totalTimePlayedPerExpert;

@property (nonatomic, readonly) NSInteger fastestGamePerEasy;
@property (nonatomic, readonly) NSInteger fastestGamePerMedium;
@property (nonatomic, readonly) NSInteger fastestGamePerHard;
@property (nonatomic, readonly) NSInteger fastestGamePerExpert;

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

//
//  ZSStatisticsController.h
//  ZenSudoku
//
//  Created by Brent Traut on 1/15/12.
//  Copyright 2012 Ten Four Software, LLC. All rights reserved.
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
	NSInteger gamesSolvedPerModerate;
	NSInteger gamesSolvedPerChallenging;
	NSInteger gamesSolvedPerDiabolical;
	NSInteger gamesSolvedPerInsane;
	
	// Answers
	NSInteger totalEnteredAnswers;
	NSInteger totalStrikes;
	NSInteger totalUndos;
	NSInteger totalRedos;
	
	// Time
	NSInteger totalTimePlayed;
	
	NSInteger totalTimePlayedPerEasy;
	NSInteger totalTimePlayedPerModerate;
	NSInteger totalTimePlayedPerChallenging;
	NSInteger totalTimePlayedPerDiabolical;
	NSInteger totalTimePlayedPerInsane;
	
	NSInteger fastestGamePerEasy;
	NSInteger fastestGamePerModerate;
	NSInteger fastestGamePerChallenging;
	NSInteger fastestGamePerDiabolical;
	NSInteger fastestGamePerInsane;
}

// Games
@property (readonly) NSInteger totalStartedGames;
@property (readonly) NSInteger totalSolvedGames;

@property (readonly) NSInteger gamesSolvedPerEasy;
@property (readonly) NSInteger gamesSolvedPerModerate;
@property (readonly) NSInteger gamesSolvedPerChallenging;
@property (readonly) NSInteger gamesSolvedPerDiabolical;
@property (readonly) NSInteger gamesSolvedPerInsane;

// Answers
@property (readonly) NSInteger totalEnteredAnswers;
@property (readonly) NSInteger totalStrikes;
@property (readonly) NSInteger totalUndos;
@property (readonly) NSInteger totalRedos;
@property (readonly) NSInteger totalHints;

// Time
@property (readonly) NSInteger totalTimePlayed;

@property (readonly) NSInteger totalTimePlayedPerEasy;
@property (readonly) NSInteger totalTimePlayedPerModerate;
@property (readonly) NSInteger totalTimePlayedPerChallenging;
@property (readonly) NSInteger totalTimePlayedPerDiabolical;
@property (readonly) NSInteger totalTimePlayedPerInsane;

@property (readonly) NSInteger fastestGamePerEasy;
@property (readonly) NSInteger fastestGamePerModerate;
@property (readonly) NSInteger fastestGamePerChallenging;
@property (readonly) NSInteger fastestGamePerDiabolical;
@property (readonly) NSInteger fastestGamePerInsane;

@property (readonly) BOOL lastGameWasTimeRecord;

+ (ZSStatisticsController *)sharedInstance;

- (id)init;
- (void)resetStats;

- (void)gameStartedWithDifficulty:(ZSGameDifficulty)difficulty;
- (void)gameSolvedWithDifficulty:(ZSGameDifficulty)difficulty totalTime:(NSInteger)seconds;
- (void)answerEntered;
- (void)strikeEntered;
- (void)userUsedUndo;
- (void)userUsedRedo;
- (void)userUsedHint;
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
extern NSString * const kGamesSolvedPerModerateKey;
extern NSString * const kGamesSolvedPerChallengingKey;
extern NSString * const kGamesSolvedPerDiabolicalKey;
extern NSString * const kGamesSolvedPerInsaneKey;

// Answers
extern NSString * const kTotalEnteredAnswersKey;
extern NSString * const kTotalStrikesKey;
extern NSString * const kTotalUndosKey;
extern NSString * const kTotalRedosKey;

// Time
extern NSString * const kTotalTimePlayedKey;

extern NSString * const kTotalTimePlayedPerEasyKey;
extern NSString * const kTotalTimePlayedPerModerateKey;
extern NSString * const kTotalTimePlayedPerChallengingKey;
extern NSString * const kTotalTimePlayedPerDiabolicalKey;
extern NSString * const kTotalTimePlayedPerInsaneKey;

extern NSString * const kFastestGamePerEasyKey;
extern NSString * const kFastestGamePerModerateKey;
extern NSString * const kFastestGamePerChallengingKey;
extern NSString * const kFastestGamePerInsaneKey;

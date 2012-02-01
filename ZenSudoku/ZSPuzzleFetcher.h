//
//  ZSPuzzleFetcher.h
//  ZenSudoku
//
//  Created by Brent Traut on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSGame.h"

@class FMDatabase;

@interface ZSPuzzleFetcher : NSObject {
	FMDatabase *db;
}

- (ZSGame *)fetchGameWithType:(ZSGameType)type size:(int)size difficulty:(ZSGameDifficulty)difficulty;

- (NSDictionary *)getRandomPuzzleWithType:(ZSGameType)type size:(int)size difficulty:(ZSGameDifficulty)difficulty;

- (ZSGame *)createGameWithDictionary:dict;

@end

extern NSString * const kSQLiteDBFileName;
extern NSString * const kSQLiteDBFileNameResource;
extern NSString * const kSQLiteDBFileNameType;

extern NSString * const kDBPuzzleDefinitionIdKey;
extern NSString * const kDBPuzzleDefinitionTypeKey;
extern NSString * const kDBPuzzleDefinitionSizeKey;
extern NSString * const kDBPuzzleDefinitionDifficultyKey;
extern NSString * const kDBPuzzleDefinitionGuessesKey;
extern NSString * const kDBPuzzleDefinitionAnswersKey;
extern NSString * const kDBPuzzleDefinitionGroupMapKey;

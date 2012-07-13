//
//  ZSPuzzleFetcher.h
//  ZenSudoku
//
//  Created by Brent Traut on 1/23/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSGame.h"

@class FMDatabase;

@interface ZSPuzzleFetcher : NSObject {
	FMDatabase *db;
}

- (NSArray *)fetchGames:(NSInteger)howMany withDifficulty:(ZSGameDifficulty)difficulty;

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

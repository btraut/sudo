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

+ (ZSGame *)fetchGameWithDifficulty:(ZSGameDifficulty)difficulty;

- (ZSGame *)_fetchGameWithDifficulty:(ZSGameDifficulty)difficulty;
- (void)markPuzzleUsed:(NSInteger)puzzleId;

- (NSInteger)getTotalPuzzlesForDifficulty:(ZSGameDifficulty)difficulty;
- (NSInteger)getTotalFreshPuzzlesForDifficulty:(ZSGameDifficulty)difficulty;
- (NSString *)getRandomPuzzleStringForDifficulty:(ZSGameDifficulty)difficulty;

- (ZSGame *)createGameWithDifficulty:(ZSGameDifficulty)difficulty puzzleString:(NSString *)puzzleString;

@end

extern NSString * const kSQLiteDBFileName;


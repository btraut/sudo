//
//  ZSGameGenerator.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGameCalculator.h"
#import "ZSGame.h"

@interface ZSGameGenerator : ZSGameCalculator

- (ZSGame *)generateGameWithDifficulty:(ZSGameDifficulty)difficulty;
- (ZSGame *)generateStandard9x9Game;

- (BOOL)buildPuzzleForX:(NSInteger)x y:(NSInteger)y;

- (void)populateRandomNumberArray:(NSInteger *)array withSize:(NSInteger)arraySize;

@end

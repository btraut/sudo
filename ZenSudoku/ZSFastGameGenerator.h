//
//  ZSFastGameGenerator.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZSGame.h"

@class ZSFastGameBoard;

@interface ZSFastGameGenerator : NSObject {
	@private
	
	ZSFastGameBoard *_reductionGameBoard;
	ZSFastGameBoard *_scratchGameBoard;
}

- (ZSGame *)generateGameWithDifficulty:(ZSGameDifficulty)difficulty;
- (ZSGame *)generateStandard9x9Game;

- (BOOL)buildPuzzleForX:(int)x y:(int)y;

- (void)populateRandomNumberArray:(int *)array withSize:(int)arraySize;

@end

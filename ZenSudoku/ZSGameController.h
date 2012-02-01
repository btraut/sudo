//
//  ZSGameController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSGame.h"

@interface ZSGameController : NSObject {
	ZSGame *currentGame;
}

@property (strong, readonly) ZSGame *currentGame;

+ (ZSGameController *)sharedInstance;

// Game Management
- (void)fetchGameWithDifficulty:(ZSGameDifficulty)difficulty;
- (void)generateGameWithDifficulty:(ZSGameDifficulty)difficulty;
- (void)clearCurrentGame;

// Saved Games
- (BOOL)savedGameInProgress;
- (void)loadSavedGame;
- (void)saveGame;
- (void)clearSavedGame;

// Utilities
+ (int **)alloc2DIntGridWithSize:(int)size;
+ (void)free2DIntGrid:(int **)grid withSize:(int)size;
+ (BOOL ***)alloc3DBoolGridWithSize:(int)size;
+ (void)free3DBoolGrid:(BOOL ***)grid withSize:(int)size;	

@end

extern NSString * const kSavedGameFileName;

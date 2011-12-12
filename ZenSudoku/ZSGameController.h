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

- (void)generateGameWithDifficulty:(ZSGameDifficulty)difficulty;

+ (NSInteger **)alloc2DIntGridWithSize:(NSInteger)size;
+ (void)free2DIntGrid:(NSInteger **)grid withSize:(NSInteger)size;
+ (BOOL ***)alloc3DBoolGridWithSize:(NSInteger)size;
+ (void)free3DBoolGrid:(BOOL ***)grid withSize:(NSInteger)size;	

- (BOOL)savedGameInProgress;
- (void)loadSavedGame;
- (void)saveGame;
- (void)clearSavedGame;

@end

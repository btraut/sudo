//
//  ZSGameController.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSGame.h"

@interface ZSGameController : NSObject

+ (ZSGameController *)sharedInstance;

// Game Management
- (ZSGame *)fetchGameWithDifficulty:(ZSGameDifficulty)difficulty;

// Cache Management
- (void)populateCacheForDifficulty:(ZSGameDifficulty)difficulty synchronous:(BOOL)synchronous;
- (void)populateCacheFromUserDefaults;
- (void)saveCacheToUserDefaults;

// Saved Games
- (BOOL)savedGameInProgress;
- (ZSGame *)loadSavedGame;
- (void)saveGame:(ZSGame *)game;
- (void)clearSavedGame;

// Utilities
+ (NSInteger **)alloc2DIntGridWithSize:(NSInteger)size;
+ (void)free2DIntGrid:(NSInteger **)grid withSize:(NSInteger)size;
+ (BOOL ***)alloc3DBoolGridWithSize:(NSInteger)size;
+ (void)free3DBoolGrid:(BOOL ***)grid withSize:(NSInteger)size;	

@end

extern NSString * const kSavedGameFileName;

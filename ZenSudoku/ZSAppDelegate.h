//
//  ZSAppDelegate.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

- (void)userDidUpgradeVersion;

- (void)setUserDefaults;

- (NSString *)getPathForFileName:(NSString *)filename;

@end

// Test Flight Params

extern NSString * const kTestFlightTeamToken;
extern NSString * const kTestFlightCheckPointStartedNewPuzzle;
extern NSString * const kTestFlightCheckPointSolvedPuzzle;
extern NSString * const kTestFlightCheckPointUsedUndo;
extern NSString * const kTestFlightCheckPointUsedAutoPencil;
extern NSString * const kTestFlightCheckPointUsedAHint;
extern NSString * const kTestFlightCheckPointOpenedRibbon;

// Preference Keys

extern NSString * const kLastUsedVersionKey;

extern NSString * const kDisplayedTutorialNotices;

extern NSString * const kPuzzleCacheKey;

extern NSString * const kLastPlayedPuzzleDifficulty;

extern NSString * const kClearTileSelectionAfterPickingAnswerOptionForAnswerKey;
extern NSString * const kClearTileSelectionAfterPickingAnswerOptionForPencilKey;

extern NSString * const kClearPencilsAfterGuessingKey;

extern NSString * const kShowErrorsOptionKey;
extern NSString * const kRemoveTileAfterErrorKey;

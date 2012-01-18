//
//  ZSAppDelegate.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSMainMenuViewController.h"

@interface ZSAppDelegate : UIResponder <UIApplicationDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

- (void)setUserDefaults;

- (NSString *)getPathForFileName:(NSString *)filename;

@end

// Test Flight Params

extern NSString * const kTestFlightTeamToken;
extern NSString * const kTestFlightCheckPointStartedNewPuzzle;
extern NSString * const kTestFlightCheckPointSolvedPuzzle;
extern NSString * const kTestFlightCheckPointOpenedStatistics;
extern NSString * const kTestFlightCheckPointOpenedSettings;

// Preference Keys

extern NSString * const kTileAnswerOrderKey;

extern NSString * const kClearAnswerOptionSelectionAfterPickingTileForAnswerKey;
extern NSString * const kClearTileSelectionAfterPickingAnswerOptionForAnswerKey;
extern NSString * const kClearAnswerOptionSelectionAfterPickingTileForPencilKey;
extern NSString * const kClearTileSelectionAfterPickingAnswerOptionForPencilKey;

extern NSString * const kClearPencilsAfterGuessingKey;

extern NSString * const kShowErrorsOptionKey;
extern NSString * const kRemoveTileAfterErrorKey;

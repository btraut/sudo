//
//  ZSAppDelegate.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSAppDelegate.h"
#import "ZSMainMenuViewController.h"
#import "ZSGameController.h"
#import "ZSGame.h"

NSString * const kTileAnswerOrderKey = @"kTileAnswerOrderKey";

NSString * const kClearAnswerOptionSelectionAfterPickingTileForAnswerKey = @"kClearAnswerOptionSelectionAfterPickingTileForAnswerKey";
NSString * const kClearTileSelectionAfterPickingAnswerOptionForAnswerKey = @"kClearTileSelectionAfterPickingAnswerOptionForAnswerKey";
NSString * const kClearAnswerOptionSelectionAfterPickingTileForPencilKey = @"kClearAnswerOptionSelectionAfterPickingTileForPencilKey";
NSString * const kClearTileSelectionAfterPickingAnswerOptionForPencilKey = @"kClearTileSelectionAfterPickingAnswerOptionForPencilKey";

NSString * const kClearPencilsAfterGuessingKey = @"kClearPencilsAfterGuessingKey";

NSString * const kShowErrorsOptionKey = @"kShowErrorsOptionKey";
NSString * const kRemoveTileAfterErrorKey = @"kRemoveTileAfterErrorKey";

NSString * const kSavedGameInProgressKey = @"kSavedGameInProgressKey";
NSString * const kSavedGameKey = @"kSavedGameKey";

@implementation ZSAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self.window makeKeyAndVisible];
	
	// Set user defaults.
	[self setUserDefaults];
	
	// If a game was previously in progress, restore it.
	if ([[ZSGameController sharedInstance] savedGameInProgress]) {
		[[ZSGameController sharedInstance] loadSavedGame];
	}
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[ZSGameController sharedInstance] saveGame];
}

- (void)setUserDefaults {
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 
								 [NSNumber numberWithInt:ZSGameTileAnswerOrderTileFirst], kTileAnswerOrderKey,
								 
								 [NSNumber numberWithBool:NO], kClearAnswerOptionSelectionAfterPickingTileForAnswerKey,
								 [NSNumber numberWithBool:NO], kClearTileSelectionAfterPickingAnswerOptionForAnswerKey,
								 [NSNumber numberWithBool:NO], kClearAnswerOptionSelectionAfterPickingTileForPencilKey,
								 [NSNumber numberWithBool:NO], kClearTileSelectionAfterPickingAnswerOptionForPencilKey,
								 
								 [NSNumber numberWithBool:YES], kClearPencilsAfterGuessingKey,
								 
								 [NSNumber numberWithInt:ZSShowErrorsOptionAlways], kShowErrorsOptionKey,
								 [NSNumber numberWithBool:NO], kRemoveTileAfterErrorKey,
								 
								 [NSNumber numberWithBool:NO], kSavedGameInProgressKey,
								 [NSDictionary dictionary], kSavedGameKey,
								 
								 nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];	
}

@end

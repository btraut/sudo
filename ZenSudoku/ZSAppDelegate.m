//
//  ZSAppDelegate.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSAppDelegate.h"
#import "ZSMainMenuViewController.h"
#import "ZSGameBookViewController.h"
#import "ZSGameController.h"
#import "ZSStatisticsController.h"
#import "ZSGame.h"

#import "TestFlight.h"

NSString * const kTestFlightTeamToken = @"b838f7b1003025e596ee5b134d349769_NDgyOTkyMDEyLTAxLTEzIDA1OjAyOjMzLjM4ODA4NA";
NSString * const kTestFlightCheckPointStartedNewPuzzle = @"kTestFlightCheckPointStartedNewPuzzle";
NSString * const kTestFlightCheckPointSolvedPuzzle = @"kTestFlightCheckPointSolvedPuzzle";
NSString * const kTestFlightCheckPointOpenedStatistics = @"kTestFlightCheckPointOpenedStatistics";
NSString * const kTestFlightCheckPointOpenedSettings = @"kTestFlightCheckPointOpenedSettings";

NSString * const kLastUsedVersionKey = @"kLastUsedVersionKey";

NSString * const kTileAnswerOrderKey = @"kTileAnswerOrderKey";

NSString * const kClearAnswerOptionSelectionAfterPickingTileForAnswerKey = @"kClearAnswerOptionSelectionAfterPickingTileForAnswerKey";
NSString * const kClearTileSelectionAfterPickingAnswerOptionForAnswerKey = @"kClearTileSelectionAfterPickingAnswerOptionForAnswerKey";
NSString * const kClearAnswerOptionSelectionAfterPickingTileForPencilKey = @"kClearAnswerOptionSelectionAfterPickingTileForPencilKey";
NSString * const kClearTileSelectionAfterPickingAnswerOptionForPencilKey = @"kClearTileSelectionAfterPickingAnswerOptionForPencilKey";

NSString * const kClearPencilsAfterGuessingKey = @"kClearPencilsAfterGuessingKey";

NSString * const kShowErrorsOptionKey = @"kShowErrorsOptionKey";
NSString * const kRemoveTileAfterErrorKey = @"kRemoveTileAfterErrorKey";

@implementation ZSAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Tell TestFlight that we used the app.
	[TestFlight takeOff:kTestFlightTeamToken];
	
	// Set user defaults.
	[self setUserDefaults];
	
	// If a game was previously in progress, restore it.
	if ([[ZSGameController sharedInstance] savedGameInProgress]) {
//		[[ZSGameController sharedInstance] loadSavedGame];
	}
	
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	ZSGameBookViewController *gameBookViewController = [[ZSGameBookViewController alloc] init];
	
	_window.rootViewController = gameBookViewController;
	[_window makeKeyAndVisible];
	
	// If the user has upgraded the game since last launch, the game may need to do stuff.
	NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	if (![[[NSUserDefaults standardUserDefaults] stringForKey:kLastUsedVersionKey] isEqualToString:currentVersion]) {
		[self userDidUpgradeVersion];
	}
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[ZSGameController sharedInstance] saveGame];
	[[ZSStatisticsController sharedInstance] saveStats];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// [[ZSGameController sharedInstance] saveGame];
}

- (void)userDidUpgradeVersion {
	// Get the new version and save it back into the user defaults.
	NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	[[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kLastUsedVersionKey];
	
	// Reset settings.
	[NSUserDefaults resetStandardUserDefaults];
	
	// Debug - clear stats and re-save.
	[[ZSStatisticsController sharedInstance] resetStats];
	[[ZSStatisticsController sharedInstance] saveStats];
}

- (void)setUserDefaults {
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 
								 [NSNumber numberWithBool:NO], kClearAnswerOptionSelectionAfterPickingTileForAnswerKey,
								 [NSNumber numberWithBool:NO], kClearTileSelectionAfterPickingAnswerOptionForAnswerKey,
								 [NSNumber numberWithBool:NO], kClearAnswerOptionSelectionAfterPickingTileForPencilKey,
								 [NSNumber numberWithBool:NO], kClearTileSelectionAfterPickingAnswerOptionForPencilKey,
								 
								 [NSNumber numberWithInt:ZSGameTileAnswerOrderTileFirst], kTileAnswerOrderKey,
								 
								 [NSNumber numberWithBool:YES], kClearPencilsAfterGuessingKey,
								 
								 [NSNumber numberWithInt:ZSShowErrorsOptionLogical], kShowErrorsOptionKey,
								 [NSNumber numberWithBool:NO], kRemoveTileAfterErrorKey,
								 
								 nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];	
}

- (NSString *)getPathForFileName:(NSString *)filename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:filename];
}

@end

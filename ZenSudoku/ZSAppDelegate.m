//
//  ZSAppDelegate.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSAppDelegate.h"
#import "ZSGameBookViewController.h"
#import "ZSGameController.h"
#import "ZSStatisticsController.h"
#import "ZSGame.h"

#import "Flurry.h"
#import "FlurryAds.h"

NSString * const kFlurryAPIKey = @"RKJTR5RVTPM98RTJ4GPH";

NSString * const kAnalyticsCheckpointStartedNewPuzzle = @"kAnalyticsCheckpointStartedNewPuzzle";
NSString * const kAnalyticsCheckpointSolvedPuzzle = @"kAnalyticsCheckpointSolvedPuzzle";
NSString * const kAnalyticsCheckpointUsedUndo = @"kAnalyticsCheckpointUsedUndo";
NSString * const kAnalyticsCheckpointUsedAutoPencil = @"kAnalyticsCheckpointUsedAutoPencil";
NSString * const kAnalyticsCheckpointUsedAHint = @"kAnalyticsCheckpointUsedAHint";
NSString * const kAnalyticsCheckpointNoHintAvailable = @"kAnalyticsCheckpointNoHintAvailable";
NSString * const kAnalyticsCheckpointOpenedRibbon = @"kAnalyticsCheckpointOpenedRibbon";

NSString * const kLastUsedVersionKey = @"kLastUsedVersionKey";

NSString * const kDisplayedTutorialNotices = @"kDisplayedTutorialNotices";

NSString * const kPuzzleCacheKey = @"kPuzzleCacheKey";

NSString * const kLastPlayedPuzzleDifficulty = @"kLastPlayedPuzzleDifficulty";

NSString * const kClearTileSelectionAfterPickingAnswerOptionForAnswerKey = @"kClearTileSelectionAfterPickingAnswerOptionForAnswerKey";
NSString * const kClearTileSelectionAfterPickingAnswerOptionForPencilKey = @"kClearTileSelectionAfterPickingAnswerOptionForPencilKey";

NSString * const kClearPencilsAfterGuessingKey = @"kClearPencilsAfterGuessingKey";

NSString * const kShowErrorsOptionKey = @"kShowErrorsOptionKey";
NSString * const kRemoveTileAfterErrorKey = @"kRemoveTileAfterErrorKey";

NSString * const kPreventScreenDimmingOptionKey = @"kPreventScreenDimmingOptionKey";

@implementation ZSAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Set user defaults.
	[self setUserDefaults];
	
	// If the user has upgraded the game since last launch, the game may need to do stuff.
	NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	if (![[[NSUserDefaults standardUserDefaults] stringForKey:kLastUsedVersionKey] isEqualToString:currentVersion]) {
		[self userDidUpgradeVersion];
	}
	
	// Load puzzles in from the defaults cache.
	[[ZSGameController sharedInstance] populateCacheFromUserDefaults];
	
	// Populate the cache. If it is already full from the user defaults, this does nothing.
	[[ZSGameController sharedInstance] populateCacheForAllDifficultiesSynchronous:YES];
	
	// Build the window.
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	ZSGameBookViewController *gameBookViewController = [[ZSGameBookViewController alloc] init];
	
	_window.rootViewController = gameBookViewController;
	[_window makeKeyAndVisible];
	
	// Hide the menu bar.
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
	
	// Initialize Flurry.
	[Flurry startSession:kFlurryAPIKey];
	[FlurryAds initialize:_window.rootViewController];
	
	[FlurryAds enableTestAds:YES];
	
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	ZSGameBookViewController *gameBookViewController = (ZSGameBookViewController *)_window.rootViewController;
	
	[gameBookViewController.currentGameViewController applicationWillResignActive:application];
	
	// Save the game and statistics.
	[[ZSGameController sharedInstance] saveGame:gameBookViewController.currentGameViewController.game];
	[[ZSStatisticsController sharedInstance] saveStats];
	
	// Load the puzzle cache back into user defaults.
	[[ZSGameController sharedInstance] saveCacheToUserDefaults];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	ZSGameBookViewController *gameBookViewController = (ZSGameBookViewController *)_window.rootViewController;
	
	[gameBookViewController.currentGameViewController applicationDidBecomeActive:application];
	
	// Handle screen dimming option.
	BOOL disableIdleTimer = [[[NSUserDefaults standardUserDefaults] objectForKey:kPreventScreenDimmingOptionKey] boolValue];
	[[UIApplication sharedApplication] setIdleTimerDisabled:disableIdleTimer];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// [[ZSGameController sharedInstance] saveGame];
}

- (void)userDidUpgradeVersion {
	// Get the new version and save it back into the user defaults.
	NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	[[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kLastUsedVersionKey];
	
	// Debug - Reset settings.
	[NSUserDefaults resetStandardUserDefaults];
	
	// Debug - clear stats and re-save.
	[[ZSStatisticsController sharedInstance] resetStats];
	[[ZSStatisticsController sharedInstance] saveStats];
	
	// Debug - clear saved puzzle.
	[[ZSGameController sharedInstance] clearSavedGame];
}

- (void)setUserDefaults {
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 
								 @"(never)", kLastUsedVersionKey,
								 
								 [NSNumber numberWithBool:NO], kDisplayedTutorialNotices,
								 
								 [NSData data], kPuzzleCacheKey,
								 
								 [NSNumber numberWithInt:ZSGameDifficultyChallenging], kLastPlayedPuzzleDifficulty,
								 
								 [NSNumber numberWithBool:NO], kClearTileSelectionAfterPickingAnswerOptionForAnswerKey,
								 [NSNumber numberWithBool:NO], kClearTileSelectionAfterPickingAnswerOptionForPencilKey,
								 
								 [NSNumber numberWithBool:YES], kClearPencilsAfterGuessingKey,
								 
								 [NSNumber numberWithInt:ZSShowErrorsOptionLogical], kShowErrorsOptionKey,
								 [NSNumber numberWithBool:NO], kRemoveTileAfterErrorKey,
								 
								 [NSNumber numberWithBool:NO], kPreventScreenDimmingOptionKey,
								 
								 nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];	
}

- (NSString *)getPathForFileName:(NSString *)filename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:filename];
}

@end

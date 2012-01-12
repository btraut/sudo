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

@implementation ZSAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Set user defaults.
	[self setUserDefaults];
	
	// If a game was previously in progress, restore it.
	if ([[ZSGameController sharedInstance] savedGameInProgress]) {
		[[ZSGameController sharedInstance] loadSavedGame];
	}
	
	// Set up the window.
	ZSMainMenuViewController *mainMenuController = [[ZSMainMenuViewController alloc] initWithStyle:UITableViewStyleGrouped];
	
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_navigationController = [[UINavigationController alloc] initWithRootViewController:mainMenuController];
	
	_window.rootViewController = _navigationController;
	[_window makeKeyAndVisible];
	
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
	// [[ZSGameController sharedInstance] saveGame];
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
								 
								 nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];	
}

@end

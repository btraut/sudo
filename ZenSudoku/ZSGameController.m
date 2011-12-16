//
//  ZSGameController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameController.h"
#import "ZSAppDelegate.h"
#import "ZSGame.h"
#import "ZSFastGameGenerator.h"

@implementation ZSGameController

@synthesize currentGame;

- (id)init {
	self = [super init];
	
	if (self) {
		currentGame = nil;
	}
	
	return self;
}

#pragma mark Game Creation

- (void)generateGameWithDifficulty:(ZSGameDifficulty)difficulty {
	ZSFastGameGenerator *gameGenerator = [[ZSFastGameGenerator alloc] init];
	currentGame = [gameGenerator generateGameWithDifficulty:difficulty];
}

#pragma mark Utilities

+ (NSInteger **)alloc2DIntGridWithSize:(NSInteger)size {
	// Allocate.
	NSInteger **grid = malloc(size * sizeof(NSInteger *));
	
	for (NSInteger i = 0; i < size; ++i) {
		grid[i] = malloc(size * sizeof(NSInteger));
	}
	
	return grid;
}

+ (void)free2DIntGrid:(NSInteger **)grid withSize:(NSInteger)size {
	for (NSInteger i = 0; i < size; ++i) {
		free(grid[i]);
	}
	
	free(grid);
}

+ (BOOL ***)alloc3DBoolGridWithSize:(NSInteger)size {
	// Allocate.
	BOOL ***grid = malloc(size * sizeof(BOOL **));
	
	for (NSInteger i = 0; i < size; ++i) {
		grid[i] = malloc(size * sizeof(BOOL *));
		
		for (NSInteger j = 0; j < size; ++j) {
			grid[i][j] = malloc(size * sizeof(BOOL));
		}
	}
	
	return grid;
}

+ (void)free3DBoolGrid:(BOOL ***)grid withSize:(NSInteger)size {
	for (NSInteger i = 0; i < size; ++i) {
		for (NSInteger j = 0; j < size; ++j) {
			free(grid[i][j]);
		}
		
		free(grid[i]);
	}
	
	free(grid);
}

#pragma mark Saved Game

- (BOOL)savedGameInProgress {
	return [[NSUserDefaults standardUserDefaults] boolForKey:kSavedGameInProgressKey];
}

- (void)loadSavedGame {
	NSDictionary *dictionaryRepresentation = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSavedGameKey];
	currentGame = [[ZSGame alloc] initWithDictionaryRepresentation:dictionaryRepresentation];
}

- (void)saveGame {
	[self clearSavedGame];
	
	if (currentGame) {
		NSDictionary *dictionaryRepresentation = [currentGame getDictionaryRepresentation];
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kSavedGameInProgressKey];
		[[NSUserDefaults standardUserDefaults] setObject:dictionaryRepresentation forKey:kSavedGameKey];
	}
}

- (void)clearSavedGame {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:kSavedGameInProgressKey];
	[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionary] forKey:kSavedGameKey];
}

#pragma mark Singleton Methods

+ (id)sharedInstance {
	static ZSGameController *_sharedInstance;
	
	if (!_sharedInstance) {
		static dispatch_once_t oncePredicate;
		dispatch_once(&oncePredicate, ^{
			_sharedInstance = [[super allocWithZone:nil] init];
		});
	}
	
	return _sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone {
	return self;	
}

@end

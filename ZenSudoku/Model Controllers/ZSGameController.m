//
//  ZSGameController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSGameController.h"
#import "ZSAppDelegate.h"
#import "ZSGame.h"
#import "ZSPuzzleFetcher.h"

#define UNARCHIVER_DATA_KEY @"data"

NSString * const kSavedGameFileName = @"SavedGame.plist";

@implementation ZSGameController

- (id)init {
	self = [super init];
	
	if (self) {
		
	}
	
	return self;
}

#pragma mark Game Creation

- (ZSGame *)fetchGameWithDifficulty:(ZSGameDifficulty)difficulty {
	ZSPuzzleFetcher *fetcher = [[ZSPuzzleFetcher alloc] init];
	return [fetcher fetchGameWithType:ZSGameTypeTraditional size:9 difficulty:difficulty];
}

#pragma mark Saved Game

- (BOOL)savedGameInProgress {
	ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *savedGameFilePath = [appDelegate getPathForFileName:kSavedGameFileName];
	return [[NSFileManager defaultManager] fileExistsAtPath:savedGameFilePath];
}

- (ZSGame *)loadSavedGame {
	ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *savedGameFilePath = [appDelegate getPathForFileName:kSavedGameFileName];
	NSData *data = [[NSData alloc] initWithContentsOfFile:savedGameFilePath];
	
	if (data == nil) {
		return nil;
	}
	
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
	ZSGame *game = [unarchiver decodeObjectForKey:UNARCHIVER_DATA_KEY];
	[unarchiver finishDecoding];
	
	return game;
}

- (void)saveGame:(ZSGame *)game {
	[self clearSavedGame];
	
	ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *savedGameFilePath = [appDelegate getPathForFileName:kSavedGameFileName];
	
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:game forKey:UNARCHIVER_DATA_KEY];
	[archiver finishEncoding];
	[data writeToFile:savedGameFilePath atomically:YES];
}

- (void)clearSavedGame {
	ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *savedGameFilePath = [appDelegate getPathForFileName:kSavedGameFileName];
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:savedGameFilePath error:NULL];
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

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

#define CACHE_THRESHOLD 5

NSString * const kSavedGameFileName = @"SavedGame.plist";

@interface ZSGameController () {
	dispatch_queue_t _cachePopulationDispatchQueue;
	dispatch_group_t _cachePopulationDispatchGroup;
}

@property (strong) NSMutableArray *standard9x9EasyCache;
@property (strong) NSMutableArray *standard9x9ModerateCache;
@property (strong) NSMutableArray *standard9x9ChallengingCache;
@property (strong) NSMutableArray *standard9x9DiabolicalCache;
@property (strong) NSMutableArray *standard9x9InsaneCache;

@end

@implementation ZSGameController

@synthesize standard9x9EasyCache = _standard9x9EasyCache;
@synthesize standard9x9ModerateCache = _standard9x9ModerateCache;
@synthesize standard9x9ChallengingCache = _standard9x9ChallengingCache;
@synthesize standard9x9DiabolicalCache = _standard9x9DiabolicalCache;
@synthesize standard9x9InsaneCache = _standard9x9InsaneCache;

- (id)init {
	self = [super init];
	
	if (self) {
		// Init cache.
		_cachePopulationDispatchQueue = dispatch_queue_create("com.tenfoursoftware.cachePopulationQueue", NULL);
		_cachePopulationDispatchGroup = dispatch_group_create();
		
		_standard9x9EasyCache = [NSMutableArray array];
		_standard9x9ModerateCache = [NSMutableArray array];
		_standard9x9ChallengingCache = [NSMutableArray array];
		_standard9x9DiabolicalCache = [NSMutableArray array];
		_standard9x9InsaneCache = [NSMutableArray array];
	}
	
	return self;
}

- (void)dealloc {
	dispatch_release(_cachePopulationDispatchGroup);
	dispatch_release(_cachePopulationDispatchQueue);
}

#pragma mark Game Creation

- (ZSGame *)fetchGameWithDifficulty:(ZSGameDifficulty)difficulty {
	NSMutableArray *cacheArray;
	
	switch (difficulty) {
		case ZSGameDifficultyEasy: cacheArray = self.standard9x9EasyCache; break;
		case ZSGameDifficultyModerate: cacheArray = self.standard9x9ModerateCache; break;
		case ZSGameDifficultyChallenging: cacheArray = self.standard9x9ChallengingCache; break;
		case ZSGameDifficultyDiabolical: cacheArray = self.standard9x9DiabolicalCache; break;
		case ZSGameDifficultyInsane: cacheArray = self.standard9x9InsaneCache; break;
	}
	
	if (cacheArray.count == 0) {
		[self populateCacheForDifficulty:difficulty synchronous:YES];
	}
	
	ZSGame *newGame = [cacheArray objectAtIndex:0];
	[cacheArray removeObjectAtIndex:0];
	
	return newGame;
}

#pragma mark Cache Management

- (void)populateCacheForDifficulty:(ZSGameDifficulty)difficulty synchronous:(BOOL)synchronous {
	dispatch_group_async(_cachePopulationDispatchGroup, _cachePopulationDispatchQueue, ^{
		NSMutableArray *cacheArray;
		
		switch (difficulty) {
			case ZSGameDifficultyEasy: cacheArray = self.standard9x9EasyCache; break;
			case ZSGameDifficultyModerate: cacheArray = self.standard9x9ModerateCache; break;
			case ZSGameDifficultyChallenging: cacheArray = self.standard9x9ChallengingCache; break;
			case ZSGameDifficultyDiabolical: cacheArray = self.standard9x9DiabolicalCache; break;
			case ZSGameDifficultyInsane: cacheArray = self.standard9x9InsaneCache; break;
		}
		
		NSInteger puzzlesToFetch = CACHE_THRESHOLD - cacheArray.count;
		
		if (puzzlesToFetch) {
			ZSPuzzleFetcher *fetcher = [[ZSPuzzleFetcher alloc] init];
			NSArray *games = [fetcher fetchGames:puzzlesToFetch withDifficulty:difficulty];
			
			for (ZSGame *game in games) {
				[cacheArray addObject:game];
			}
		}
	});
	
	if (synchronous) {
		dispatch_group_wait(_cachePopulationDispatchGroup, DISPATCH_TIME_FOREVER);
	}
}

- (void)populateCacheFromUserDefaults {
	NSData *encodedDefaultsCache = [[NSUserDefaults standardUserDefaults] objectForKey:kPuzzleCacheKey];
    NSDictionary *defaultsCache;
	
	if (encodedDefaultsCache.length) {
		defaultsCache = [NSKeyedUnarchiver unarchiveObjectWithData:encodedDefaultsCache];
	}
	
	if (defaultsCache) {
		NSArray *currentDifficultyCache;
		
		if ((currentDifficultyCache = [defaultsCache objectForKey:@"standard9x9EasyCache"])) {
			for (ZSGame *game in currentDifficultyCache) {
				[self.standard9x9EasyCache addObject:game];
			}
		}
		
		if ((currentDifficultyCache = [defaultsCache objectForKey:@"standard9x9ModerateCache"])) {
			for (ZSGame *game in currentDifficultyCache) {
				[self.standard9x9ModerateCache addObject:game];
			}
		}
		
		if ((currentDifficultyCache = [defaultsCache objectForKey:@"standard9x9ChallengingCache"])) {
			for (ZSGame *game in currentDifficultyCache) {
				[self.standard9x9ChallengingCache addObject:game];
			}
		}
		
		if ((currentDifficultyCache = [defaultsCache objectForKey:@"standard9x9DiabolicalCache"])) {
			for (ZSGame *game in currentDifficultyCache) {
				[self.standard9x9DiabolicalCache addObject:game];
			}
		}
		
		if ((currentDifficultyCache = [defaultsCache objectForKey:@"standard9x9InsaneCache"])) {
			for (ZSGame *game in currentDifficultyCache) {
				[self.standard9x9InsaneCache addObject:game];
			}
		}
	}
}

- (void)saveCacheToUserDefaults {
	NSMutableDictionary *defaultsCache = [NSDictionary dictionaryWithObjectsAndKeys:
										  self.standard9x9EasyCache, @"standard9x9EasyCache",
										  self.standard9x9ModerateCache, @"standard9x9ModerateCache",
										  self.standard9x9ChallengingCache, @"standard9x9ChallengingCache",
										  self.standard9x9DiabolicalCache, @"standard9x9DiabolicalCache",
										  self.standard9x9InsaneCache, @"standard9x9InsaneCache",
										  nil];
	
    NSData *encodedDefaultsCache = [NSKeyedArchiver archivedDataWithRootObject:defaultsCache];
	[[NSUserDefaults standardUserDefaults] setObject:encodedDefaultsCache forKey:kPuzzleCacheKey];
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

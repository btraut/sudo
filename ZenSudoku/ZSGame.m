//
//  ZSGame.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGame.h"
#import "ZSAppDelegate.h"
#import "ZSFastGameSolver.h"
#import "ZSGameController.h"
#import "ZSGameHistoryEntry.h"
#import "ZSGameBoard.h"
#import "ZSStatisticsController.h"

// Game Difficulty Names
NSString * const kGameDifficultyNameEasy = @"kGameDifficultyNameEasy";
NSString * const kGameDifficultyNameMedium = @"kGameDifficultyNameMedium";
NSString * const kGameDifficultyNameHard = @"kGameDifficultyNameHard";
NSString * const kGameDifficultyNameExpert = @"kGameDifficultyNameExpert";

// Game Type Names
NSString * const kGameTypeNameTraditional = @"kGameTypeNameTraditional";
NSString * const kGameTypeNameWordoku = @"kGameTypeNameWordoku";
NSString * const kGameTypeNameJigsaw = @"kGameTypeNameJigsaw";

// Dictionary Keys for Game Preservation / Restoration
NSString * const kDictionaryRepresentationGameSizeKey = @"kDictionaryRepresentationGameSizeKey";
NSString * const kDictionaryRepresentationGameDifficultyKey = @"kDictionaryRepresentationGameDifficultyKey";
NSString * const kDictionaryRepresentationGameTypeKey = @"kDictionaryRepresentationGameTypeKey";

NSString * const kDictionaryRepresentationGameTilesKey = @"kDictionaryRepresentationGameTilesKey";

NSString * const kDictionaryRepresentationGameTimerCountKey = @"kDictionaryRepresentationGameTimerCountKey";
NSString * const kDictionaryRepresentationGameTotalStrikesKey = @"kDictionaryRepresentationGameTotalStrikesKey";

NSString * const kDictionaryRepresentationGameUndoStackKey = @"kDictionaryRepresentationGameUndoStackKey";
NSString * const kDictionaryRepresentationGameRedoStackKey = @"kDictionaryRepresentationGameRedoStackKey";


@implementation ZSGame

@synthesize difficulty, type;
@synthesize gameBoard;
@synthesize recordingHistory;
@synthesize delegate;
@synthesize timerCount;
@synthesize totalStrikes;

#pragma mark - Initializing

+ (id)emptyStandard9x9Game {
	ZSGame *newGame = [[ZSGame alloc] initWithSize:9];
	
	newGame.gameBoard = [ZSGameBoard emptyStandard9x9Game];
	newGame.gameBoard.delegate = newGame;
	
	return newGame;
}

- (id)init {
	return [self initWithSize:9];
}

- (id)initWithSize:(int)newSize {
	self = [super init];
	
	if (self) {
		// Assume the difficulty for now.
		difficulty = ZSGameDifficultyEasy;
		
		// Create the board.
		gameBoard = [[ZSGameBoard alloc] initWithSize:newSize];
		gameBoard.delegate = self;
		
		// Initialize undo/redo.
		recordingHistory = YES;
		_undoStack = [NSMutableArray array];
		_redoStack = [NSMutableArray array];
	}
	
	return self;
}

- (id)initWithSize:(int)newSize answers:(int **)newAnswers groupMap:(int **)newGroupMap {
	self = [self initWithSize:newSize];
	
	if (self) {
		// Populate the tiles.
		[gameBoard applyAnswersArray:newAnswers];
		[gameBoard applyGroupMapArray:newGroupMap];
	}
	
	return self;
}

- (void)notifyStatisticsOfNewGame {
	[[ZSStatisticsController sharedInstance] gameStartedWithDifficulty:difficulty];
}

#pragma mark - Timer Methods

- (void)startGameTimer {
	_countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(advanceGameTimer:) userInfo:nil repeats:YES];
}

- (void)stopGameTimer {
	[_countdownTimer invalidate];
}

- (void)advanceGameTimer:(NSTimer *)timer {
	++timerCount;
	
	[delegate timerDidAdvance];
	
	// Notify statistics. We could mod the time and only call this function every so often, but there's little gain in doing so.
	[[ZSStatisticsController sharedInstance] timeElapsed:1 inGameWithDifficulty:difficulty];
}

#pragma mark - Persistant Storage Methods

- (id)initWithDictionaryRepresentation:(NSDictionary *)dict {
	// Init the game with the proper size.
	self = [self initWithSize:[[dict objectForKey:kDictionaryRepresentationGameSizeKey] intValue]];
	
	if (self) {
		// Set the game properties.
		difficulty = [[dict objectForKey:kDictionaryRepresentationGameDifficultyKey] intValue];
		type = [[dict objectForKey:kDictionaryRepresentationGameTypeKey] intValue];
		
		// Unpack the tiles.
		for (int row = 0; row < gameBoard.size; row++) {
			for (int col = 0; col < gameBoard.size; col++) {
				ZSGameTile *tile = [gameBoard getTileAtRow:row col:col];
				[tile setValuesForDictionaryRepresentation:[[[dict objectForKey:kDictionaryRepresentationGameTilesKey] objectAtIndex:row] objectAtIndex:col]];
			}
		}
		
		// Set the game status data.
		timerCount = [[dict objectForKey:kDictionaryRepresentationGameTimerCountKey] intValue];
		totalStrikes = [[dict objectForKey:kDictionaryRepresentationGameTotalStrikesKey] intValue];
		
		// Unpack history.
		NSMutableArray *undoStackDictionaries = [dict objectForKey:kDictionaryRepresentationGameUndoStackKey];
		NSMutableArray *redoStackDictionaries = [dict objectForKey:kDictionaryRepresentationGameRedoStackKey];
		
		for (NSArray *stackEntries in undoStackDictionaries) {
			NSMutableArray *stackEntry = [NSMutableArray array];
			
			for (NSDictionary *historyEntry in stackEntries) {
				[stackEntry addObject:[[ZSGameHistoryEntry alloc] initWithDictionaryRepresentation:historyEntry]];
			}
			
			[_undoStack addObject:stackEntry];
		}
		
		for (NSArray *stackEntries in redoStackDictionaries) {
			NSMutableArray *stackEntry = [NSMutableArray array];
			
			for (NSDictionary *historyEntry in stackEntries) {
				[stackEntry addObject:[[ZSGameHistoryEntry alloc] initWithDictionaryRepresentation:historyEntry]];
			}
			
			[_redoStack addObject:stackEntry];
		}
	}
	
	return self;
}

- (NSDictionary *)getDictionaryRepresentation {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	// Set the game properties.
	[dict setValue:[NSNumber numberWithInt:gameBoard.size] forKey:kDictionaryRepresentationGameSizeKey];
	[dict setValue:[NSNumber numberWithInt:difficulty] forKey:kDictionaryRepresentationGameDifficultyKey];
	[dict setValue:[NSNumber numberWithInt:type] forKey:kDictionaryRepresentationGameTypeKey];
	
	// Build dictionary representations of the tiles and pack them up.
	NSMutableArray *tileRowArray = [NSMutableArray array];
	
	for (int row = 0; row < gameBoard.size; row++) {
		NSMutableArray *tileColArray = [NSMutableArray array];
		
		for (int col = 0; col < gameBoard.size; col++) {
			[tileColArray addObject:[[self getTileAtRow:row col:col] getDictionaryRepresentation]];
		}
		
		[tileRowArray addObject:tileColArray];
	}
	
	[dict setValue:tileRowArray forKey:kDictionaryRepresentationGameTilesKey];
	
	// Set the game status data.
	[dict setValue:[NSNumber numberWithInt:timerCount] forKey:kDictionaryRepresentationGameTimerCountKey];
	[dict setValue:[NSNumber numberWithInt:totalStrikes] forKey:kDictionaryRepresentationGameTotalStrikesKey];
	
	// Build game history dictionaries.
	NSMutableArray *undoStackDictionaries = [NSMutableArray array];
	NSMutableArray *redoStackDictionaries = [NSMutableArray array];
	
	for (NSArray *stackEntries in _undoStack) {
		NSMutableArray *stackEntry = [NSMutableArray array];
		
		for (ZSGameHistoryEntry *historyEntry in stackEntries) {
			[stackEntry addObject:[historyEntry getDictionaryRepresentation]];
		}
		
		[undoStackDictionaries addObject:stackEntry];
	}
	
	for (NSArray *stackEntries in _redoStack) {
		NSMutableArray *stackEntry = [NSMutableArray array];
		
		for (ZSGameHistoryEntry *historyEntry in stackEntries) {
			[stackEntry addObject:[historyEntry getDictionaryRepresentation]];
		}
		
		[redoStackDictionaries addObject:stackEntry];
	}
	
	[dict setValue:undoStackDictionaries forKey:kDictionaryRepresentationGameUndoStackKey];
	[dict setValue:redoStackDictionaries forKey:kDictionaryRepresentationGameRedoStackKey];
	
	// Done.
	return dict;
}

#pragma mark - Tile Methods

- (int)getGuessForTileAtRow:(int)row col:(int)col {
	return [self getTileAtRow:row col:col].guess;
}

- (void)setGuess:(int)guess forTileAtRow:(int)row col:(int)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	
	if (tile.guess != guess) {
		BOOL enterGuess = NO;
		
		if (guess == tile.answer) {
			enterGuess = YES;
		} else {
			// Give the user a strike.
			++totalStrikes;
			
			// If we're supposed to remove the tile on error, disallow the entry.
			if (![[NSUserDefaults standardUserDefaults] integerForKey:kRemoveTileAfterErrorKey]) {
				enterGuess = YES;
			}
			
			// Create a notification.
			[delegate guess:guess isErrorForTileAtRow:row col:col];
			
			// Notify statistics.
			[[ZSStatisticsController sharedInstance] strikeEntered];
		}

		if (enterGuess) {
			// Create a new history stop.
			[self addUndoStop];
			
			// Call the internal setter.
			[gameBoard setGuess:guess forTileAtRow:row col:col];
			
			// If settings permit, clear all the pencil marks for influenced tiles.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearPencilsAfterGuessingKey]) {
				[gameBoard clearInfluencedPencilsForTileAtRow:row col:col];
			}
		}
		
		// Notify statistics.
		[[ZSStatisticsController sharedInstance] answerEntered];
	}
}

- (void)guessDidChangeForTile:(ZSGameTile *)tile previousGuess:(int)previousGuess {
	// Add the history description for the guess change.
	[self addHistoryDescription:[ZSGameHistoryEntry undoDescriptionWithType:ZSGameHistoryEntryTypeGuess tile:tile previousValue:previousGuess]];
	
	// Notify the delegate that things changed.
	[delegate tileGuessDidChange:tile.guess forTileAtRow:tile.row col:tile.col];
	
	// If the game is over, notify the delegate of that as well.
	if ([self isSolved]) {
		// Notify the delegate.
		[delegate gameWasSolved];
		
		// Notify statistics.
		[[ZSStatisticsController sharedInstance] gameSolvedWithDifficulty:difficulty totalTime:timerCount];
	}
}

- (void)pencilDidChangeForTile:(ZSGameTile *)tile pencilNumber:(int)pencilNumber previousSet:(int)previousSet {
	// Add the history description for the pencil change.
	ZSGameHistoryEntry *undoDescription = [ZSGameHistoryEntry undoDescriptionWithType:ZSGameHistoryEntryTypePencil tile:tile previousValue:previousSet];
	undoDescription.pencilNumber = pencilNumber;
	[self addHistoryDescription:undoDescription];
	
	// Notify the delegate that things changed.
	[delegate tilePencilDidChange:[tile getPencilForGuess:pencilNumber] forPencilNumber:pencilNumber forTileAtRow:tile.row col:tile.col];
}

- (void)clearGuessForTileAtRow:(int)row col:(int)col {
	[self setGuess:0 forTileAtRow:row col:col];
}

- (BOOL)getLockedForTileAtRow:(int)row col:(int)col {
	return [self getTileAtRow:row col:col].locked;
}

- (void)setLocked:(BOOL)locked forTileAtRow:(int)row col:(int)col {
	[self getTileAtRow:row col:col].locked = locked;
}

- (BOOL)getPencilForPencilNumber:(int)pencilNumber forTileAtRow:(int)row col:(int)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	return [tile getPencilForGuess:pencilNumber];
}

- (void)setPencil:(BOOL)isSet forPencilNumber:(int)pencilNumber forTileAtRow:(int)row col:(int)col {
	// Create a new history stop.
	[self addUndoStop];
	
	// Call the internal setter.
	[gameBoard setPencil:isSet forPencilNumber:pencilNumber forTileAtRow:row col:col];
}

- (void)togglePencilForPencilNumber:(int)pencilNumber forTileAtRow:(int)row col:(int)col {
	BOOL previousValue = [self getPencilForPencilNumber:pencilNumber forTileAtRow:row col:col];
	[self setPencil:!previousValue forPencilNumber:pencilNumber forTileAtRow:row col:col];
}

- (int)getGroupIdForTileAtRow:(int)row col:(int)col {
	return [self getTileAtRow:row col:col].groupId;
}

#pragma mark - Tile Methods (Private)

- (ZSGameTile *)getTileAtRow:(int)row col:(int)col {
	return [gameBoard getTileAtRow:row col:col];
}

- (NSArray *)getAllInfluencedTilesForTileAtRow:(int)targetRow col:(int)targetCol includeSelf:(BOOL)includeSelf {
	ZSGameTile *targetTile = [self getTileAtRow:targetRow col:targetCol];
	
	NSMutableArray *influencedTiles = [NSMutableArray array];
	
	// Add the group tiles first. Optionally add self.
	[influencedTiles addObjectsFromArray:[self getFamilySetForTileAtRow:targetRow col:targetCol includeSelf:includeSelf]];
	
	// Add the col tiles. Skip the ones in the same group (including self).
	for (int row = 0; row < gameBoard.size; ++row) {
		ZSGameTile *possibleInfluencedTile = [self getTileAtRow:row col:targetCol];
		
		if (possibleInfluencedTile.groupId != targetTile.groupId) {
			[influencedTiles addObject:possibleInfluencedTile];
		}
	}
	
	// Add the row tiles. Skip the ones in the same group (including self).
	for (int col = 0; col < gameBoard.size; ++col) {
		ZSGameTile *possibleInfluencedTile = [self getTileAtRow:targetRow col:col];
		
		if (possibleInfluencedTile.groupId != targetTile.groupId) {
			[influencedTiles addObject:possibleInfluencedTile];
		}
	}
	
	return influencedTiles;
}

- (NSArray *)getRowSetForTileAtRow:(int)targetRow col:(int)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	for (int row = 0; row < gameBoard.size; ++row) {
		if (includeSelf || row != targetRow) {
			[set addObject:[self getTileAtRow:row col:targetCol]];
		}
	}
	
	return set;
}

- (NSArray *)getColSetForTileAtRow:(int)targetRow col:(int)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	for (int col = 0; col < gameBoard.size; ++col) {
		if (includeSelf || col != targetCol) {
			[set addObject:[self getTileAtRow:targetRow col:col]];
		}
	}
	
	return set;
}

- (NSArray *)getFamilySetForTileAtRow:(int)targetRow col:(int)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	int targetGroupId = [self getTileAtRow:targetRow col:targetCol].groupId;
	
	for (int row = 0; row < gameBoard.size; ++row) {
		for (int col = 0; col < gameBoard.size; ++col) {
			ZSGameTile *gameTile = [self getTileAtRow:row col:col];
			
			if (gameTile.groupId == targetGroupId && (includeSelf || !(row == targetRow && col == targetCol))) {
				[set addObject:gameTile];
			}
		}
	}
	
	return set;
}

#pragma mark - Misc Methods

- (BOOL)allowsGuess:(int)guess {
	int totalOfGuess = 0;
	
	for (int row = 0; row < gameBoard.size; row++) {
		for (int col = 0; col < gameBoard.size; col++) {
			ZSGameTile *tile = [self getTileAtRow:row col:col];
			
			if (tile.guess == guess) {
				totalOfGuess++;
			}
			
			if (totalOfGuess == gameBoard.size) {
				return NO;
			}
		}
	}
	
	return YES;
}

- (BOOL)isSolved {
	for (int row = 0; row < gameBoard.size; row++) {
		for (int col = 0; col < gameBoard.size; col++) {
			ZSGameTile *gameTile = [self getTileAtRow:row col:col];
			
			if (!gameTile.guess || gameTile.guess != gameTile.answer) {
				return NO;
			}
		}
	}
	
	return YES;
}

#pragma mark - Game Actions

- (ZSGameSolveResult)solve {
	return [gameBoard solve];
}

- (void)addAutoPencils {
	// Create a new history stop.
	[self addUndoStop];
	
	// Set the pencils on the board.
	[gameBoard addAutoPencils];
}

- (void)clearInfluencedPencilsForTileAtRow:(int)row col:(int)col {
	// Create a new history stop.
	[self addUndoStop];
	
	// Call the internal setter.
	[gameBoard clearInfluencedPencilsForTileAtRow:row col:col];
}

#pragma mark - Undo/Redo

- (void)undo {
	// Keep popping the undo stack until a state is found with one or more actions.
	NSMutableArray *historyState;
	BOOL foundValidHistoryState = NO;
	
	while (!foundValidHistoryState && [_undoStack count]) {
		historyState = [_undoStack lastObject];
		[_undoStack removeLastObject];
		
		if ([historyState count]) {
			foundValidHistoryState = YES;
		}
	}
	
	// If no state was found with actions, we're done here.
	if (!foundValidHistoryState) {
		return;
	}
	
	// Stop recording while we undo.
	recordingHistory = NO;
	
	// Walk the history state backwards and restore each action.
	for (int i = [historyState count]; i; --i) {
		ZSGameHistoryEntry *undoDescription = [historyState objectAtIndex:(i - 1)];
		
		int tempPreviousValue;
		ZSGameTile *undoTile;
		
		switch (undoDescription.type) {
			case ZSGameHistoryEntryTypeGuess:
				undoTile = [gameBoard getTileAtRow:undoDescription.row col:undoDescription.col];
				tempPreviousValue = undoTile.guess;
				[gameBoard setGuess:undoDescription.previousValue forTileAtRow:undoDescription.row col:undoDescription.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
				
			case ZSGameHistoryEntryTypePencil:
				undoTile = [gameBoard getTileAtRow:undoDescription.row col:undoDescription.col];
				tempPreviousValue = [undoTile getPencilForGuess:undoDescription.pencilNumber];
				[gameBoard setPencil:undoDescription.previousValue forPencilNumber:undoDescription.pencilNumber forTileAtRow:undoDescription.row col:undoDescription.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
		}
	}
	
	// Add the state back to the redo stack.
	[_redoStack addObject:historyState];
	
	// Turn recording back on.
	recordingHistory = YES;
	
	// Notify statistics.
	[[ZSStatisticsController sharedInstance] userUsedUndo];
}

- (void)redo {
	// Keep popping the undo stack until a state is found with one or more actions.
	NSMutableArray *historyState;
	BOOL foundValidHistoryState = NO;
	
	while (!foundValidHistoryState && [_redoStack count]) {
		historyState = [_redoStack lastObject];
		[_redoStack removeLastObject];
		
		if ([historyState count]) {
			foundValidHistoryState = YES;
		}
	}
	
	// If no state was found with actions, we're done here.
	if (!foundValidHistoryState) {
		return;
	}
	
	// Stop recording while we undo.
	recordingHistory = NO;
	
	// Walk the history state backwards and restore each action.
	for (ZSGameHistoryEntry *undoDescription in historyState) {
		int tempPreviousValue;
		ZSGameTile *redoTile;
		
		switch (undoDescription.type) {
			case ZSGameHistoryEntryTypeGuess:
				redoTile = [gameBoard getTileAtRow:undoDescription.row col:undoDescription.col];
				tempPreviousValue = redoTile.guess;
				[gameBoard setGuess:undoDescription.previousValue forTileAtRow:undoDescription.row col:undoDescription.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
				
			case ZSGameHistoryEntryTypePencil:
				redoTile = [gameBoard getTileAtRow:undoDescription.row col:undoDescription.col];
				tempPreviousValue = [redoTile getPencilForGuess:undoDescription.pencilNumber];
				[gameBoard setPencil:undoDescription.previousValue forPencilNumber:undoDescription.pencilNumber forTileAtRow:undoDescription.row col:undoDescription.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
		}
	}
	
	// Add the state back to the undo stack.
	[_undoStack addObject:historyState];
	
	// Turn recording back on.
	recordingHistory = YES;
	
	// Notify statistics.
	[[ZSStatisticsController sharedInstance] userUsedRedo];
}

- (void)addHistoryDescription:(ZSGameHistoryEntry *)undoDescription {
	if (recordingHistory) {
		// Clear the redo stack.
		[_redoStack removeAllObjects];
		
		// Add the history description.
		[[_undoStack lastObject] addObject:undoDescription];
	}
}

- (void)addUndoStop {
	[_undoStack addObject:[NSMutableArray array]];
}

@end

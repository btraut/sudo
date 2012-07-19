//
//  ZSGame.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSGame.h"
#import "ZSAppDelegate.h"
#import "ZSGameController.h"
#import "ZSHistoryEntry.h"
#import "ZSBoard.h"
#import "ZSStatisticsController.h"

// Game Difficulty Names
NSString * const kGameDifficultyNameEasy = @"kGameDifficultyNameEasy";
NSString * const kGameDifficultyNameModerate = @"kGameDifficultyNameModerate";
NSString * const kGameDifficultyNameChallenging = @"kGameDifficultyNameChallenging";
NSString * const kGameDifficultyNameDiabolical = @"kGameDifficultyNameDiabolical";
NSString * const kGameDifficultyNameInsane = @"kGameDifficultyNameInsane";

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


@interface ZSGame() {
	BOOL _onGenericUndoStop;
	
	NSMutableArray *_undoStack;
	NSMutableArray *_redoStack;
	
	NSTimer *_countdownTimer;
}

@end

@implementation ZSGame

@synthesize difficulty, type;
@synthesize board;
@synthesize recordingHistory;
@synthesize stateChangeDelegate;
@synthesize timerCount;
@synthesize totalStrikes;

#pragma mark - Initializing

+ (id)emptyStandard9x9Game {
	ZSGame *newGame = [[ZSGame alloc] initWithSize:9];
	
	newGame.board = [ZSBoard emptyStandard9x9Game];
	newGame.board.delegate = newGame;
	
	return newGame;
}

- (id)init {
	return [self initWithSize:9];
}

- (id)initWithSize:(NSInteger)newSize {
	self = [super init];
	
	if (self) {
		// Assume the difficulty for now.
		difficulty = ZSGameDifficultyEasy;
		
		// Create the board.
		board = [[ZSBoard alloc] initWithSize:newSize];
		board.delegate = self;
		
		// Initialize undo/redo.
		recordingHistory = YES;
		_undoStack = [NSMutableArray array];
		_redoStack = [NSMutableArray array];
	}
	
	return self;
}

- (id)initWithSize:(NSInteger)newSize answers:(NSInteger **)newAnswers groupMap:(NSInteger **)newGroupMap {
	self = [self initWithSize:newSize];
	
	if (self) {
		// Populate the tiles.
		[board applyAnswersArray:newAnswers];
		[board applyGroupMapArray:newGroupMap];
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
	
	[self.stateChangeDelegate timerDidAdvance];
	
	// Notify statistics. We could mod the time and only call this function every so often, but there's little gain in doing so.
	[[ZSStatisticsController sharedInstance] timeElapsed:1 inGameWithDifficulty:difficulty];
}

#pragma mark - Persistant Storage Methods

- (id)initWithCoder:(NSCoder *)decoder {
	NSInteger size = [decoder decodeIntForKey:kDictionaryRepresentationGameSizeKey];
	
	// Init the game with the proper size.
	self = [self initWithSize:size];
	
	if (self) {
		// Set the game properties.
		difficulty = [decoder decodeIntForKey:kDictionaryRepresentationGameDifficultyKey];
		type = [decoder decodeIntForKey:kDictionaryRepresentationGameTypeKey];
		
		// Unpack the tiles.
		NSArray *coderTiles = [decoder decodeObjectForKey:kDictionaryRepresentationGameTilesKey];
		
		for (NSInteger row = 0; row < board.size; row++) {
			for (NSInteger col = 0; col < board.size; col++) {
				ZSTile *tile = [board getTileAtRow:row col:col];
				[tile copyTile:[[coderTiles objectAtIndex:row] objectAtIndex:col]];
			}
		}
		
		// Set the game status data.
		timerCount = [decoder decodeIntForKey:kDictionaryRepresentationGameTimerCountKey];
		totalStrikes = [decoder decodeIntForKey:kDictionaryRepresentationGameTotalStrikesKey];
		
		// Unpack history.
		_undoStack = [decoder decodeObjectForKey:kDictionaryRepresentationGameUndoStackKey];
		_redoStack = [decoder decodeObjectForKey:kDictionaryRepresentationGameRedoStackKey];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	// Encode puzzle size.
	[encoder encodeInt:board.size forKey:kDictionaryRepresentationGameSizeKey];
	
	// Encode game properties.
	[encoder encodeInt:difficulty forKey:kDictionaryRepresentationGameDifficultyKey];
	[encoder encodeInt:type forKey:kDictionaryRepresentationGameTypeKey];
	
	// Encode tiles.
	NSMutableArray *tileRowArray = [NSMutableArray array];
	
	for (NSInteger row = 0; row < board.size; row++) {
		NSMutableArray *tileColArray = [NSMutableArray array];
		
		for (NSInteger col = 0; col < board.size; col++) {
			[tileColArray addObject:[self getTileAtRow:row col:col]];
		}
		
		[tileRowArray addObject:tileColArray];
	}
	
	[encoder encodeObject:tileRowArray forKey:kDictionaryRepresentationGameTilesKey];
	
	// Encode game status.
	[encoder encodeInt:timerCount forKey:kDictionaryRepresentationGameTimerCountKey];
	[encoder encodeInt:totalStrikes forKey:kDictionaryRepresentationGameTotalStrikesKey];
	
	// Encode game history.
	[encoder encodeObject:_undoStack forKey:kDictionaryRepresentationGameUndoStackKey];
	[encoder encodeObject:_redoStack forKey:kDictionaryRepresentationGameRedoStackKey];
}

#pragma mark - NSCoder Methods

- (NSInteger)getGuessForTileAtRow:(NSInteger)row col:(NSInteger)col {
	return [self getTileAtRow:row col:col].guess;
}

- (void)setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col {
	ZSTile *tile = [self getTileAtRow:row col:col];
	
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
			[self.stateChangeDelegate guess:guess isErrorForTileAtRow:row col:col];
			
			// Notify statistics.
			[[ZSStatisticsController sharedInstance] strikeEntered];
		}

		if (enterGuess) {
			// Create a new history stop.
			[self addUndoStop];
			
			// Call the internal setter.
			[board setGuess:guess forTileAtRow:row col:col];
			
			// If settings permit, clear all the pencil marks for influenced tiles.
			if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearPencilsAfterGuessingKey]) {
				[board clearInfluencedPencilsForTileAtRow:row col:col];
			}
		}
		
		// Notify statistics.
		[[ZSStatisticsController sharedInstance] answerEntered];
	}
}

- (void)guessDidChangeForTile:(ZSTile *)tile previousGuess:(NSInteger)previousGuess {
	// Add the history description for the guess change.
	[self addHistoryDescription:[ZSHistoryEntry undoDescriptionWithType:ZSHistoryEntryTypeGuess tile:tile previousValue:previousGuess]];
	
	// Notify the delegate that things changed.
	[self.stateChangeDelegate tileGuessDidChange:tile.guess forTileAtRow:tile.row col:tile.col];
	
	// If the game is over, notify the delegate of that as well.
	if ([self isSolved]) {
		// Notify the delegate.
		[self.stateChangeDelegate gameWasSolved];
		
		// Notify statistics.
		[[ZSStatisticsController sharedInstance] gameSolvedWithDifficulty:difficulty totalTime:timerCount];
	}
}

- (void)pencilDidChangeForTile:(ZSTile *)tile pencilNumber:(NSInteger)pencilNumber previousSet:(NSInteger)previousSet {
	// Add the history description for the pencil change.
	ZSHistoryEntry *undoDescription = [ZSHistoryEntry undoDescriptionWithType:ZSHistoryEntryTypePencil tile:tile previousValue:previousSet];
	undoDescription.pencilNumber = pencilNumber;
	[self addHistoryDescription:undoDescription];
	
	// Notify the delegate that things changed.
	[self.stateChangeDelegate tilePencilDidChange:[tile getPencilForGuess:pencilNumber] forPencilNumber:pencilNumber forTileAtRow:tile.row col:tile.col];
}

- (void)clearGuessForTileAtRow:(NSInteger)row col:(NSInteger)col {
	[self setGuess:0 forTileAtRow:row col:col];
}

- (BOOL)getLockedForTileAtRow:(NSInteger)row col:(NSInteger)col {
	return [self getTileAtRow:row col:col].locked;
}

- (void)setLocked:(BOOL)locked forTileAtRow:(NSInteger)row col:(NSInteger)col {
	[self getTileAtRow:row col:col].locked = locked;
}

- (BOOL)getPencilForPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	ZSTile *tile = [self getTileAtRow:row col:col];
	return [tile getPencilForGuess:pencilNumber];
}

- (void)setPencil:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	// Create a new history stop.
	[self addUndoStop];
	
	// Call the internal setter.
	[board setPencil:isSet forPencilNumber:pencilNumber forTileAtRow:row col:col];
}

- (void)togglePencilForPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	BOOL previousValue = [self getPencilForPencilNumber:pencilNumber forTileAtRow:row col:col];
	[self setPencil:!previousValue forPencilNumber:pencilNumber forTileAtRow:row col:col];
}

- (NSInteger)getGroupIdForTileAtRow:(NSInteger)row col:(NSInteger)col {
	return [self getTileAtRow:row col:col].groupId;
}

#pragma mark - Tile Methods

- (ZSTile *)getTileAtRow:(NSInteger)row col:(NSInteger)col {
	return [board getTileAtRow:row col:col];
}

- (NSArray *)getAllInfluencedTilesForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	ZSTile *targetTile = [self getTileAtRow:targetRow col:targetCol];
	
	NSMutableArray *influencedTiles = [NSMutableArray array];
	
	// Add the group tiles first. Optionally add self.
	[influencedTiles addObjectsFromArray:[self getFamilySetForTileAtRow:targetRow col:targetCol includeSelf:includeSelf]];
	
	// Add the col tiles. Skip the ones in the same group (including self).
	for (NSInteger row = 0; row < board.size; ++row) {
		ZSTile *possibleInfluencedTile = [self getTileAtRow:row col:targetCol];
		
		if (possibleInfluencedTile.groupId != targetTile.groupId) {
			[influencedTiles addObject:possibleInfluencedTile];
		}
	}
	
	// Add the row tiles. Skip the ones in the same group (including self).
	for (NSInteger col = 0; col < board.size; ++col) {
		ZSTile *possibleInfluencedTile = [self getTileAtRow:targetRow col:col];
		
		if (possibleInfluencedTile.groupId != targetTile.groupId) {
			[influencedTiles addObject:possibleInfluencedTile];
		}
	}
	
	return influencedTiles;
}

- (NSArray *)getRowSetForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	for (NSInteger col = 0; col < board.size; ++col) {
		if (includeSelf || col != targetCol) {
			[set addObject:[self getTileAtRow:targetRow col:col]];
		}
	}
	
	return set;
}

- (NSArray *)getColSetForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	for (NSInteger row = 0; row < board.size; ++row) {
		if (includeSelf || row != targetRow) {
			[set addObject:[self getTileAtRow:row col:targetCol]];
		}
	}
	
	return set;
}

- (NSArray *)getFamilySetForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	NSInteger targetGroupId = [self getTileAtRow:targetRow col:targetCol].groupId;
	
	for (NSInteger row = 0; row < board.size; ++row) {
		for (NSInteger col = 0; col < board.size; ++col) {
			ZSTile *gameTile = [self getTileAtRow:row col:col];
			
			if (gameTile.groupId == targetGroupId && (includeSelf || !(row == targetRow && col == targetCol))) {
				[set addObject:gameTile];
			}
		}
	}
	
	return set;
}

#pragma mark - Misc Methods

- (BOOL)allowsGuess:(NSInteger)guess {
	NSInteger totalOfGuess = 0;
	
	for (NSInteger row = 0; row < board.size; row++) {
		for (NSInteger col = 0; col < board.size; col++) {
			ZSTile *tile = [self getTileAtRow:row col:col];
			
			if (tile.guess == guess) {
				totalOfGuess++;
			}
			
			if (totalOfGuess == board.size) {
				return NO;
			}
		}
	}
	
	return YES;
}

- (BOOL)isSolved {
	for (NSInteger row = 0; row < board.size; row++) {
		for (NSInteger col = 0; col < board.size; col++) {
			ZSTile *gameTile = [self getTileAtRow:row col:col];
			
			if (!gameTile.guess || gameTile.guess != gameTile.answer) {
				return NO;
			}
		}
	}
	
	return YES;
}

#pragma mark - Game Actions

- (void)addAutoPencils {
	// Create a new history stop.
	[self addUndoStop];
	
	// Set the pencils on the board.
	[board addAutoPencils];
}

- (void)clearInfluencedPencilsForTileAtRow:(NSInteger)row col:(NSInteger)col {
	// Create a new history stop.
	[self addUndoStop];
	
	// Call the internal setter.
	[board clearInfluencedPencilsForTileAtRow:row col:col];
}

#pragma mark - Undo/Redo

- (void)undo {
	[self undoAndPlaceOntoRedoStack:YES];
}

- (void)undoAndPlaceOntoRedoStack:(BOOL)placeOntoRedoStack {
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
	for (NSInteger i = [historyState count]; i; --i) {
		ZSHistoryEntry *undoDescription = [historyState objectAtIndex:(i - 1)];
		
		NSInteger tempPreviousValue;
		ZSTile *undoTile;
		
		switch (undoDescription.type) {
			case ZSHistoryEntryTypeGuess:
				undoTile = [board getTileAtRow:undoDescription.row col:undoDescription.col];
				tempPreviousValue = undoTile.guess;
				[board setGuess:undoDescription.previousValue forTileAtRow:undoDescription.row col:undoDescription.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
				
			case ZSHistoryEntryTypePencil:
				undoTile = [board getTileAtRow:undoDescription.row col:undoDescription.col];
				tempPreviousValue = [undoTile getPencilForGuess:undoDescription.pencilNumber];
				[board setPencil:undoDescription.previousValue forPencilNumber:undoDescription.pencilNumber forTileAtRow:undoDescription.row col:undoDescription.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
		}
	}
	
	// Add the state back to the redo stack.
	if (placeOntoRedoStack) {
		[_redoStack addObject:historyState];
	}
	
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
	for (ZSHistoryEntry *undoDescription in historyState) {
		NSInteger tempPreviousValue;
		ZSTile *redoTile;
		
		switch (undoDescription.type) {
			case ZSHistoryEntryTypeGuess:
				redoTile = [board getTileAtRow:undoDescription.row col:undoDescription.col];
				tempPreviousValue = redoTile.guess;
				[board setGuess:undoDescription.previousValue forTileAtRow:undoDescription.row col:undoDescription.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
				
			case ZSHistoryEntryTypePencil:
				redoTile = [board getTileAtRow:undoDescription.row col:undoDescription.col];
				tempPreviousValue = [redoTile getPencilForGuess:undoDescription.pencilNumber];
				[board setPencil:undoDescription.previousValue forPencilNumber:undoDescription.pencilNumber forTileAtRow:undoDescription.row col:undoDescription.col];
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

- (void)addHistoryDescription:(ZSHistoryEntry *)undoDescription {
	if (recordingHistory) {
		// Clear the redo stack.
		[_redoStack removeAllObjects];
		
		// Add the history description.
		[[_undoStack lastObject] addObject:undoDescription];
	}
}

- (void)startGenericUndoStop {
	_onGenericUndoStop = YES;
	
	[_undoStack addObject:[NSMutableArray array]];
}

- (void)stopGenericUndoStop {
	_onGenericUndoStop = NO;
}

- (void)addUndoStop {
	if (!_onGenericUndoStop) {
		[_undoStack addObject:[NSMutableArray array]];
	}
}

@end

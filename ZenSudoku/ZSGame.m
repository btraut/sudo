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

NSString * const kDictionaryRepresentationGameDifficultyKey = @"kDictionaryRepresentationGameDifficultyKey";
NSString * const kDictionaryRepresentationGameTilesKey = @"kDictionaryRepresentationGameTilesKey";

@implementation ZSGame

@synthesize difficulty, gameBoard;
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

- (id)initWithSize:(NSInteger)newSize {
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

- (id)initWithSize:(NSInteger)newSize answers:(NSInteger **)newAnswers groupMap:(NSInteger **)newGroupMap {
	self = [self initWithSize:newSize];
	
	if (self) {
		// Populate the tiles.
		[gameBoard applyAnswersArray:newAnswers];
		[gameBoard applyGroupMapArray:newGroupMap];
	}
	
	return self;
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
}

#pragma mark - Persistant Storage Methods

- (id)initWithDictionaryRepresentation:(NSDictionary *)dict {
/*
	self = [self init];
	
	if (self) {
		NSMutableArray *tileRows = [NSMutableArray array];
		
		for (NSInteger row = 0; row < gameBoard.size; row++) {
			NSMutableArray *tileCols = [NSMutableArray array];
			
			for (NSInteger col = 0; col < gameBoard.size; col++) {
				NSDictionary *gameTileDictionaryRepresentation = [[[dict objectForKey:kDictionaryRepresentationGameTilesKey] objectAtIndex:row] objectAtIndex:col];
				
				ZSGameTile *gameTile = [[ZSGameTile alloc] initWithGame:(ZSGame *)self dictionaryRepresentation:gameTileDictionaryRepresentation];
				
				gameTile.row = row;
				gameTile.col = col;
				
				[tileCols addObject:gameTile];
			}
			
			[tileRows addObject:[NSArray arrayWithArray:tileCols]];
		}
		
		_tiles = [NSArray arrayWithArray:tileRows];
	}
	
	return self;
*/
	
	return nil;
}

- (NSDictionary *)getDictionaryRepresentation {
/*
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setValue:[NSNumber numberWithInt:difficulty] forKey:kDictionaryRepresentationGameDifficultyKey];
	
	NSMutableArray *tileRowArray = [NSMutableArray array];
	
	for (NSInteger row = 0; row < gameBoard.size; row++) {
		NSMutableArray *tileColArray = [NSMutableArray array];
		
		for (NSInteger col = 0; col < gameBoard.size; col++) {
			[tileColArray addObject:[[self getTileAtRow:row col:col] getDictionaryRepresentation]];
		}
		
		[tileRowArray addObject:tileColArray];
	}
	
	[dict setValue:tileRowArray forKey:kDictionaryRepresentationGameTilesKey];
	
	return dict;
*/
	
	return nil;
}

#pragma mark - Tile Methods

- (NSInteger)getGuessForTileAtRow:(NSInteger)row col:(NSInteger)col {
	return [self getTileAtRow:row col:col].guess;
}

- (void)setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	
	if (tile.guess != guess) {
		// Create a new history stop.
		[self addUndoStop];
		
		// Call the internal setter.
		[gameBoard setGuess:guess forTileAtRow:row col:col];
		
		// If settings permit, clear all the pencil marks for influenced tiles.
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearPencilsAfterGuessingKey]) {
			[gameBoard clearInfluencedPencilsForTileAtRow:row col:col];
		}
	}
}

- (void)guessDidChangeForTile:(ZSGameTile *)tile previousGuess:(NSInteger)previousGuess {
	// Add the history description for the guess change.
	[self addHistoryDescription:[ZSGameHistoryEntry undoDescriptionWithType:ZSGameHistoryEntryTypeGuess tile:tile previousValue:previousGuess]];
	
	// Notify the delegate that things changed.
	[delegate tileGuessDidChange:tile.guess forTileAtRow:tile.row col:tile.col];
	
	// If the game is over, notify the delegate of that as well.
	if ([self isSolved]) {
		[delegate gameWasSolved];
	}
}

- (void)pencilDidChangeForTile:(ZSGameTile *)tile pencilNumber:(NSInteger)pencilNumber previousSet:(NSInteger)previousSet {
	// Add the history description for the pencil change.
	ZSGameHistoryEntry *undoDescription = [ZSGameHistoryEntry undoDescriptionWithType:ZSGameHistoryEntryTypePencil tile:tile previousValue:previousSet];
	undoDescription.pencilNumber = pencilNumber;
	[self addHistoryDescription:undoDescription];
	
	// Notify the delegate that things changed.
	[delegate tilePencilDidChange:[tile getPencilForGuess:pencilNumber] forPencilNumber:pencilNumber forTileAtRow:tile.row col:tile.col];
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
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	return [tile getPencilForGuess:pencilNumber];
}

- (void)setPencil:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	// Create a new history stop.
	[self addUndoStop];
	
	// Call the internal setter.
	[gameBoard setPencil:isSet forPencilNumber:pencilNumber forTileAtRow:row col:col];
}

- (void)togglePencilForPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	BOOL previousValue = [self getPencilForPencilNumber:pencilNumber forTileAtRow:row col:col];
	[self setPencil:!previousValue forPencilNumber:pencilNumber forTileAtRow:row col:col];
}

- (NSInteger)getGroupIdForTileAtRow:(NSInteger)row col:(NSInteger)col {
	return [self getTileAtRow:row col:col].groupId;
}

#pragma mark - Tile Methods (Private)

- (ZSGameTile *)getTileAtRow:(NSInteger)row col:(NSInteger)col {
	return [gameBoard getTileAtRow:row col:col];
}

- (NSArray *)getAllInfluencedTilesForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	ZSGameTile *targetTile = [self getTileAtRow:targetRow col:targetCol];
	
	NSMutableArray *influencedTiles = [NSMutableArray array];
	
	// Add the group tiles first. Optionally add self.
	[influencedTiles addObjectsFromArray:[self getFamilySetForTileAtRow:targetRow col:targetCol includeSelf:includeSelf]];
	
	// Add the col tiles. Skip the ones in the same group (including self).
	for (NSInteger row = 0; row < gameBoard.size; ++row) {
		ZSGameTile *possibleInfluencedTile = [self getTileAtRow:row col:targetCol];
		
		if (possibleInfluencedTile.groupId != targetTile.groupId) {
			[influencedTiles addObject:possibleInfluencedTile];
		}
	}
	
	// Add the row tiles. Skip the ones in the same group (including self).
	for (NSInteger col = 0; col < gameBoard.size; ++col) {
		ZSGameTile *possibleInfluencedTile = [self getTileAtRow:targetRow col:col];
		
		if (possibleInfluencedTile.groupId != targetTile.groupId) {
			[influencedTiles addObject:possibleInfluencedTile];
		}
	}
	
	return influencedTiles;
}

- (NSArray *)getRowSetForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	for (NSInteger row = 0; row < gameBoard.size; ++row) {
		if (includeSelf || row != targetRow) {
			[set addObject:[self getTileAtRow:row col:targetCol]];
		}
	}
	
	return set;
}

- (NSArray *)getColSetForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	for (NSInteger col = 0; col < gameBoard.size; ++col) {
		if (includeSelf || col != targetCol) {
			[set addObject:[self getTileAtRow:targetRow col:col]];
		}
	}
	
	return set;
}

- (NSArray *)getFamilySetForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	NSInteger targetGroupId = [self getTileAtRow:targetRow col:targetCol].groupId;
	
	for (NSInteger row = 0; row < gameBoard.size; ++row) {
		for (NSInteger col = 0; col < gameBoard.size; ++col) {
			ZSGameTile *gameTile = [self getTileAtRow:row col:col];
			
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
	
	for (NSInteger row = 0; row < gameBoard.size; row++) {
		for (NSInteger col = 0; col < gameBoard.size; col++) {
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
	for (NSInteger row = 0; row < gameBoard.size; row++) {
		for (NSInteger col = 0; col < gameBoard.size; col++) {
			ZSGameTile *gameTile = [self getTileAtRow:row col:col];
			
			if (!gameTile.guess || gameTile.guess != gameTile.answer) {
				return NO;
			}
		}
	}
	
	return YES;
}

#pragma mark - Game Actions

- (void)solve {
	[gameBoard solve];
}

- (void)addAutoPencils {
	// Create a new history stop.
	[self addUndoStop];
	
	// Set the pencils on the board.
	[gameBoard addAutoPencils];
}

- (void)clearInfluencedPencilsForTileAtRow:(NSInteger)row col:(NSInteger)col {
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
	for (NSInteger i = [historyState count]; i; --i) {
		ZSGameHistoryEntry *undoDescription = [historyState objectAtIndex:(i - 1)];
		
		NSInteger tempPreviousValue;
		
		switch (undoDescription.type) {
			case ZSGameHistoryEntryTypeGuess:
				tempPreviousValue = undoDescription.tile.guess;
				[gameBoard setGuess:undoDescription.previousValue forTileAtRow:undoDescription.tile.row col:undoDescription.tile.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
				
			case ZSGameHistoryEntryTypePencil:
				tempPreviousValue = [undoDescription.tile getPencilForGuess:undoDescription.pencilNumber];
				[gameBoard setPencil:undoDescription.previousValue forPencilNumber:undoDescription.pencilNumber forTileAtRow:undoDescription.tile.row col:undoDescription.tile.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
		}
	}
	
	// Add the state back to the redo stack.
	[_redoStack addObject:historyState];
	
	// Turn recording back on.
	recordingHistory = YES;
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
		NSInteger tempPreviousValue;
		
		switch (undoDescription.type) {
			case ZSGameHistoryEntryTypeGuess:
				tempPreviousValue = undoDescription.tile.guess;
				[gameBoard setGuess:undoDescription.previousValue forTileAtRow:undoDescription.tile.row col:undoDescription.tile.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
				
			case ZSGameHistoryEntryTypePencil:
				tempPreviousValue = [undoDescription.tile getPencilForGuess:undoDescription.pencilNumber];
				[gameBoard setPencil:undoDescription.previousValue forPencilNumber:undoDescription.pencilNumber forTileAtRow:undoDescription.tile.row col:undoDescription.tile.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
		}
	}
	
	// Add the state back to the undo stack.
	[_undoStack addObject:historyState];
	
	// Turn recording back on.
	recordingHistory = YES;
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

//
//  ZSGame.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGame.h"
#import "ZSAppDelegate.h"
#import "ZSGameSolver.h"
#import "ZSGameController.h"
#import "ZSGameHistoryEntry.h"

NSString * const kDictionaryRepresentationGameDifficultyKey = @"kDictionaryRepresentationGameDifficultyKey";
NSString * const kDictionaryRepresentationGameTilesKey = @"kDictionaryRepresentationGameTilesKey";

NSInteger empty9x9Grid[9][9] = {
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
};

NSInteger standard9x9GroupMap[9][9] = {
	{0, 0, 0, 1, 1, 1, 2, 2, 2},
	{0, 0, 0, 1, 1, 1, 2, 2, 2},
	{0, 0, 0, 1, 1, 1, 2, 2, 2},
	{3, 3, 3, 4, 4, 4, 5, 5, 5},
	{3, 3, 3, 4, 4, 4, 5, 5, 5},
	{3, 3, 3, 4, 4, 4, 5, 5, 5},
	{6, 6, 6, 7, 7, 7, 8, 8, 8},
	{6, 6, 6, 7, 7, 7, 8, 8, 8},
	{6, 6, 6, 7, 7, 7, 8, 8, 8},
};

@interface ZSGame()

- (void)_setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)_setPencil:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)_setAllPencils:(BOOL)isSet forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)_clearInfluencedPencilsForTileAtRow:(NSInteger)row col:(NSInteger)col;

@end

@implementation ZSGame

@synthesize size, difficulty;
@synthesize recordingHistory;
@synthesize delegate;
@synthesize timerCount;
@synthesize totalStrikes;

#pragma mark - Initializing

+ (id)emptyStandard9x9Game {
	NSInteger **newAnswers = [ZSGameController alloc2DIntGridWithSize:9];
	NSInteger **newGroupMap = [ZSGameController alloc2DIntGridWithSize:9];
	
	for (NSInteger row = 0; row < 9; ++row) {
		for (NSInteger col = 0; col < 9; ++col) {
			newAnswers[row][col] = 0;
			newGroupMap[row][col] = standard9x9GroupMap[row][col];
		}
	}
	
	ZSGame *newGame = [[ZSGame alloc] initWithSize:9 answers:newAnswers groupMap:newGroupMap];
	
	[ZSGameController free2DIntGrid:newAnswers withSize:9];
	[ZSGameController free2DIntGrid:newGroupMap withSize:9];
	
	return newGame;
}

- (id)init {
	return [self initWithSize:9];
}

- (id)initWithSize:(NSInteger)newSize {
	self = [super init];
	
	if (self) {
		// Set the new size.
		size = newSize;
		
		// Create the tiles.
		[self createTiles];
		
		// Assume the difficulty for now.
		difficulty = ZSGameDifficultyEasy;
		
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
		[self applyAnswersArray:newAnswers];
		[self applyGroupMapArray:newGroupMap];
	}
	
	return self;
}

- (void)createTiles {
	NSMutableArray *tileRows = [NSMutableArray array];
	
	for (NSInteger row = 0; row < size; row++) {
		NSMutableArray *tileCols = [NSMutableArray array];
		
		for (NSInteger col = 0; col < size; col++) {
			ZSGameTile *gameTile = [[ZSGameTile alloc] initWithGame:self];
			
			gameTile.row = row;
			gameTile.col = col;
			
			[tileCols addObject:gameTile];
		}
		
		[tileRows addObject:[NSArray arrayWithArray:tileCols]];
	}
	
	_tiles = [NSArray arrayWithArray:tileRows];
}

- (void)applyAnswersString:(NSString *)answers {
	NSInteger currentRow = 0;
	NSInteger currentCol = 0;
	
	NSInteger intEquivalent;
	
	for (NSInteger i = 0, l = answers.length; i < l; ++i) {
		unichar currentChar = [answers characterAtIndex:i];
		
		switch (currentChar) {
			case '.':
			case '0':
				[self getTileAtRow:currentRow col:currentCol].answer = 0;
				[self getTileAtRow:currentRow col:currentCol].guess = 0;
				[self getTileAtRow:currentRow col:currentCol].locked = NO;
				break;
				
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				intEquivalent = (NSInteger)currentChar - 48;
				[self getTileAtRow:currentRow col:currentCol].answer = intEquivalent;
				[self getTileAtRow:currentRow col:currentCol].guess = intEquivalent;
				[self getTileAtRow:currentRow col:currentCol].locked = YES;
				break;
				
			default:
				continue;
		}
		
		if (++currentCol >= size) {
			currentCol -= size;
			++currentRow;
		}
		
		if (currentRow == size) {
			break;
		}
	}
}

- (void)applyAnswersArray:(NSInteger **)newAnswers {
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
			[self getTileAtRow:row col:col].answer = newAnswers[row][col];
			[self getTileAtRow:row col:col].guess = newAnswers[row][col];
			[self getTileAtRow:row col:col].locked = newAnswers[row][col];
		}
	}
}

- (void)applyGroupMapArray:(NSInteger **)newGroupMap {
	for (NSInteger row = 0; row < size; row++) {
		for (NSInteger col = 0; col < size; col++) {
			[self getTileAtRow:row col:col].groupId = newGroupMap[row][col];
		}
	}
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
	self = [self init];
	
	if (self) {
		NSMutableArray *tileRows = [NSMutableArray array];
		
		for (NSInteger row = 0; row < size; row++) {
			NSMutableArray *tileCols = [NSMutableArray array];
			
			for (NSInteger col = 0; col < size; col++) {
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
}

- (NSDictionary *)getDictionaryRepresentation {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setValue:[NSNumber numberWithInt:difficulty] forKey:kDictionaryRepresentationGameDifficultyKey];
	
	NSMutableArray *tileRowArray = [NSMutableArray array];
	
	for (NSInteger row = 0; row < size; row++) {
		NSMutableArray *tileColArray = [NSMutableArray array];
		
		for (NSInteger col = 0; col < size; col++) {
			[tileColArray addObject:[[self getTileAtRow:row col:col] getDictionaryRepresentation]];
		}
		
		[tileRowArray addObject:tileColArray];
	}
	
	[dict setValue:tileRowArray forKey:kDictionaryRepresentationGameTilesKey];
	
	return dict;
}

#pragma mark - Tile Methods

- (NSInteger)getAnswerForTileAtRow:(NSInteger)row col:(NSInteger)col {
	return [self getTileAtRow:row col:col].answer;
}

- (void)setAnswer:(NSInteger)answer forTileAtRow:(NSInteger)row col:(NSInteger)col {
	[self getTileAtRow:row col:col].answer = answer;
}

- (NSInteger)getGuessForTileAtRow:(NSInteger)row col:(NSInteger)col {
	return [self getTileAtRow:row col:col].guess;
}

- (void)setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	
	if (tile.guess != guess) {
		// Create a new history stop.
		[self addUndoStop];
		
		// Call the internal setter.
		[self _setGuess:guess forTileAtRow:row col:col];
		
		// If settings permit, clear all the pencil marks for influenced tiles.
		if ([[NSUserDefaults standardUserDefaults] boolForKey:kClearPencilsAfterGuessingKey]) {
			[self _clearInfluencedPencilsForTileAtRow:row col:col];
		}
	}
}

- (void)_setGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	
	if (tile.guess != guess) {
		// Clear all the pencil marks from the tile. This will create history records as well.
		[self _setAllPencils:NO forTileAtRow:row col:col];
		
		// Add the history description for the guess change.
		[self addHistoryDescription:[ZSGameHistoryEntry undoDescriptionWithType:ZSGameHistoryEntryTypeGuess tile:tile previousValue:tile.guess]];
		
		// Change the guess value.
		tile.guess = guess;
		
		// Notify the delegate that things changed.
		[delegate tileGuessDidChange:guess forTileAtRow:row col:col];
		
		// If the game is over, notify the delegate of that as well.
		if ([self isSolved]) {
			[delegate gameWasSolved];
		}
	}
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
	[self _setPencil:isSet forPencilNumber:pencilNumber forTileAtRow:row col:col];
}

- (void)_setPencil:(BOOL)isSet forPencilNumber:(NSInteger)pencilNumber forTileAtRow:(NSInteger)row col:(NSInteger)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	BOOL previousValue = [tile getPencilForGuess:pencilNumber];
	
	if (isSet != previousValue) {
		ZSGameHistoryEntry *undoDescription = [ZSGameHistoryEntry undoDescriptionWithType:ZSGameHistoryEntryTypePencil tile:tile previousValue:previousValue];
		undoDescription.pencilNumber = pencilNumber;
		[self addHistoryDescription:undoDescription];
		
		[tile setPencil:isSet forGuess:pencilNumber];
		
		[delegate tilePencilDidChange:isSet forPencilNumber:pencilNumber forTileAtRow:row col:col];
	}
}

- (void)_setAllPencils:(BOOL)isSet forTileAtRow:(NSInteger)row col:(NSInteger)col {
	for (NSInteger i = 1; i <= size; ++i) {
		[self _setPencil:isSet forPencilNumber:i forTileAtRow:row col:col];
	}
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
	return [[_tiles objectAtIndex:row] objectAtIndex:col];
}

- (NSArray *)getAllInfluencedTilesForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	ZSGameTile *targetTile = [self getTileAtRow:targetRow col:targetCol];
	
	NSMutableArray *influencedTiles = [NSMutableArray array];
	
	// Add the group tiles first. Optionally add self.
	[influencedTiles addObjectsFromArray:[self getFamilySetForTileAtRow:targetRow col:targetCol includeSelf:includeSelf]];
	
	// Add the col tiles. Skip the ones in the same group (including self).
	for (NSInteger row = 0; row < size; ++row) {
		ZSGameTile *possibleInfluencedTile = [self getTileAtRow:row col:targetCol];
		
		if (possibleInfluencedTile.groupId != targetTile.groupId) {
			[influencedTiles addObject:possibleInfluencedTile];
		}
	}
	
	// Add the row tiles. Skip the ones in the same group (including self).
	for (NSInteger col = 0; col < size; ++col) {
		ZSGameTile *possibleInfluencedTile = [self getTileAtRow:targetRow col:col];
		
		if (possibleInfluencedTile.groupId != targetTile.groupId) {
			[influencedTiles addObject:possibleInfluencedTile];
		}
	}
	
	return influencedTiles;
}

- (NSArray *)getRowSetForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	for (NSInteger row = 0; row < size; ++row) {
		if (includeSelf || row != targetRow) {
			[set addObject:[self getTileAtRow:row col:targetCol]];
		}
	}
	
	return set;
}

- (NSArray *)getColSetForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	for (NSInteger col = 0; col < size; ++col) {
		if (includeSelf || col != targetCol) {
			[set addObject:[self getTileAtRow:targetRow col:col]];
		}
	}
	
	return set;
}

- (NSArray *)getFamilySetForTileAtRow:(NSInteger)targetRow col:(NSInteger)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	NSInteger targetGroupId = [self getTileAtRow:targetRow col:targetCol].groupId;
	
	for (NSInteger row = 0; row < size; ++row) {
		for (NSInteger col = 0; col < size; ++col) {
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
	
	for (NSInteger row = 0; row < size; row++) {
		for (NSInteger col = 0; col < size; col++) {
			ZSGameTile *tile = [self getTileAtRow:row col:col];
			
			if (tile.guess == guess) {
				totalOfGuess++;
			}
			
			if (totalOfGuess == size) {
				return NO;
			}
		}
	}
	
	return YES;
}

- (BOOL)isSolved {
	for (NSInteger row = 0; row < size; row++) {
		for (NSInteger col = 0; col < size; col++) {
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
	[[ZSGameSolver alloc] solveGame:self];
}

- (void)addAutoPencils {
	// Create a new history stop.
	[self addUndoStop];
	
	// For the first pass, enable all pencil marks.
	for (NSInteger row = 0; row < size; row++) {
		for (NSInteger col = 0; col < size; col++) {
			ZSGameTile *tile = [self getTileAtRow:row col:col];
			
			if (!tile.guess) {
				for (NSInteger i = 1; i <= size; ++i) {
					[self _setPencil:YES forPencilNumber:i forTileAtRow:row col:col];
				}
			}
		}
	}
	
	// Search for all guesses. When one is found, get all the associated tiles and disable pencils for that value.
	for (NSInteger row = 0; row < size; row++) {
		for (NSInteger col = 0; col < size; col++) {
			[self _clearInfluencedPencilsForTileAtRow:row col:col];
		}
	}
}

- (void)clearInfluencedPencilsForTileAtRow:(NSInteger)row col:(NSInteger)col {
	// Create a new history stop.
	[self addUndoStop];
	
	// Call the internal setter.
	[self _clearInfluencedPencilsForTileAtRow:row col:col];
}

- (void)_clearInfluencedPencilsForTileAtRow:(NSInteger)row col:(NSInteger)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	
	// Only clear the pencils if there's no guess present.
	if (tile.guess) {
		NSArray *influencedTiles = [self getAllInfluencedTilesForTileAtRow:row col:col includeSelf:NO];
		
		for (ZSGameTile *influencedTile in influencedTiles) {
			if (!influencedTile.guess) {
				[self _setPencil:NO forPencilNumber:tile.guess forTileAtRow:influencedTile.row col:influencedTile.col];
			}
		}
	}
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
				[self _setGuess:undoDescription.previousValue forTileAtRow:undoDescription.tile.row col:undoDescription.tile.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
				
			case ZSGameHistoryEntryTypePencil:
				tempPreviousValue = [undoDescription.tile getPencilForGuess:undoDescription.pencilNumber];
				[self _setPencil:undoDescription.previousValue forPencilNumber:undoDescription.pencilNumber forTileAtRow:undoDescription.tile.row col:undoDescription.tile.col];
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
				[self _setGuess:undoDescription.previousValue forTileAtRow:undoDescription.tile.row col:undoDescription.tile.col];
				undoDescription.previousValue = tempPreviousValue;
				break;
				
			case ZSGameHistoryEntryTypePencil:
				tempPreviousValue = [undoDescription.tile getPencilForGuess:undoDescription.pencilNumber];
				[self _setPencil:undoDescription.previousValue forPencilNumber:undoDescription.pencilNumber forTileAtRow:undoDescription.tile.row col:undoDescription.tile.col];
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

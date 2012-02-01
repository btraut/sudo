//
//  ZSGameBoard.m
//  ZenSudoku
//
//  Created by Brent Traut on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameBoard.h"
#import "ZSGame.h"
#import "ZSGameTile.h"
#import "ZSGameController.h"
#import "ZSFastGameSolver.h"

int standard9x9GroupMap[9][9] = {
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

@implementation ZSGameBoard

@synthesize delegate;
@synthesize size;

#pragma mark - Initialization

+ (id)emptyStandard9x9Game {
	int **newAnswers = [ZSGameController alloc2DIntGridWithSize:9];
	int **newGroupMap = [ZSGameController alloc2DIntGridWithSize:9];
	
	for (int row = 0; row < 9; ++row) {
		for (int col = 0; col < 9; ++col) {
			newAnswers[row][col] = 0;
			newGroupMap[row][col] = standard9x9GroupMap[row][col];
		}
	}
	
	ZSGameBoard *newBoard = [[ZSGameBoard alloc] initWithSize:9 answers:newAnswers groupMap:newGroupMap];
	
	[ZSGameController free2DIntGrid:newAnswers withSize:9];
	[ZSGameController free2DIntGrid:newGroupMap withSize:9];
	
	return newBoard;
}

- (id)init {
	return [self initWithSize:9];
}

- (id)initWithSize:(int)newSize {
	self = [super init];
	
	if (self) {
		// Set the new size.
		size = newSize;
		
		// Create the tiles.
		[self createTiles];
	}
	
	return self;
}

- (id)initWithSize:(int)newSize answers:(int **)newAnswers groupMap:(int **)newGroupMap {
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
	
	for (int row = 0; row < size; row++) {
		NSMutableArray *tileCols = [NSMutableArray array];
		
		for (int col = 0; col < size; col++) {
			ZSGameTile *gameTile = [[ZSGameTile alloc] initWithBoard:self];
			
			gameTile.row = row;
			gameTile.col = col;
			
			[tileCols addObject:gameTile];
		}
		
		[tileRows addObject:[NSArray arrayWithArray:tileCols]];
	}
	
	_tiles = [NSArray arrayWithArray:tileRows];
}

- (void)applyAnswersString:(NSString *)answers {
	int currentRow = 0;
	int currentCol = 0;
	
	int intEquivalent;
	
	for (int i = 0, l = answers.length; i < l; ++i) {
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
				intEquivalent = (int)currentChar - 48;
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

- (void)applyAnswersArray:(int **)newAnswers {
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			[self getTileAtRow:row col:col].answer = newAnswers[row][col];
			[self getTileAtRow:row col:col].guess = newAnswers[row][col];
			[self getTileAtRow:row col:col].locked = newAnswers[row][col];
		}
	}
}

- (void)applyGroupMapArray:(int **)newGroupMap {
	for (int row = 0; row < size; row++) {
		for (int col = 0; col < size; col++) {
			[self getTileAtRow:row col:col].groupId = newGroupMap[row][col];
		}
	}
}

- (void)copyGroupMapFromGameBoard:(ZSGameBoard *)gameBoard {
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			[self getTileAtRow:row col:col].groupId = [gameBoard getTileAtRow:row col:col].groupId;
		}
	}
}

- (void)copyAnswersFromGameBoard:(ZSGameBoard *)gameBoard {
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			[self getTileAtRow:row col:col].answer = [gameBoard getTileAtRow:row col:col].answer;
		}
	}
}

- (void)copyGuessesFromGameBoard:(ZSGameBoard *)gameBoard {
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			[self getTileAtRow:row col:col].guess = [gameBoard getTileAtRow:row col:col].guess;
		}
	}
}

- (void)copyGuessesFromString:(NSString *)string {
	int currentRow = 0;
	int currentCol = 0;
	
	int intEquivalent;
	
	for (int i = 0, l = string.length; i < l; ++i) {
		unichar currentChar = [string characterAtIndex:i];
		
		switch (currentChar) {
			case '.':
			case '0':
				[self clearGuessForTileAtRow:currentRow col:currentCol];
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
				intEquivalent = (int)currentChar - 48;
				[self getTileAtRow:currentRow col:currentCol].guess = intEquivalent;
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

- (void)copyGroupMapFromString:(NSString *)string {
	int currentRow = 0;
	int currentCol = 0;
	
	int intEquivalent;
	
	for (int i = 0, l = string.length; i < l; ++i) {
		unichar currentChar = [string characterAtIndex:i];
		
		switch (currentChar) {
			case '0':
			case '1':
			case '2':
			case '3':
			case '4':
			case '5':
			case '6':
			case '7':
			case '8':
			case '9':
				intEquivalent = (int)currentChar - 48;
				[self getTileAtRow:currentRow col:currentCol].groupId = intEquivalent;
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

- (void)copyAnswersFromString:(NSString *)string {
	int currentRow = 0;
	int currentCol = 0;
	
	int intEquivalent;
	
	for (int i = 0, l = string.length; i < l; ++i) {
		unichar currentChar = [string characterAtIndex:i];
		
		switch (currentChar) {
			case '.':
			case '0':
				[self clearGuessForTileAtRow:currentRow col:currentCol];
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
				intEquivalent = (int)currentChar - 48;
				[self getTileAtRow:currentRow col:currentCol].answer = intEquivalent;
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

- (void)lockAnswers {
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			ZSGameTile *tile = [self getTileAtRow:row col:col];
			
			tile.guess = tile.answer;
			tile.locked = (BOOL)tile.answer;
		}
	}
}

#pragma mark - Getters

- (ZSGameTile *)getTileAtRow:(int)row col:(int)col {
	return [[_tiles objectAtIndex:row] objectAtIndex:col];
}

- (NSArray *)getAllInfluencedTilesForTileAtRow:(int)targetRow col:(int)targetCol includeSelf:(BOOL)includeSelf {
	ZSGameTile *targetTile = [self getTileAtRow:targetRow col:targetCol];
	
	NSMutableArray *influencedTiles = [NSMutableArray array];
	
	// Add the group tiles first. Optionally add self.
	[influencedTiles addObjectsFromArray:[self getFamilySetForTileAtRow:targetRow col:targetCol includeSelf:includeSelf]];
	
	// Add the col tiles. Skip the ones in the same group (including self).
	for (int row = 0; row < size; ++row) {
		ZSGameTile *possibleInfluencedTile = [self getTileAtRow:row col:targetCol];
		
		if (possibleInfluencedTile.groupId != targetTile.groupId) {
			[influencedTiles addObject:possibleInfluencedTile];
		}
	}
	
	// Add the row tiles. Skip the ones in the same group (including self).
	for (int col = 0; col < size; ++col) {
		ZSGameTile *possibleInfluencedTile = [self getTileAtRow:targetRow col:col];
		
		if (possibleInfluencedTile.groupId != targetTile.groupId) {
			[influencedTiles addObject:possibleInfluencedTile];
		}
	}
	
	return influencedTiles;
}

- (NSArray *)getRowSetForTileAtRow:(int)targetRow col:(int)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	for (int row = 0; row < size; ++row) {
		if (includeSelf || row != targetRow) {
			[set addObject:[self getTileAtRow:row col:targetCol]];
		}
	}
	
	return set;
}

- (NSArray *)getColSetForTileAtRow:(int)targetRow col:(int)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	for (int col = 0; col < size; ++col) {
		if (includeSelf || col != targetCol) {
			[set addObject:[self getTileAtRow:targetRow col:col]];
		}
	}
	
	return set;
}

- (NSArray *)getFamilySetForTileAtRow:(int)targetRow col:(int)targetCol includeSelf:(BOOL)includeSelf {
	NSMutableArray *set = [NSMutableArray array];
	
	int targetGroupId = [self getTileAtRow:targetRow col:targetCol].groupId;
	
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			ZSGameTile *gameTile = [self getTileAtRow:row col:col];
			
			if (gameTile.groupId == targetGroupId && (includeSelf || !(row == targetRow && col == targetCol))) {
				[set addObject:gameTile];
			}
		}
	}
	
	return set;
}

- (NSArray *)getSetOfInfluencedTileSetsForTileAtRow:(int)row col:(int)col includeSelf:(BOOL)includeSelf {
	NSMutableArray *sets = [NSMutableArray array];
	
	[sets addObject:[self getRowSetForTileAtRow:row col:col includeSelf:includeSelf]];
	[sets addObject:[self getColSetForTileAtRow:row col:col includeSelf:includeSelf]];
	[sets addObject:[self getFamilySetForTileAtRow:row col:col includeSelf:includeSelf]];
	
	return sets;
}

- (NSArray *)getTileSetForRow:(int)row {
	NSMutableArray *set = [NSMutableArray array];
	
	for (int col = 0; col < size; ++col) {
		[set addObject:[self getTileAtRow:row col:col]];
	}
	
	return set;
}

- (NSArray *)getTileSetForCol:(int)col {
	NSMutableArray *set = [NSMutableArray array];
	
	for (int row = 0; row < size; ++row) {
		[set addObject:[self getTileAtRow:row col:col]];
	}
	
	return set;
}

- (NSArray *)getTileSetForGroup:(int)groupId {
	NSMutableArray *set = [NSMutableArray array];
	
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			ZSGameTile *gameTile = [self getTileAtRow:row col:col];
			
			if (gameTile.groupId == groupId) {
				[set addObject:gameTile];
			}
		}
	}
	
	return set;
}

#pragma mark - Setters

- (void)setAnswer:(int)answer forTileAtRow:(int)row col:(int)col {
	[self setAnswer:answer forTileAtRow:row col:col locked:NO];
}

- (void)setAnswer:(int)answer forTileAtRow:(int)row col:(int)col locked:(BOOL)locked {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	
	if (tile.answer != answer) {
		// Clear all the pencil marks (except the actual answer) from the tile.
		[self setAllPencils:NO forTileAtRow:row col:col];
		
		// Change the guess value.
		tile.answer = answer;
		
		if (locked) {
			tile.guess = answer;
			tile.locked = YES;
		}
	}
}

- (void)clearAnswerForTileAtRow:(int)row col:(int)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	int previousAnswer = tile.answer;
	
	if (previousAnswer) {
		// Clear all the pencil marks (except the actual answer) from the tile.
		[self setAllPencils:NO forTileAtRow:row col:col];
		
		// Change the answer value.
		tile.answer = 0;
		tile.guess = 0;
		tile.locked = NO;
	}
}
	
- (void)setGuess:(int)guess forTileAtRow:(int)row col:(int)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	int previousGuess = tile.guess;
	
	if (tile.guess != guess) {
		// Clear all the pencil marks (except the actual answer) from the tile.
		[self setAllPencils:NO forTileAtRow:row col:col];
		
		// Change the guess value.
		tile.guess = guess;
		
		// Notify the delegate that things changed.
		[delegate guessDidChangeForTile:tile previousGuess:previousGuess];
	}
}

- (void)clearGuessForTileAtRow:(int)row col:(int)col {
	[self setGuess:0 forTileAtRow:row col:col];
}

- (void)setPencil:(BOOL)isSet forPencilNumber:(int)pencilNumber forTileAtRow:(int)row col:(int)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	BOOL previousValue = [tile getPencilForGuess:pencilNumber];
	
	if (isSet != previousValue) {
		// Set the pencil mark.
		[tile setPencil:isSet forGuess:pencilNumber];
		
		// Notify the delegate that things changed.
		[delegate pencilDidChangeForTile:tile pencilNumber:pencilNumber previousSet:previousValue];
	}
}

- (void)setAllPencils:(BOOL)isSet forTileAtRow:(int)row col:(int)col {
	for (int i = 1; i <= size; ++i) {
		[self setPencil:isSet forPencilNumber:i forTileAtRow:row col:col];
	}
}

- (void)clearInfluencedPencilsForTileAtRow:(int)row col:(int)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	
	// Only clear the pencils if there's no guess present.
	if (tile.guess) {
		NSArray *influencedTiles = [self getAllInfluencedTilesForTileAtRow:row col:col includeSelf:NO];
		
		for (ZSGameTile *influencedTile in influencedTiles) {
			if (!influencedTile.guess) {
				[self setPencil:NO forPencilNumber:tile.guess forTileAtRow:influencedTile.row col:influencedTile.col];
			}
		}
	}
}

- (void)addAutoPencils {
	// For the first pass, enable all pencil marks.
	for (int row = 0; row < size; row++) {
		for (int col = 0; col < size; col++) {
			ZSGameTile *tile = [self getTileAtRow:row col:col];
			
			if (!tile.guess) {
				for (int i = 1; i <= size; ++i) {
					[self setPencil:YES forPencilNumber:i forTileAtRow:row col:col];
				}
			}
		}
	}
	
	// Search for all guesses. When one is found, get all the associated tiles and disable pencils for that value.
	for (int row = 0; row < size; row++) {
		for (int col = 0; col < size; col++) {
			[self clearInfluencedPencilsForTileAtRow:row col:col];
		}
	}
}

- (void)lockGuesses {
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			if ([self getTileAtRow:row col:col].guess) {
				[self lockTileAtRow:row col:col];
			}
		}
	}
}

- (void)lockTileAtRow:(int)row col:(int)col {
	ZSGameTile *tile = [self getTileAtRow:row col:col];
	
	tile.guess = tile.answer;
	tile.locked = YES;
}

- (ZSGameSolveResult)solve {
	// Initialize a solver.
	ZSFastGameSolver *solver = [[ZSFastGameSolver alloc] initWithSize:size];
	[solver copyGroupMapFromGameBoard:self];
	[solver copyGuessesFromGameBoard:self];
	
	// Solve the puzzle.
	ZSGameSolveResult result = [solver solve];
	
	// Copy the solution into the answer grid.
	[solver copySolutionToGameBoard:self];
	
	return result;
}

#pragma mark - Validitiy Checks

- (BOOL)isGuess:(int)guess validInRow:(int)x col:(int)y {
	// Cache the target tile's group.
	int targetGroup = [self getTileAtRow:x col:y].groupId;
	
	// Loop over the entire puzzle to find tiles in the same group.
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			ZSGameTile *iteratedTile = [self getTileAtRow:row col:col];
			
			// Find all the tiles in the same row, col, or group as the target tile.
			if (row == x || col == y || iteratedTile.groupId == targetGroup) {
				// If the current tile matches the target's guess, the guess is invalid.
				if (iteratedTile.guess == guess) {
					return NO;
				}
			}
		}
	}
	
	// If we made it through the loop, the guess is valid.
	return YES;
}

- (BOOL)isGuess:(int)guess validInRow:(int)x {
	for (int col = 0; col < 9; col++) {
		if ([self getTileAtRow:x col:col].guess == guess) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isGuess:(int)guess validInCol:(int)y {
	for (int row = 0; row < 9; row++) {
		if ([self getTileAtRow:row col:y].guess == guess) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isGuess:(int)guess validInGroupAtRow:(int)x col:(int)y {
	// Cache the target tile's group.
	int targetGroup = [self getTileAtRow:x col:y].groupId;
	
	// Loop over the entire puzzle to find tiles in the same group.
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			ZSGameTile *iteratedTile = [self getTileAtRow:row col:col];
			
			// Find all the tiles in the same group (excluding the target tile itself).
			if (iteratedTile.groupId == targetGroup && !(row == x && col == y)) {
				if (iteratedTile.guess == guess) {
					return NO;
				}
			}
		}
	}
	
	return YES;
}

- (BOOL)isAnswer:(int)answer validInRow:(int)x col:(int)y {
	// Cache the target tile's group.
	int targetGroup = [self getTileAtRow:x col:y].groupId;
	
	// Loop over the entire puzzle to find tiles in the same group.
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			ZSGameTile *iteratedTile = [self getTileAtRow:row col:col];
			
			// Find all the tiles in the same row, col, or group as the target tile.
			if (row == x || col == y || iteratedTile.groupId == targetGroup) {
				// If the current tile matches the target's guess, the guess is invalid.
				if (iteratedTile.answer == answer) {
					return NO;
				}
			}
		}
	}
	
	// If we made it through the loop, the guess is valid.
	return YES;
}

- (BOOL)isAnswer:(int)answer validInRow:(int)x {
	for (int col = 0; col < 9; col++) {
		if ([self getTileAtRow:x col:col].answer == answer) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isAnswer:(int)answer validInCol:(int)y {
	for (int row = 0; row < 9; row++) {
		if ([self getTileAtRow:row col:y].answer == answer) {
			return NO;
		}
	}
	
	return YES;
}

- (BOOL)isAnswer:(int)answer validInGroupAtRow:(int)x col:(int)y {
	// Cache the target tile's group.
	int targetGroup = [self getTileAtRow:x col:y].groupId;
	
	// Loop over the entire puzzle to find tiles in the same group.
	for (int row = 0; row < size; ++row) {
		for (int col = 0; col < size; ++col) {
			ZSGameTile *iteratedTile = [self getTileAtRow:row col:col];
			
			// Find all the tiles in the same group (excluding the target tile itself).
			if (iteratedTile.groupId == targetGroup && !(row == x && col == y)) {
				if (iteratedTile.answer == answer) {
					return NO;
				}
			}
		}
	}
	
	return YES;
}

#pragma mark - Debug

- (void)print9x9PuzzleAnswers {
	NSLog(@" ");
	for (int row = 0; row < 9; ++row) {
		NSLog(@" %i %i %i | %i %i %i | %i %i %i", [self getTileAtRow:row col:0].answer, [self getTileAtRow:row col:1].answer,
			  [self getTileAtRow:row col:2].answer, [self getTileAtRow:row col:3].answer, [self getTileAtRow:row col:4].answer,
			  [self getTileAtRow:row col:5].answer, [self getTileAtRow:row col:6].answer, [self getTileAtRow:row col:7].answer,
			  [self getTileAtRow:row col:8].answer);
		
		if (row == 2 || row == 5) {
			NSLog(@"-------+-------+-------");
		}
	}
	NSLog(@" ");
}

- (void)print9x9PuzzleGuesses {
	NSLog(@" ");
	for (int row = 0; row < 9; ++row) {
		NSLog(@" %i %i %i | %i %i %i | %i %i %i", [self getTileAtRow:row col:0].guess, [self getTileAtRow:row col:1].guess,
			  [self getTileAtRow:row col:2].guess, [self getTileAtRow:row col:3].guess, [self getTileAtRow:row col:4].guess,
			  [self getTileAtRow:row col:5].guess, [self getTileAtRow:row col:6].guess, [self getTileAtRow:row col:7].guess,
			  [self getTileAtRow:row col:8].guess);
		
		if (row == 2 || row == 5) {
			NSLog(@"-------+-------+-------");
		}
	}
	NSLog(@" ");
}

@end

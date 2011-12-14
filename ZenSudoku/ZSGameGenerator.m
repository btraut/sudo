//
//  ZSGameGenerator.m
//  ZenSudoku
//
//  Created by Brent Traut on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameGenerator.h"
#import "ZSGameSolver.h"
#import "ZSGameController.h"
#import "ZSGame.h"
#import "ZSGameBoard.h"
#import "ZSGameTile.h"

@implementation ZSGameGenerator

- (ZSGame *)generateGameWithDifficulty:(ZSGameDifficulty)difficulty {
	ZSGame *game = [self generateStandard9x9Game];
	game.difficulty = difficulty;
	
	return game;
}

- (ZSGame *)generateStandard9x9Game {
	// Build a fresh game.
	ZSGame *newGame = [ZSGame emptyStandard9x9Game];
	
	// Allocate puzzle memory.
	_reductionGameBoard = [[ZSGameBoard alloc] initWithSize:newGame.gameBoard.size];
	_scratchGameBoard = [[ZSGameBoard alloc] initWithSize:newGame.gameBoard.size];
	
	[_reductionGameBoard copyGroupMapFromGameBoard:newGame.gameBoard];
	[_scratchGameBoard copyGroupMapFromGameBoard:newGame.gameBoard];
	
	// Build a whole puzzle.
	[self buildPuzzleForX:0 y:0];
	
	// Generate a random string of rows and columns to act as our reduction guide.
	NSInteger *reductionCoords = malloc(_reductionGameBoard.size * _reductionGameBoard.size * sizeof(NSInteger));
	[self populateRandomNumberArray:reductionCoords withSize:(_reductionGameBoard.size * _reductionGameBoard.size)];
	
	// Create a solver to use in the loop.
	ZSGameSolver *gameSolver = [[ZSGameSolver alloc] init];
	
	// As long as it doesn't make the solution ambiguous, keep removing tiles.
	for (NSInteger i = 0, iMax = _reductionGameBoard.size * _reductionGameBoard.size; i < iMax; ++i) {
		NSInteger reductionRow = reductionCoords[i] / _reductionGameBoard.size;
		NSInteger reductionCol = reductionCoords[i] % _reductionGameBoard.size;
		
		// Copy the puzzle to the scratch board. We have to keep doing this because the solver keeps solving it.
		[_scratchGameBoard copyAnswersFromGameBoard:_reductionGameBoard];
		
		// If the puzzle is still valid, we can poke another hole in it.
		// If none of the later guesses worked out, set the guess back to 0.
		[_scratchGameBoard clearAnswerForTileAtRow:reductionRow col:reductionCol];
		
		// Attempt to solve the puzzle.
		ZSGameSolveResult solveResults = [gameSolver solveGameBoard:_scratchGameBoard];
		
		// If a single solution is found in the scratch board, apply the reduction to the reduction board.
		if (solveResults == ZSGameSolveResultSucceeded) {
			[_reductionGameBoard clearAnswerForTileAtRow:reductionRow col:reductionCol];
		}
	}
	
	// Do one last copy and solve in the scratch board.
	[_scratchGameBoard copyAnswersFromGameBoard:_reductionGameBoard];
	[gameSolver solveGameBoard:_scratchGameBoard];
	
	// Save the puzzle data into the new game.
	[newGame.gameBoard copyAnswersFromGameBoard:_scratchGameBoard];
	
	for (NSInteger row = 0; row < newGame.gameBoard.size; ++row) {
		for (NSInteger col = 0; col < newGame.gameBoard.size; ++col) {
			if ([_reductionGameBoard getTileAtRow:row col:col].answer) {
				[newGame.gameBoard lockTileAtRow:row col:col];
			}
		}
	}
	
	[newGame.gameBoard print9x9PuzzleAnswers];
	[newGame.gameBoard print9x9PuzzleGuesses];
	
	return newGame;
}

- (BOOL)buildPuzzleForX:(NSInteger)row y:(NSInteger)col {
	// If we've already iterated off the end, the puzzle is complete.
	if (col >= _reductionGameBoard.size) {
		return YES;
	}
	
	// If we've iterated off the right side of the puzzle, instead reset to the next row.
	if (row >= _reductionGameBoard.size) {
		return [self buildPuzzleForX:0 y:(col + 1)];
	}
	
	// If the tile is already solved, move on to the next one to the right.
	if ([_reductionGameBoard getTileAtRow:row col:col].answer != 0) {
		return [self buildPuzzleForX:(row + 1) y:col];
	}
	
	// Now that we've found an empty spot, loop over all the possible guesses.
	NSInteger *randomGuesses = malloc(_reductionGameBoard.size * sizeof(NSInteger));
	[self populateRandomNumberArray:randomGuesses withSize:_reductionGameBoard.size];
	
	for (NSInteger i = 0; i < _reductionGameBoard.size; ++i) {
		NSInteger guess = randomGuesses[i] + 1;
		
		if ([_reductionGameBoard isAnswer:guess validInRow:row col:col]) {
			[_reductionGameBoard setAnswer:guess forTileAtRow:row col:col];
			
			if ([self buildPuzzleForX:(row + 1) y:col]) {
				return YES;
			}
			
			// If none of the later guesses worked out, set the guess back to 0.
			[_reductionGameBoard clearAnswerForTileAtRow:row col:col];
		}
	}
	
	free(randomGuesses);
	
	return NO;
}

- (void)populateRandomNumberArray:(NSInteger *)array withSize:(NSInteger)arraySize {
	// Populate the array.
	for (NSInteger i = 0; i < arraySize; ++i) {
		array[i] = i;
	}
	
	// Shuffle the array.
	NSInteger temp, target1, target2;
	
	for (NSInteger i = 0, timesToShuffle = arraySize * arraySize; i < timesToShuffle; ++i) {
		target1 = arc4random() % arraySize;
		target2 = arc4random() % arraySize;
		
		temp = array[target1];
		array[target1] = array[target2];
		array[target2] = temp;
	}
}

@end
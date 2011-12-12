//
//  ZSGameSolver.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSGameCalculator.h"

typedef enum {
	ZSGameSolveResultSucceeded,
	ZSGameSolveResultFailedNoSolution,
	ZSGameSolveResultFailedMultipleSolutions
} ZSGameSolveResult;

@class ZSGame;

@interface ZSGameSolver : ZSGameCalculator {
	@private
	
	NSInteger **solutionTiles;
	BOOL ***pencils;
}

- (ZSGameSolveResult)solveGame:(ZSGame *)game;
- (ZSGameSolveResult)solveTiles:(NSInteger **)newTiles groupMap:(NSInteger **)newGroupMap size:(NSInteger)newSize;

- (ZSGameSolveResult)solve;

- (void)setGuess:(NSInteger)guess forX:(NSInteger)x y:(NSInteger)y;

- (NSInteger)getTotalAnswers;
- (NSInteger)getTotalDigits;

- (NSInteger)solveOnlyChoice;
- (NSInteger)solveSinglePossibility;
- (NSInteger)eliminatePencilsHiddenSubGroup;
- (ZSGameSolveResult)solveBruteForce;

- (ZSGameSolveResult)solveForX:(NSInteger)x y:(NSInteger)y;

@end

extern NSString * const kExceptionPuzzleHasNoSolution;
extern NSString * const kExceptionPuzzleHasMultipleSolutions;

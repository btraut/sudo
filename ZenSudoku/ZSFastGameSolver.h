//
//  ZSFastGameSolver.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ZSGameSolveResultSucceeded,
	ZSGameSolveResultFailedNoSolution,
	ZSGameSolveResultFailedMultipleSolutions
} ZSGameSolveResult;

@class ZSFastGameBoard;

@interface ZSFastGameSolver : NSObject {
	@private
	
	ZSFastGameBoard *_gameBoard;
	ZSFastGameBoard *_solvedGameBoard;
}

- (ZSGameSolveResult)solveFastGameBoard:(ZSFastGameBoard *)gameBoard;

- (ZSGameSolveResult)solve;

- (NSInteger)solveOnlyChoice;
- (NSInteger)solveSinglePossibility;
- (NSInteger)eliminatePencilsHiddenSubGroup;
- (ZSGameSolveResult)solveBruteForce;

- (ZSGameSolveResult)solveBruteForceForRow:(NSInteger)row col:(NSInteger)col;

@end

extern NSString * const kExceptionPuzzleHasNoSolution;
extern NSString * const kExceptionPuzzleHasMultipleSolutions;

//
//  ZenSudokuLogicTests.m
//  ZenSudokuLogicTests
//
//  Created by Brent Traut on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZenSudokuLogicTests.h"

#import "ZSGame.h"
#import "ZSFastGameSolver.h"
#import "ZSGameController.h"

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

@implementation ZenSudokuLogicTests

- (void)setUp {
    [super setUp];
    
	// Create a game solver.
    _solver = [[ZSFastGameSolver alloc] init];
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testNoSolutions {
	NSInteger **groupMapArray = [ZSGameController alloc2DIntGridWithSize:9];
	
	for (NSInteger row = 0; row < 9; ++row) {
		for (NSInteger col = 0; col < 9; ++col) {
			groupMapArray[row][col] = standard9x9GroupMap[row][col];
		}
	}
	
	ZSGame *newGame = [[ZSGame alloc] initWithSize:9];
	[newGame applyGroupMapArray:groupMapArray];
	[newGame applyAnswersString:@"123456789   123456789   123456789   123456789   123456789   123456789   123456789   123456789   12345678."];
	
	ZSGameSolveResult result = [_solver solveGame:newGame];
	
	STAssertTrue(result == ZSGameSolveResultFailedNoSolution, nil);
	
	[ZSGameController free2DIntGrid:groupMapArray withSize:9];
}

- (void)testMultipleSolutions {
	NSInteger **groupMapArray = [ZSGameController alloc2DIntGridWithSize:9];
	
	for (NSInteger row = 0; row < 9; ++row) {
		for (NSInteger col = 0; col < 9; ++col) {
			groupMapArray[row][col] = standard9x9GroupMap[row][col];
		}
	}
	
	ZSGame *newGame = [[ZSGame alloc] initWithSize:9];
	[newGame applyGroupMapArray:groupMapArray];
	[newGame applyAnswersString:@".........   .........   .........   .........   .........   .........   .........   .........   ........."];
	
	ZSGameSolveResult result = [_solver solveGame:newGame];
	
	STAssertTrue(result == ZSGameSolveResultFailedMultipleSolutions, nil);
	
	[ZSGameController free2DIntGrid:groupMapArray withSize:9];
}

- (void)testMultipleSolutions2 {
	NSInteger **groupMapArray = [ZSGameController alloc2DIntGridWithSize:9];
	
	for (NSInteger row = 0; row < 9; ++row) {
		for (NSInteger col = 0; col < 9; ++col) {
			groupMapArray[row][col] = standard9x9GroupMap[row][col];
		}
	}
	
	ZSGame *newGame = [[ZSGame alloc] initWithSize:9];
	[newGame applyGroupMapArray:groupMapArray];
	[newGame applyAnswersString:@"347...291.1.....3...2.....82...4.8...8513........7....5287.9...............68.9.2"];
	
	ZSGameSolveResult result = [_solver solveGame:newGame];
	
	STAssertTrue(result == ZSGameSolveResultFailedMultipleSolutions, nil);
	
	[ZSGameController free2DIntGrid:groupMapArray withSize:9];
	
}

@end

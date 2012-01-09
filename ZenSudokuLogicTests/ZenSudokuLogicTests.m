//
//  ZenSudokuLogicTests.m
//  ZenSudokuLogicTests
//
//  Created by Brent Traut on 12/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZenSudokuLogicTests.h"

#import "ZSFastGameBoard.h"
#import "ZSFastGameSolver.h"

@implementation ZenSudokuLogicTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

# pragma mark - Test Fast Game Boards

- (void)testSettingGuessesFromString {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"....8..1. ..81..2.3 ...359... ..5.7.... 4...1.... .....253. ......4.. .9...6.28 ..6...9.5"];
	
	STAssertEquals(gameBoard.grid[0][4].guess, 8, nil);
	STAssertEquals(gameBoard.grid[0][7].guess, 1, nil);
	STAssertEquals(gameBoard.grid[3][4].guess, 7, nil);
	STAssertEquals(gameBoard.grid[6][6].guess, 4, nil);
	STAssertEquals(gameBoard.grid[0][0].guess, 0, nil);
	STAssertEquals(gameBoard.grid[8][7].guess, 0, nil);
}

- (void)testAutoPencil {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"....8..1. ..81..2.3 ...359... ..5.7.... 4...1.... .....253. ......4.. .9...6.28 ..6...9.5"];
	
	[gameBoard addAutoPencils];
	
	// Check tile 8-7.
	STAssertEquals(gameBoard.grid[8][7].guess, 0, nil);
	
	STAssertEquals(gameBoard.grid[8][7].totalPencils, 1, nil);
	
	STAssertFalse(gameBoard.grid[8][7].pencils[0], nil);
	STAssertFalse(gameBoard.grid[8][7].pencils[5], nil);
	STAssertTrue(gameBoard.grid[8][7].pencils[6], nil);
	STAssertFalse(gameBoard.grid[8][7].pencils[7], nil);
	
	// Check tile 8-5.
	STAssertEquals(gameBoard.grid[8][5].guess, 0, nil);
	
	STAssertEquals(gameBoard.grid[8][5].totalPencils, 5, nil);
	
	STAssertTrue(gameBoard.grid[8][5].pencils[0], nil);
	STAssertTrue(gameBoard.grid[8][5].pencils[2], nil);
	STAssertTrue(gameBoard.grid[8][5].pencils[3], nil);
	STAssertTrue(gameBoard.grid[8][5].pencils[6], nil);
	STAssertTrue(gameBoard.grid[8][5].pencils[7], nil);
	STAssertFalse(gameBoard.grid[8][5].pencils[8], nil);
}

- (void)testGuessValidation {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"....8..1. ..81..2.3 ...359... ..5.7.... 4...1.... .....253. ......4.. .9...6.28 ..6...9.5"];
	
	STAssertTrue([gameBoard isGuess:7 validInRow:8], nil);
	STAssertTrue([gameBoard isGuess:7 validInCol:7], nil);
	STAssertTrue([gameBoard isGuess:7 validInGroup:8], nil);
	STAssertTrue([gameBoard isGuess:7 validInRow:8 col:7], nil);
	
	STAssertTrue([gameBoard isGuess:4 validInRow:8], nil);
	STAssertTrue([gameBoard isGuess:4 validInCol:7], nil);
	STAssertFalse([gameBoard isGuess:4 validInGroup:8], nil);
	STAssertFalse([gameBoard isGuess:4 validInRow:8 col:7], nil);
	
	STAssertFalse([gameBoard isGuess:3 validInRow:2], nil);
	STAssertFalse([gameBoard isGuess:3 validInCol:3], nil);
	STAssertFalse([gameBoard isGuess:3 validInGroup:1], nil);
	STAssertFalse([gameBoard isGuess:3 validInRow:2 col:3], nil);
}

# pragma mark - Test Solver

- (void)testSingleSolution {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"...7..4.1 9.1..5.3. ....8.... .......7. .3....2.8 7...54... .16.7.... .24.1..5. ...6...2."];
	
	ZSFastGameSolver *solver = [[ZSFastGameSolver alloc] initWithSize:gameBoard.size];
	[solver copyGroupMapFromFastGameBoard:gameBoard];
	[solver copyGuessesFromFastGameBoard:gameBoard];
	
	ZSGameSolveResult result = [solver solve];
	
	// Make sure the solver worked properly.
	STAssertEquals(result, ZSGameSolveResultSucceeded, nil);
	
	[solver copySolutionToFastGameBoard:gameBoard];
	
	// Make sure the full top row is correct.
	STAssertEquals(gameBoard.grid[0][0].guess, 2, nil);
	STAssertEquals(gameBoard.grid[0][1].guess, 5, nil);
	STAssertEquals(gameBoard.grid[0][2].guess, 8, nil);
	STAssertEquals(gameBoard.grid[0][3].guess, 7, nil);
	STAssertEquals(gameBoard.grid[0][4].guess, 3, nil);
	STAssertEquals(gameBoard.grid[0][5].guess, 9, nil);
	STAssertEquals(gameBoard.grid[0][6].guess, 4, nil);
	STAssertEquals(gameBoard.grid[0][7].guess, 6, nil);
	STAssertEquals(gameBoard.grid[0][8].guess, 1, nil);
	
	/*
	 258739461
	 971465832
	 463281597
	 149826375
	 635197248
	 782354619
	 316572984
	 824913756
	 597648123
	*/
}

- (void)testNoSolutions {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"123456789 123456789 123456789 123456789 123456789 123456789 123456789 123456789 12345678."];
	
	ZSFastGameSolver *solver = [[ZSFastGameSolver alloc] initWithSize:gameBoard.size];
	[solver copyGroupMapFromFastGameBoard:gameBoard];
	[solver copyGuessesFromFastGameBoard:gameBoard];
	
	ZSGameSolveResult result = [solver solve];
	
	STAssertEquals(result, ZSGameSolveResultFailedNoSolution, nil);
}

- (void)testMultipleSolutions {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"......... ......... ......... ......... ......... ......... ......... ......... ........."];
	
	ZSFastGameSolver *solver = [[ZSFastGameSolver alloc] initWithSize:gameBoard.size];
	[solver copyGroupMapFromFastGameBoard:gameBoard];
	[solver copyGuessesFromFastGameBoard:gameBoard];
	
	ZSGameSolveResult result = [solver solve];
	
	STAssertEquals(result, ZSGameSolveResultFailedMultipleSolutions, nil);
}

- (void)testMultipleSolutions2 {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"347...291 .1.....3. ..2.....8 2...4.8.. .8513.... ....7.... 5287.9... ......... ...68.9.2"];
	
	ZSFastGameSolver *solver = [[ZSFastGameSolver alloc] initWithSize:gameBoard.size];
	[solver copyGroupMapFromFastGameBoard:gameBoard];
	[solver copyGuessesFromFastGameBoard:gameBoard];
	
	ZSGameSolveResult result = [solver solve];
	
	STAssertEquals(result, ZSGameSolveResultFailedMultipleSolutions, nil);
}

- (void)testEasySolutionOrder {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"....8..1. ..81..2.3 ...359... ..5.7.... 4...1.... .....253. ......4.. .9...6.28 ..6...9.5"];
	
	ZSFastGameSolver *solver = [[ZSFastGameSolver alloc] initWithSize:gameBoard.size];
	[solver copyGroupMapFromFastGameBoard:gameBoard];
	[solver copyGuessesFromFastGameBoard:gameBoard];
	
	NSInteger solved;
	
	// Solve 7 in 8-7.
	solved = [solver solveOnlyChoice];
	STAssertEquals(solved, 1, nil);
	
	// Solve 6 in 6-7.
	// Solve 1 in 6-8.
	// Solve 3 in 7-6.
	solved = [solver solveOnlyChoice];
	STAssertEquals(solved, 3, nil);
	
	// Solve 4 in 7-4.
	solved = [solver solveOnlyChoice];
	STAssertEquals(solved, 1, nil);
	
	// Solve 6 in 1-4.
	// Solve 9 in 5-4.
	solved = [solver solveOnlyChoice];
	STAssertEquals(solved, 2, nil);
	
	// Nothing left to solve.
	solved = [solver solveOnlyChoice];
	STAssertEquals(solved, 0, nil);
}

- (void)testSinglePossibility {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"....8..1. ..816.2.3 ...359... ..5.7.... 4...1.... ....9253. ......461 .9..46328 ..6..1975"];
	
	ZSFastGameSolver *solver = [[ZSFastGameSolver alloc] initWithSize:gameBoard.size];
	[solver copyGroupMapFromFastGameBoard:gameBoard];
	[solver copyGuessesFromFastGameBoard:gameBoard];
	
	NSInteger solved;
	
	// Solve 7 in 8-7.
	solved = [solver solveSinglePossibility];
	STAssertEquals(solved, 6, nil);
}

- (void)testBruteForce {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"....8..1. ..81..2.3 ...359... ..5.7.... 4...1.... .....253. ......4.. .9...6.28 ..6...9.5"];
	
	ZSFastGameSolver *solver = [[ZSFastGameSolver alloc] initWithSize:gameBoard.size];
	[solver copyGroupMapFromFastGameBoard:gameBoard];
	[solver copyGuessesFromFastGameBoard:gameBoard];
	
	ZSGameSolveResult result = [solver solveBruteForce];
	
	STAssertTrue(result == ZSGameSolveResultSucceeded, nil);
	
	[solver copySolutionToFastGameBoard:gameBoard];
	
	STAssertEquals(gameBoard.grid[8][5].guess, 1, nil);
	STAssertEquals(gameBoard.grid[8][6].guess, 9, nil);
	STAssertEquals(gameBoard.grid[8][7].guess, 7, nil);
	STAssertEquals(gameBoard.grid[8][8].guess, 5, nil);
	
	for (NSInteger row = 0; row < gameBoard.size; ++row) {
		for (NSInteger col = 0; col < gameBoard.size; ++col) {
			STAssertTrue(gameBoard.grid[row][col].guess, nil);
		}
	}
}

- (void)testEliminatingPencilsViaHiddenPairs {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"8.1..6.94 3....9.8. 97..8.5.. 547.62.3. 632....5. 198375246 .8362.915 .65198... 2195....8"];
	
	ZSFastGameSolver *solver = [[ZSFastGameSolver alloc] initWithSize:gameBoard.size];
	[solver copyGroupMapFromFastGameBoard:gameBoard];
	[solver copyGuessesFromFastGameBoard:gameBoard];
	
	ZSFastGameBoard *solverGameBoard = [solver getGameBoard];
	
	STAssertTrue(solverGameBoard.grid[2][5].pencils[0], nil);
	STAssertTrue(solverGameBoard.grid[2][5].pencils[2], nil);
	STAssertTrue(solverGameBoard.grid[2][5].pencils[3], nil);
	
	STAssertTrue(solverGameBoard.grid[2][8].pencils[0], nil);
	STAssertTrue(solverGameBoard.grid[2][8].pencils[1], nil);
	STAssertTrue(solverGameBoard.grid[2][8].pencils[2], nil);
	
	STAssertTrue(solverGameBoard.grid[4][3].pencils[3], nil);
	STAssertTrue(solverGameBoard.grid[4][3].pencils[7], nil);
	STAssertTrue(solverGameBoard.grid[4][3].pencils[8], nil);
	
	NSInteger totalEliminatedPencils = [solver eliminatePencilsHiddenSubgroupForSize:2];
	
	STAssertEquals(totalEliminatedPencils, 3, nil);
	
	STAssertTrue(solverGameBoard.grid[2][5].pencils[0], nil);
	STAssertTrue(solverGameBoard.grid[2][5].pencils[2], nil);
	STAssertFalse(solverGameBoard.grid[2][5].pencils[3], nil);
	
	STAssertTrue(solverGameBoard.grid[2][8].pencils[0], nil);
	STAssertFalse(solverGameBoard.grid[2][8].pencils[1], nil);
	STAssertTrue(solverGameBoard.grid[2][8].pencils[2], nil);
	
	STAssertFalse(solverGameBoard.grid[4][3].pencils[3], nil);
	STAssertTrue(solverGameBoard.grid[4][3].pencils[7], nil);
	STAssertTrue(solverGameBoard.grid[4][3].pencils[8], nil);
}

- (void)testEliminatingPencilsViaHiddenTriplets {
	ZSFastGameBoard *gameBoard = [[ZSFastGameBoard alloc] initWithSize:9];
	[gameBoard copyGroupMapFromString:@"000111222 000111222 000111222 333444555 333444555 333444555 666777888 666777888 666777888"];
	[gameBoard copyGuessesFromString:@"5286...49 13649..25 7942.563. ...1..2.. ..78263.. ..25.9.6. 24.3..976 8.97.2413 .7.9.4582"];
	
	ZSFastGameSolver *solver = [[ZSFastGameSolver alloc] initWithSize:gameBoard.size];
	[solver copyGroupMapFromFastGameBoard:gameBoard];
	[solver copyGuessesFromFastGameBoard:gameBoard];
	
	ZSFastGameBoard *solverGameBoard = [solver getGameBoard];
	
	STAssertTrue(solverGameBoard.grid[0][4].pencils[0], nil);
	STAssertTrue(solverGameBoard.grid[0][4].pencils[2], nil);
	STAssertTrue(solverGameBoard.grid[0][4].pencils[6], nil);
	
	NSInteger totalEliminatedPencils = [solver eliminatePencilsHiddenSubgroupForSize:3];
	
	STAssertEquals(totalEliminatedPencils, 1, nil);
	
	STAssertFalse(solverGameBoard.grid[0][4].pencils[0], nil);
	STAssertTrue(solverGameBoard.grid[0][4].pencils[2], nil);
	STAssertTrue(solverGameBoard.grid[0][4].pencils[6], nil);
}

- (void)testCombinationIterator {
	ZSFastGameSolver *solver = [[ZSFastGameSolver alloc] initWithSize:9];
	
	NSInteger *combinationArray = malloc(3 * sizeof(NSInteger));
	BOOL combinationResults = NO;
	
	// Start with combination size 2.
	[solver setFirstCombinationInArray:combinationArray ofLength:2 totalPencils:3];
	
	STAssertEquals(combinationArray[0], 0, nil);
	STAssertEquals(combinationArray[1], 1, nil);
	
	combinationResults = [solver setNextCombinationInArray:combinationArray ofLength:2 totalPencils:3];
	
	STAssertTrue(combinationResults, nil);
	STAssertEquals(combinationArray[0], 0, nil);
	STAssertEquals(combinationArray[1], 2, nil);
	
	combinationResults = [solver setNextCombinationInArray:combinationArray ofLength:2 totalPencils:3];
	
	STAssertTrue(combinationResults, nil);
	STAssertEquals(combinationArray[0], 1, nil);
	STAssertEquals(combinationArray[1], 2, nil);
	
	combinationResults = [solver setNextCombinationInArray:combinationArray ofLength:2 totalPencils:3];
	
	STAssertFalse(combinationResults, nil);
	
	// Now lets try combination size 3.
	[solver setFirstCombinationInArray:combinationArray ofLength:3 totalPencils:4];
	
	STAssertEquals(combinationArray[0], 0, nil);
	STAssertEquals(combinationArray[1], 1, nil);
	STAssertEquals(combinationArray[2], 2, nil);
	
	combinationResults = [solver setNextCombinationInArray:combinationArray ofLength:3 totalPencils:4];
	
	STAssertTrue(combinationResults, nil);
	STAssertEquals(combinationArray[0], 0, nil);
	STAssertEquals(combinationArray[1], 1, nil);
	STAssertEquals(combinationArray[2], 3, nil);
	
	combinationResults = [solver setNextCombinationInArray:combinationArray ofLength:3 totalPencils:4];
	
	STAssertTrue(combinationResults, nil);
	STAssertEquals(combinationArray[0], 0, nil);
	STAssertEquals(combinationArray[1], 2, nil);
	STAssertEquals(combinationArray[2], 3, nil);
	
	combinationResults = [solver setNextCombinationInArray:combinationArray ofLength:3 totalPencils:4];
	
	STAssertTrue(combinationResults, nil);
	STAssertEquals(combinationArray[0], 1, nil);
	STAssertEquals(combinationArray[1], 2, nil);
	STAssertEquals(combinationArray[2], 3, nil);
	
	combinationResults = [solver setNextCombinationInArray:combinationArray ofLength:3 totalPencils:4];
	
	STAssertFalse(combinationResults, nil);
}

@end

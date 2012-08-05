//
//  ZSGameOverRibbonViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 8/4/12.
//
//

#import "ZSRibbonViewController.h"

#import "ZSGame.h"

@interface ZSGameOverRibbonViewController : ZSRibbonViewController

@property (assign) ZSGameDifficulty difficulty;
@property (assign) NSInteger completionTime;
@property (assign) BOOL newRecord;
@property (assign) NSInteger hintsUsed;
@property (assign) NSInteger puzzlesSolved;

@end

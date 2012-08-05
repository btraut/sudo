//
//  ZSChangeDifficultyRibbonViewController.h
//  ZenSudoku
//
//  Created by Brent Traut on 8/4/12.
//
//

#import "ZSRibbonViewController.h"

@protocol ZSChangeDifficultyRibbonViewControllerDelegate <ZSRibbonViewControllerDelegate>

- (void)difficultyWasSelected:(ZSGameDifficulty)difficulty;

@end

@interface ZSChangeDifficultyRibbonViewController : ZSRibbonViewController

@property (weak) id<ZSChangeDifficultyRibbonViewControllerDelegate> delegate;

@property (nonatomic, assign, setter = setHighlightedDifficulty:) ZSGameDifficulty highlightedDifficulty;

@end

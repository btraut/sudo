//
//  ZSGameBookViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/26/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSGameBookViewController.h"

#import "ZSAppDelegate.h"
#import "ZSStatisticsController.h"
#import "ZSGame.h"
#import "ZSGameController.h"
#import "ZSBoardViewController.h"
#import "ZSFoldedCornerViewController.h"
#import "ZSGameViewController.h"
#import "ZSHintViewController.h"
#import "ZSGameOverRibbonViewController.h"

#ifdef FREEVERSION
#import "ZSAdPageViewController.h"
#endif

@interface ZSGameBookViewController () {
	UIImageView *_innerBook;
	
	NSMutableArray *_pages;
	
	ZSGameViewController *_extraGameViewController;
	
	ZSSplashPageViewController *_splashPageViewController;
	
	ZSHintViewController *_hintViewController;
	ZSChangeDifficultyRibbonViewController *_changeDifficultyRibbonViewController;
	ZSGameOverRibbonViewController *_gameOverRibbonViewController;
	
	UISwipeGestureRecognizer *_downSwipeGestureRecognizer;
	UITapGestureRecognizer *_hintTapGestureRecognizer;
	
	NSTimer *_backgroundProcessTimer;
	NSInteger _backgroundProcessTimerCount;
	
	ZSGameDifficulty _previouslyCachedDifficulty;
	
	BOOL _shouldTurnPageAfterRibbonCloses;
	
	NSInteger _gamesInARowWithNoAction;
	
	BOOL _preventedAdOnFirstScreen;
}

@end

@implementation ZSGameBookViewController

@synthesize currentGameViewController = _currentGameViewController;
@synthesize nextGameViewController = _nextGameViewController;
@synthesize lastGameViewController = _lastGameViewController;

@synthesize hintsShown = _hintsShown;
@synthesize ribbonShown = _ribbonShown;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Create the inner part of the book (containing all pages).
	_innerBook = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaperBackgroundWithBoard.png"]];
	_innerBook.frame = CGRectMake(0, 0, 320, 460);
	_innerBook.userInteractionEnabled = YES;
	[self.view addSubview:_innerBook];
	
	// Create the list of pages.
	_pages = [NSMutableArray array];
	
	// Create the splash page view.
	_splashPageViewController = [[ZSSplashPageViewController alloc] init];
	_splashPageViewController.foldedCornerVisibleOnLoad = YES;
	_splashPageViewController.animateCornerWhenPromoted = NO;
	_splashPageViewController.animationDelegate = self;
	[self _addPage:_splashPageViewController];
	
	// Create the game view.
	ZSGame *currentGame;
	
	if ([[ZSGameController sharedInstance] savedGameInProgress]) {
		currentGame = [[ZSGameController sharedInstance] loadSavedGame];
		[[NSUserDefaults standardUserDefaults] setInteger:currentGame.difficulty forKey:kLastPlayedPuzzleDifficulty];
	} else {
		ZSGameDifficulty newGameDifficulty = [[NSUserDefaults standardUserDefaults] integerForKey:kLastPlayedPuzzleDifficulty];
		currentGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:newGameDifficulty];
	}
	
	_nextGameViewController = [[ZSGameViewController alloc] initWithGame:currentGame];
	_nextGameViewController.hintDelegate = self;
	_nextGameViewController.animationDelegate = self;
	_nextGameViewController.difficultyButtonDelegate = self;
	_nextGameViewController.majorGameStateChangeDelegate = self;
	
	[self _addPage:_nextGameViewController];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kDisplayedTutorialNotices] boolValue]) {
		[_nextGameViewController hideTapToChangeDifficultyNoticeAnimated:NO];
	} else {
		[_nextGameViewController showTapToChangeDifficultyNoticeAnimated:NO];
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kDisplayedTutorialNotices];
	}
	
	_currentGameViewController = _nextGameViewController;
	
#ifdef FREEVERSION
	// Create the ad page view.
	ZSAdPageViewController *adPageViewController = [[ZSAdPageViewController alloc] init];
	adPageViewController.animationDelegate = self;
	adPageViewController.animateCornerWhenPromoted = NO;
	adPageViewController.foldedCornerVisibleOnLoad = NO;
	[self _addPage:adPageViewController];
#endif
	
	// Load the page behind the current. Yet another page will be loaded when the current page is done animating.
	ZSGameDifficulty newGameDifficulty = [[NSUserDefaults standardUserDefaults] integerForKey:kLastPlayedPuzzleDifficulty];
	ZSGame *newGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:newGameDifficulty];
	
	_nextGameViewController = [[ZSGameViewController alloc] initWithGame:newGame];
	_nextGameViewController.hintDelegate = self;
	_nextGameViewController.animationDelegate = self;
	_nextGameViewController.difficultyButtonDelegate = self;
	_nextGameViewController.majorGameStateChangeDelegate = self;
	
	[self _addPage:_nextGameViewController];
	
	[_nextGameViewController hideTapToChangeDifficultyNoticeAnimated:NO];
	
	// Create the page curl gradient on the left.
	UIImageView *pageCurlGradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PageCurlGradient.png"]];
	pageCurlGradient.frame = CGRectMake(0, 0, 17, 460);
	[_innerBook addSubview:pageCurlGradient];
	
	// Create the page curl on the left. This needs to go over the top of the folded corner.
	UIImageView *pageCurl = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PageCurl.png"]];
	pageCurl.frame = CGRectMake(0, 0, 17, 460);
	[_innerBook addSubview:pageCurl];
	
	// Create the hint.
	_hintViewController = [[ZSHintViewController alloc] initWithNibName:@"ZSHintViewController" bundle:[NSBundle mainBundle]];
	_hintViewController.view.frame = CGRectMake(-5, _innerBook.frame.size.height, _hintViewController.view.frame.size.width, _hintViewController.view.frame.size.height);
	[self.view addSubview:_hintViewController.view];
	
	_downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideHint)];
	_downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
	
	_hintTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHint)];
	
	// Create the ribbons.
	_changeDifficultyRibbonViewController = [[ZSChangeDifficultyRibbonViewController alloc] init];
	_changeDifficultyRibbonViewController.delegate = self;
	
	_gameOverRibbonViewController = [[ZSGameOverRibbonViewController alloc] init];
	_gameOverRibbonViewController.delegate = self;
	
	// Start the background process timer.
	_backgroundProcessTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_backgroundProcessTimerDidAdvance:) userInfo:nil repeats:YES];
	_backgroundProcessTimerCount = 0;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[_splashPageViewController dismiss];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	if (_pages.count) {
		ZSFoldedPageViewController *firstPage = [_pages objectAtIndex:0];
		[firstPage applicationWillResignActive:application];
	}
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	if (_pages.count) {
		ZSFoldedPageViewController *firstPage = [_pages objectAtIndex:0];
		[firstPage applicationDidBecomeActive:application];
	}
}

- (void)_loadNewGame {
	ZSGameDifficulty newGameDifficulty = [[NSUserDefaults standardUserDefaults] integerForKey:kLastPlayedPuzzleDifficulty];
	ZSGame *newGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:newGameDifficulty];
	
	if (_extraGameViewController) {
		_lastGameViewController = _extraGameViewController;
		_extraGameViewController = nil;
		
		[_lastGameViewController resetWithGame:newGame];
	} else {
		_lastGameViewController = [[ZSGameViewController alloc] initWithGame:newGame];
		_lastGameViewController.hintDelegate = self;
		_lastGameViewController.animationDelegate = self;
		_lastGameViewController.difficultyButtonDelegate = self;
		_lastGameViewController.majorGameStateChangeDelegate = self;
	}
	
	[self _addPage:_lastGameViewController];
	
	if (_gamesInARowWithNoAction > 2) {
		[_lastGameViewController showTapToChangeDifficultyNoticeAnimated:NO];
	} else {
		[_lastGameViewController hideTapToChangeDifficultyNoticeAnimated:NO];
	}
}

- (void)showHint {
	if (_hintsShown) {
		return;
	}
	
	_hintsShown = YES;
	
	++self.currentGameViewController.game.totalHints;
	[[ZSStatisticsController sharedInstance] userUsedHint];
	
	self.currentGameViewController.foldedCornerViewController.view.userInteractionEnabled = NO;
	
	[self.view addGestureRecognizer:_downSwipeGestureRecognizer];
	[_innerBook addGestureRecognizer:_hintTapGestureRecognizer];
	
	[UIView
	 animateWithDuration:0.4f
	 delay:0
	 options:UIViewAnimationOptionCurveEaseOut
	 animations:^{
		 _hintViewController.view.frame = CGRectMake(-5, 339, _hintViewController.view.frame.size.width, _hintViewController.view.frame.size.height);
		 _innerBook.frame = CGRectMake(0, -45, _innerBook.frame.size.width, _innerBook.frame.size.height);
	 }
	 completion:NULL];
}

- (void)hideHint {
	if (!_hintsShown) {
		return;
	}
	
	_hintsShown = NO;
	
	self.currentGameViewController.foldedCornerViewController.view.userInteractionEnabled = YES;
	
	[self.view removeGestureRecognizer:_downSwipeGestureRecognizer];
	[_innerBook removeGestureRecognizer:_hintTapGestureRecognizer];
	
	[self.currentGameViewController.boardViewController removeAllHintHighlights];
	
	[self.currentGameViewController completeCoreGameOperation];
	
	[UIView
	 animateWithDuration:0.4f
	 delay:0
	 options:UIViewAnimationOptionCurveEaseOut
	 animations:^{
		 _hintViewController.view.frame = CGRectMake(-5, _innerBook.frame.size.height, _hintViewController.view.frame.size.width, _hintViewController.view.frame.size.height);
		 _innerBook.frame = CGRectMake(0, 0, _innerBook.frame.size.width, _innerBook.frame.size.height);
	 }
	 completion:NULL];
}

- (void)showChangeDifficultyRibbon {
	if (_changeDifficultyRibbonViewController.shown) {
		return;
	}
	
	[self.view addSubview:_changeDifficultyRibbonViewController.view];
	
	_changeDifficultyRibbonViewController.highlightedDifficulty = self.currentGameViewController.game.difficulty;
	[_changeDifficultyRibbonViewController showRibbon];
}

- (void)hideChangeDifficultyRibbon {
	if (!_changeDifficultyRibbonViewController.shown) {
		return;
	}
	
	[_changeDifficultyRibbonViewController hideRibbon];
}

- (void)showGameOverRibbon {
	if (_gameOverRibbonViewController.shown) {
		return;
	}
	
	[self.view addSubview:_gameOverRibbonViewController.view];
	
	_gameOverRibbonViewController.difficulty = self.currentGameViewController.game.difficulty;
	_gameOverRibbonViewController.completionTime = self.currentGameViewController.game.timerCount;
	_gameOverRibbonViewController.hintsUsed = self.currentGameViewController.game.totalHints;
	_gameOverRibbonViewController.newRecord = [ZSStatisticsController sharedInstance].lastGameWasTimeRecord;
	
	switch (self.currentGameViewController.game.difficulty) {
		case ZSGameDifficultyEasy: _gameOverRibbonViewController.puzzlesSolved = [ZSStatisticsController sharedInstance].gamesSolvedPerEasy; break;
		case ZSGameDifficultyModerate: _gameOverRibbonViewController.puzzlesSolved = [ZSStatisticsController sharedInstance].gamesSolvedPerModerate; break;
		case ZSGameDifficultyChallenging: _gameOverRibbonViewController.puzzlesSolved = [ZSStatisticsController sharedInstance].gamesSolvedPerChallenging; break;
		case ZSGameDifficultyDiabolical: _gameOverRibbonViewController.puzzlesSolved = [ZSStatisticsController sharedInstance].gamesSolvedPerDiabolical; break;
		case ZSGameDifficultyInsane: _gameOverRibbonViewController.puzzlesSolved = [ZSStatisticsController sharedInstance].gamesSolvedPerInsane; break;
	}
	
	[_gameOverRibbonViewController showRibbon];
}

- (void)hideGameOverRibbon {
	if (!_gameOverRibbonViewController.shown) {
		return;
	}
	
	[_gameOverRibbonViewController hideRibbon];
}

- (void)_backgroundProcessTimerDidAdvance:(NSTimer *)timer {
	++_backgroundProcessTimerCount;
	
	if (_backgroundProcessTimerCount % 10 == 0) {
		switch (_previouslyCachedDifficulty) {
			case ZSGameDifficultyInsane:
				_previouslyCachedDifficulty = ZSGameDifficultyEasy;
				break;
				
			default:
				++_previouslyCachedDifficulty;
				break;
		}
		
		// NSLog(@"Populating cache, difficulty %i.", _previouslyCachedDifficulty);
		[[ZSGameController sharedInstance] populateCacheForDifficulty:_previouslyCachedDifficulty synchronous:NO];
	}
}

- (void)_setHiddenOnTapToChangeDifficultyNotices {
	if (self.currentGameViewController.actionWasMadeOnPuzzle) {
		_gamesInARowWithNoAction = 0;
	}
	
	if (_gamesInARowWithNoAction > 2) {
		[self.nextGameViewController showTapToChangeDifficultyNoticeAnimated:NO];
		[self.lastGameViewController showTapToChangeDifficultyNoticeAnimated:NO];
	} else {
		[self.nextGameViewController hideTapToChangeDifficultyNoticeAnimated:NO];
		[self.lastGameViewController hideTapToChangeDifficultyNoticeAnimated:NO];
	}
}

#pragma mark - Page Management

- (void)_addPage:(ZSFoldedPageViewController *)page {
	if (_pages.count) {
		ZSFoldedPageViewController *lastPage = [_pages lastObject];
		[_innerBook insertSubview:page.view belowSubview:lastPage.view];
	} else {
		[_innerBook addSubview:page.view];
	}
	
	[_pages addObject:page];
	
	if (_pages.count == 1) {
		[page viewWasPromotedToFront];
	}
}

- (void)_insertPage:(ZSFoldedPageViewController *)page atIndex:(NSInteger)index {
	if (index > _pages.count) {
		index = _pages.count;
	}
	
	if (_pages.count) {
		ZSFoldedPageViewController *nextPage = [_pages objectAtIndex:index];
		[_innerBook insertSubview:page.view aboveSubview:nextPage.view];
	} else {
		[_innerBook addSubview:page.view];
	}
	
	[_pages insertObject:page atIndex:index];
	
	if (_pages.count == 1) {
		[page viewWasPromotedToFront];
	}
}

- (void)_pageWasTurned {
	ZSFoldedPageViewController *firstPage = [_pages objectAtIndex:0];
	
	[_pages removeObjectAtIndex:0];
	[firstPage.view removeFromSuperview];
	[firstPage viewWasRemovedFromBook];
	
	if (_pages.count) {
		ZSFoldedPageViewController *nextPage = [_pages objectAtIndex:0];
		[nextPage viewWasPromotedToFront];
	}
}

#pragma mark - ZSFoldedPageViewControllerAnimationDelegate Implementation

- (void)pageTurnAnimationDidFinishWithViewController:(ZSFoldedPageViewController *)viewController {
	if (self.currentGameViewController.actionWasMadeOnPuzzle) {
		_gamesInARowWithNoAction = 0;
	} else {
		++_gamesInARowWithNoAction;
	}
	
	self.currentGameViewController.animateCornerWhenPromoted = YES;
	
	// If the page being removed is a game, we want to save the controller so we can reuse it later.
	if ([viewController isKindOfClass:[ZSGameViewController class]]) {
		// Shift our page bookkeeping forward.
		_extraGameViewController = _currentGameViewController;
		_currentGameViewController = _nextGameViewController;
		_nextGameViewController = _lastGameViewController;
		_lastGameViewController = nil;
	}
	
#ifdef FREEVERSION
	ZSAdPageViewController *savedAdPageViewController = nil;
	
	if ([viewController isKindOfClass:[ZSAdPageViewController class]]) {
		savedAdPageViewController = (ZSAdPageViewController *)viewController;
	}
#endif
	
	[self _pageWasTurned];
	
#ifdef FREEVERSION
	if (savedAdPageViewController) {
		[self _insertPage:savedAdPageViewController atIndex:1];
	}
#endif
}

#pragma mark - ZSFoldedPageAndPlusButtonViewControllerAnimationDelegate Implementation

- (void)plusButtonStartAnimationDidFinishWithViewController:(ZSGameViewController *)viewController {
	// Load a new game into the recycled view controller.
	[self _loadNewGame];
}

- (void)userBeganDraggingFoldedCornerWithViewController:(ZSGameViewController *)viewController {
	[self _setHiddenOnTapToChangeDifficultyNotices];
}

#pragma mark - ZSHintDelegate Implementation

- (BOOL)getHintsShown {
	return _hintsShown;
}

- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController {
	[_hintViewController beginHintDeck:hintDeck forGameViewController:gameViewController];
	[self showHint];
}

- (void)endHintDeck {
	[self hideHint];
}

#pragma mark - ZSChangeDifficultyRibbonViewControllerDelegate Implementation

- (void)difficultyWasSelected:(ZSGameDifficulty)difficulty {
	if (difficulty != self.nextGameViewController.game.difficulty) {
		ZSGame *newNextGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:difficulty];
		[self.nextGameViewController resetWithGame:newNextGame];
		
		ZSGame *newLastGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:difficulty];
		[self.lastGameViewController resetWithGame:newLastGame];
		
		[[NSUserDefaults standardUserDefaults] setInteger:difficulty forKey:kLastPlayedPuzzleDifficulty];
		
		_shouldTurnPageAfterRibbonCloses = YES;
	}
}

- (void)hideRibbonAnimationDidFinish {
	// Both ribbons call the same delegate, so we'll just remove them both.
	[_gameOverRibbonViewController.view removeFromSuperview];
	[_changeDifficultyRibbonViewController.view removeFromSuperview];
	
	// If the user picked a new difficulty, turn the page.
	if (_shouldTurnPageAfterRibbonCloses) {
		_shouldTurnPageAfterRibbonCloses = NO;
		
		[self.currentGameViewController turnPage];
	}
}

#pragma mark - ZSDifficultyButtonViewControllerDelegate Implementation

- (void)difficultyButtonWasPressedWithViewController:(ZSGameViewController *)viewController {
	[self showChangeDifficultyRibbon];
	
	_gamesInARowWithNoAction = 0;
	[self _setHiddenOnTapToChangeDifficultyNotices];
}

#pragma mark - ZSMajorGameStateChangeDelegate Implementation

- (void)gameWasSolvedWithViewController:(ZSGameViewController *)viewController {
	if (_hintsShown) {
		[self hideHint];
	}
	
	[self showGameOverRibbon];
}


@end

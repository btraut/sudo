//
//  ZSGameBookViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/26/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSGameBookViewController.h"

#import "ZSGameController.h"
#import "ZSGame.h"
#import "ZSGameViewController.h"
#import "ZSBoardViewController.h"
#import "ZSHintViewController.h"
#import "ZSFoldedCornerViewController.h"
#import "ZSAppDelegate.h"

@interface ZSGameBookViewController () {
	UIImageView *_innerBook;
	
	ZSHintViewController *_hintViewController;
	ZSRibbonViewController *_ribbonViewController;
	
	ZSSplashPageViewController *_splashPageViewController;
	
	UISwipeGestureRecognizer *_downSwipeGestureRecognizer;
	UITapGestureRecognizer *_hintTapGestureRecognizer;
	
	NSTimer *_backgroundProcessTimer;
	NSInteger _backgroundProcessTimerCount;
	
	ZSGameDifficulty _previouslyCachedDifficulty;
	
	BOOL _shouldTurnPageAfterRibbonCloses;
	
	NSInteger _gamesInARowWithNoAction;
}

@end

@implementation ZSGameBookViewController

@synthesize currentGameViewController, nextGameViewController, lastGameViewController, extraGameViewController;
@synthesize hintsShown = _hintsShown;
@synthesize ribbonShown = _ribbonShown;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Create the inner part of the book (containing all pages).
	_innerBook = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaperBackgroundWithBoard.png"]];
	_innerBook.frame = CGRectMake(0, 0, 320, 460);
	_innerBook.userInteractionEnabled = YES;
	[self.view addSubview:_innerBook];
	
	// Create the game view.
	ZSGame *currentGame;
	
	if ([[ZSGameController sharedInstance] savedGameInProgress]) {
		currentGame = [[ZSGameController sharedInstance] loadSavedGame];
		[[NSUserDefaults standardUserDefaults] setInteger:currentGame.difficulty forKey:kLastPlayedPuzzleDifficulty];
	} else {
		ZSGameDifficulty newGameDifficulty = [[NSUserDefaults standardUserDefaults] integerForKey:kLastPlayedPuzzleDifficulty];
		currentGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:newGameDifficulty];
	}
	
	self.currentGameViewController = [[ZSGameViewController alloc] initWithGame:currentGame];
	self.currentGameViewController.hintDelegate = self;
	self.currentGameViewController.animationDelegate = self;
	self.currentGameViewController.difficultyButtonDelegate = self;
	[_innerBook addSubview:self.currentGameViewController.view];
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:kDisplayedTutorialNotices] boolValue]) {
		[self.currentGameViewController hideTapToChangeDifficultyNoticeAnimated:NO];
	} else {
		[self.currentGameViewController showTapToChangeDifficultyNoticeAnimated:NO];
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kDisplayedTutorialNotices];
	}
	
	// Load the page behind the current. Yet another page will be loaded when the current page is done animating.
	ZSGameDifficulty newGameDifficulty = [[NSUserDefaults standardUserDefaults] integerForKey:kLastPlayedPuzzleDifficulty];
	ZSGame *newGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:newGameDifficulty];
	
	self.nextGameViewController = [[ZSGameViewController alloc] initWithGame:newGame];
	self.nextGameViewController.hintDelegate = self;
	self.nextGameViewController.animationDelegate = self;
	self.nextGameViewController.difficultyButtonDelegate = self;
	[_innerBook insertSubview:self.nextGameViewController.view belowSubview:self.currentGameViewController.view];
	
	[self.nextGameViewController hideTapToChangeDifficultyNoticeAnimated:NO];
	
	// Create the splash page view.
	_splashPageViewController = [[ZSSplashPageViewController alloc] init];
	_splashPageViewController.foldedCornerVisibleOnLoad = YES;
	_splashPageViewController.animationDelegate = self;
	[_innerBook addSubview:_splashPageViewController.view];
	
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
	
	// Create the ribbon.
	_ribbonViewController = [[ZSRibbonViewController alloc] init];
	_ribbonViewController.delegate = self;
	
	// Start the background process timer.
	_backgroundProcessTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_backgroundProcessTimerDidAdvance:) userInfo:nil repeats:YES];
	_backgroundProcessTimerCount = 0;
}

- (void)_loadNewGame {
	ZSGameDifficulty newGameDifficulty = [[NSUserDefaults standardUserDefaults] integerForKey:kLastPlayedPuzzleDifficulty];
	ZSGame *newGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:newGameDifficulty];
	
	if (self.extraGameViewController) {
		self.lastGameViewController = self.extraGameViewController;
		self.extraGameViewController = nil;
		
		[self.lastGameViewController resetWithGame:newGame];
	} else {
		self.lastGameViewController = [[ZSGameViewController alloc] initWithGame:newGame];
		self.lastGameViewController.hintDelegate = self;
		self.lastGameViewController.animationDelegate = self;
		self.lastGameViewController.difficultyButtonDelegate = self;
	}

	[_innerBook insertSubview:self.lastGameViewController.view belowSubview:self.nextGameViewController.view];
	
	if (_gamesInARowWithNoAction > 2) {
		[self.lastGameViewController showTapToChangeDifficultyNoticeAnimated:NO];
	} else {
		[self.lastGameViewController hideTapToChangeDifficultyNoticeAnimated:NO];
	}
}

- (void)showHint {
	if (_hintsShown) {
		return;
	}
	
	_hintsShown = YES;
	
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

- (void)showRibbon {
	if (_ribbonViewController.shown) {
		return;
	}
	
	[self.view addSubview:_ribbonViewController.view];
	
	[_ribbonViewController showRibbon];
}

- (void)hideRibbon {
	if (!_ribbonViewController.shown) {
		return;
	}
	
	[_ribbonViewController hideRibbon];
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

#pragma mark - ZSFoldedPageViewControllerAnimationDelegate Implementation

- (void)pageTurnAnimationDidFinishWithViewController:(ZSFoldedPageViewController *)viewController {
	if (self.currentGameViewController.actionWasMadeOnPuzzle) {
		_gamesInARowWithNoAction = 0;
	} else {
		++_gamesInARowWithNoAction;
	}
	
	self.currentGameViewController.animateCornerWhenPromoted = YES;
	
	if (viewController == _splashPageViewController) {
		[_splashPageViewController.view removeFromSuperview];
		_splashPageViewController = nil;
		
		[self.currentGameViewController viewWasPromotedToFront];
	} else {
		// Get the previous game out of the way.
		[self.currentGameViewController.view removeFromSuperview];
		
		// Swap the next game view controller for the current. We'll recycle the old one so we don't need to reinitialize.
		self.extraGameViewController = self.currentGameViewController;
		
		// Promote the other view controllers.
		self.currentGameViewController = self.nextGameViewController;
		self.nextGameViewController = self.lastGameViewController;
		self.lastGameViewController = nil;
		
		// Fire up the new game.
		[self.currentGameViewController viewWasPromotedToFront];
	}
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

#pragma mark - ZSRibbonViewControllerDelegate Implementation

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
	[_ribbonViewController.view removeFromSuperview];
	
	if (_shouldTurnPageAfterRibbonCloses) {
		_shouldTurnPageAfterRibbonCloses = NO;
		
		[self.currentGameViewController turnPage];
	}
}

#pragma mark - ZSDifficultyButtonViewControllerDelegate Implementation

- (void)difficultyButtonWasPressedWithViewController:(ZSGameViewController *)viewController {
	[self showRibbon];
	
	_gamesInARowWithNoAction = 0;
	[self _setHiddenOnTapToChangeDifficultyNotices];
}

@end

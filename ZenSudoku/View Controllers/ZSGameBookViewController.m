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

@interface ZSGameBookViewController () {
	UIImageView *_innerBook;
	
	UISwipeGestureRecognizer *_downSwipeGestureRecognizer;
	UITapGestureRecognizer *_tapGestureRecognizer;
}

@end

@implementation ZSGameBookViewController

@synthesize currentGameViewController, nextGameViewController, tempGameViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Create the inner part of the book (containing all pages).
	_innerBook = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaperBackground.png"]];
	_innerBook.frame = CGRectMake(0, 0, 320, 460);
	_innerBook.userInteractionEnabled = YES;
	[self.view addSubview:_innerBook];
	
	// Create the game view.
	ZSGame *currentGame;
	
	if ([[ZSGameController sharedInstance] savedGameInProgress]) {
		currentGame = [[ZSGameController sharedInstance] loadSavedGame];
	} else {
		ZSGameDifficulty randomDifficulty = arc4random() % 5;
		currentGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:randomDifficulty];
	}
	
	currentGameViewController = [[ZSGameViewController alloc] initWithGame:currentGame];
	currentGameViewController.hintDelegate = self;
	currentGameViewController.majorGameStateDelegate = self;
	currentGameViewController.foldedCornerVisibleOnLoad = YES;
	[_innerBook addSubview:currentGameViewController.view];
	
	[currentGameViewController viewWasPromotedToFrontAnimated:NO];
	
	// Create the new next game view.
	[self loadNewNextGame];
	
	// Create the page curl gradient on the left.
	UIImageView *pageCurlGradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PageCurlGradient.png"]];
	pageCurlGradient.frame = CGRectMake(0, 0, 17, 460);
	[_innerBook addSubview:pageCurlGradient];
	
	// Create the page curl on the left. This needs to go over the top of the folded corner.
	UIImageView *pageCurl = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PageCurl.png"]];
	pageCurl.frame = CGRectMake(0, 0, 17, 460);
	[_innerBook addSubview:pageCurl];
	
	// Create the hint.
	hintViewController = [[ZSHintViewController alloc] initWithNibName:@"ZSHintViewController" bundle:[NSBundle mainBundle]];
	hintViewController.view.frame = CGRectMake(-5, _innerBook.frame.size.height, hintViewController.view.frame.size.width, hintViewController.view.frame.size.height);
	[self.view addSubview:hintViewController.view];
	
	_downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideHint)];
	_downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
	
	_tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHint)];
}

- (void)startNewGame {
	// Get the previous game out of the way.
	[self.currentGameViewController.view removeFromSuperview];
	
	// Swap the next game view controller for the current. We'll recycle the old one so we don't need to reinitialize.
	self.tempGameViewController = currentGameViewController;
	self.currentGameViewController = self.nextGameViewController;
	
	// Fire up the new game.
	[self.currentGameViewController viewWasPromotedToFrontAnimated:YES];
}

- (void)frontViewControllerFinishedDisplaying {
	// Load a new game into the recycled view controller.
	[self loadNewNextGame];
}

- (void)loadNewNextGame {
	ZSGameDifficulty randomDifficulty = arc4random() % 5;
	ZSGame *newGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:randomDifficulty];
	
	if (self.tempGameViewController) {
		self.nextGameViewController = self.tempGameViewController;
		self.tempGameViewController = nil;
		
		[self.nextGameViewController resetWithGame:newGame];
	} else {
		self.nextGameViewController = [[ZSGameViewController alloc] initWithGame:newGame];
		nextGameViewController.hintDelegate = self;
		nextGameViewController.majorGameStateDelegate = self;
	}

	[_innerBook insertSubview:self.nextGameViewController.view belowSubview:self.currentGameViewController.view];
}

- (BOOL)getHintsShown {
	return hintsShown;
}

- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController {
	[hintViewController beginHintDeck:hintDeck forGameViewController:gameViewController];
	[self showHint];
}

- (void)endHintDeck {
	[self hideHint];
}

- (void)showHint {
	if (hintsShown) {
		return;
	}
	
	hintsShown = YES;
	
	self.currentGameViewController.foldedCornerViewController.view.userInteractionEnabled = NO;
	
	[self.view addGestureRecognizer:_downSwipeGestureRecognizer];
	[_innerBook addGestureRecognizer:_tapGestureRecognizer];
	
	[UIView
	 animateWithDuration:0.4f
	 delay:0
	 options:UIViewAnimationOptionCurveEaseOut
	 animations:^{
		 hintViewController.view.frame = CGRectMake(-5, 339, hintViewController.view.frame.size.width, hintViewController.view.frame.size.height);
		 _innerBook.frame = CGRectMake(0, -45, _innerBook.frame.size.width, _innerBook.frame.size.height);
	 }
	 completion:NULL];
}

- (void)hideHint {
	if (!hintsShown) {
		return;
	}
	
	hintsShown = NO;
	
	self.currentGameViewController.foldedCornerViewController.view.userInteractionEnabled = YES;
	
	[self.view removeGestureRecognizer:_downSwipeGestureRecognizer];
	[_innerBook removeGestureRecognizer:_tapGestureRecognizer];
	
	[currentGameViewController.boardViewController removeAllHintHighlights];
	
	[currentGameViewController completeCoreGameOperation];
	
	[UIView
		animateWithDuration:0.4f
		delay:0
		options:UIViewAnimationOptionCurveEaseOut
		animations:^{
			hintViewController.view.frame = CGRectMake(-5, _innerBook.frame.size.height, hintViewController.view.frame.size.width, hintViewController.view.frame.size.height);
			_innerBook.frame = CGRectMake(0, 0, _innerBook.frame.size.width, _innerBook.frame.size.height);
		}
		completion:NULL];
}

@end

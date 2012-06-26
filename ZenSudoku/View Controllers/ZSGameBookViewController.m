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
#import "ZSGameBoardViewController.h"
#import "ZSHintViewController.h"
#import "ZSFoldedCornerViewController.h"

@implementation ZSGameBookViewController

@synthesize currentGameViewController, nextGameViewController, tempGameViewController;

- (void)loadView {
	self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaperBackground.png"]];
	self.view.frame = CGRectMake(0, 0, 320, 460);
	self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
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
	[self.view addSubview:currentGameViewController.view];
	
	[currentGameViewController viewWasPromotedToFrontAnimated:NO];
	
	// Create the new next game view.
	[self loadNewNextGame];
	
	// Create the page curl gradient on the left.
	UIImageView *pageCurlGradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PageCurlGradient.png"]];
	pageCurlGradient.frame = CGRectMake(0, 0, 17, 460);
	[self.view addSubview:pageCurlGradient];
	
	// Create the page curl on the left. This needs to go over the top of the folded corner.
	UIImageView *pageCurl = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PageCurl.png"]];
	pageCurl.frame = CGRectMake(0, 0, 17, 460);
	[self.view addSubview:pageCurl];
	
	// Create the hint.
	hintViewController = [[ZSHintViewController alloc] initWithNibName:@"ZSHintViewController" bundle:[NSBundle mainBundle]];
	hintViewController.view.frame = CGRectMake(0, 480, hintViewController.view.frame.size.width, hintViewController.view.frame.size.height);
	[self.view addSubview:hintViewController.view];
}

- (void)startNewGame {
	// Get the previous game out of the way.
	[self.currentGameViewController.view removeFromSuperview];
	
	// Swap the next game view controller for the current. We'll recycle the old one so we don't need to reinitialize.
	self.tempGameViewController = currentGameViewController;
	self.currentGameViewController = self.nextGameViewController;
	
	// Fire up the new game.
	[currentGameViewController viewWasPromotedToFrontAnimated:YES];
}

- (void)frontViewControllerFinishedDisplaying {
	// Load a new game into the recycled view controller.
	[self loadNewNextGame];
}

- (void)loadNewNextGame {
	NSLog(@"Loading new game!");
	
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

	[self.view insertSubview:self.nextGameViewController.view belowSubview:self.currentGameViewController.view];
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
	
	[UIView
	 animateWithDuration:0.4f
	 delay:0
	 options:UIViewAnimationOptionCurveEaseOut
	 animations:^{
		 hintViewController.view.frame = CGRectMake(0, 310, hintViewController.view.frame.size.width, hintViewController.view.frame.size.height);
		 currentGameViewController.view.frame = CGRectMake(0, -45, currentGameViewController.view.frame.size.width, currentGameViewController.view.frame.size.height);
	 }
	 completion:NULL];
}

- (void)hideHint {
	if (!hintsShown) {
		return;
	}
	
	hintsShown = NO;
	
	[currentGameViewController.gameBoardViewController removeAllHintHighlights];
	
	[UIView
		animateWithDuration:0.4f
		delay:0
		options:UIViewAnimationOptionCurveEaseOut
		animations:^{
			hintViewController.view.frame = CGRectMake(0, 480, hintViewController.view.frame.size.width, hintViewController.view.frame.size.height);
			currentGameViewController.view.frame = CGRectMake(0, 0, currentGameViewController.view.frame.size.width, currentGameViewController.view.frame.size.height);
		}
		completion:NULL];
}

@end

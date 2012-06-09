//
//  ZSGameBookViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSGameBookViewController.h"

#import "ZSGameController.h"
#import "ZSGame.h"
#import "ZSGameViewController.h"
#import "ZSGameBoardViewController.h"
#import "ZSHintViewController.h"
#import "ZSFoldedCornerView.h"
#import "ZSFoldedPageView.h"

@implementation ZSGameBookViewController

@synthesize currentGameViewController, nextGameViewController;

- (void)loadView {
	self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PaperBackground.png"]];
	self.view.frame = CGRectMake(0, 0, 320, 460);
	self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Create the new game view.
	ZSGame *newGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:ZSGameDifficultyDiabolical];
	nextGameViewController = [[ZSGameViewController alloc] initWithGame:newGame];
	nextGameViewController.hintDelegate = self;
	[self.view addSubview:nextGameViewController.view];
	
	// Create the game view.
	ZSGame *currentGame;
	
	if (false && [[ZSGameController sharedInstance] savedGameInProgress]) {
		currentGame = [[ZSGameController sharedInstance] loadSavedGame];
	} else {
		currentGame = [[ZSGameController sharedInstance] fetchGameWithDifficulty:ZSGameDifficultyDiabolical];
	}
	
	currentGameViewController = [[ZSGameViewController alloc] initWithGame:currentGame];
	currentGameViewController.hintDelegate = self;
	[self.view addSubview:currentGameViewController.view];
	
	// Create the page curl gradient on the left.
	UIImageView *pageCurlGradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PageCurlGradient.png"]];
	pageCurlGradient.frame = CGRectMake(0, 0, 17, 460);
	[self.view addSubview:pageCurlGradient];
	
	// Create the folded corner.
	foldedCornerView = [[ZSFoldedCornerView alloc] init];
	foldedCornerView.touchDelegate = self;
	[self.view addSubview:foldedCornerView];
	
	[foldedCornerView redraw];
	currentGameViewController.foldDimensions = foldedCornerView.foldDimensions;
	[currentGameViewController.view setNeedsDisplay];
	
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
//	previousGameViewController = currentGameViewController;
	
//	[[ZSGameController sharedInstance] fetchGameWithDifficulty:previousGameViewController.game.difficulty];
//	ZSGame *currentGame = [ZSGameController sharedInstance].currentGame;
//	
//	currentGameViewController = [[ZSGameViewController alloc] initWithGame:currentGame];
//	currentGameViewController.hintDelegate = self;
//	
//	[self.view addSubview:currentGameViewController.view];
//	[previousGameViewController.view removeFromSuperview];
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
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	hintViewController.view.frame = CGRectMake(0, 310, hintViewController.view.frame.size.width, hintViewController.view.frame.size.height);
	currentGameViewController.view.frame = CGRectMake(0, -45, currentGameViewController.view.frame.size.width, currentGameViewController.view.frame.size.height);
	
	[UIView commitAnimations];
}

- (void)hideHint {
	if (!hintsShown) {
		return;
	}
	
	hintsShown = NO;
	
	[currentGameViewController.gameBoardViewController removeAllHintHighlights];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	hintViewController.view.frame = CGRectMake(0, 480, hintViewController.view.frame.size.width, hintViewController.view.frame.size.height);
	currentGameViewController.view.frame = CGRectMake(0, 0, currentGameViewController.view.frame.size.width, currentGameViewController.view.frame.size.height);
	
	[UIView commitAnimations];
}

- (void)foldedCornerTouchStarted:(CGPoint)startPoint {
	currentGameViewController.foldDimensions = foldedCornerView.foldDimensions;
	
	[(ZSFoldedPageView *)currentGameViewController.view createScreenshotFromView];
	[(ZSFoldedPageView *)currentGameViewController.view setAllSubViewsHidden:YES];
	
	[currentGameViewController.view setNeedsDisplay];
}

- (void)foldedCornerTouchMoved:(CGPoint)touchPoint {
	currentGameViewController.foldDimensions = foldedCornerView.foldDimensions;
	[currentGameViewController.view setNeedsDisplay];
}

- (void)foldedCornerTouchEnded {
	currentGameViewController.foldDimensions = foldedCornerView.foldDimensions;
	
	[(ZSFoldedPageView *)currentGameViewController.view restoreScreenshotFromOriginal];
	[(ZSFoldedPageView *)currentGameViewController.view setAllSubViewsHidden:NO];
	
	[currentGameViewController.view setNeedsDisplay];
}

@end

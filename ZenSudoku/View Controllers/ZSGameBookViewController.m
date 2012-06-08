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

@interface ZSGameBookViewController () {
	CGPoint _foldedCornerTouchStartPoint;
}

@end

@implementation ZSGameBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Create the game view.
	ZSGame *currentGame = [ZSGameController sharedInstance].currentGame;
	
	if (!currentGame) {
		[[ZSGameController sharedInstance] fetchGameWithDifficulty:ZSGameDifficultyDiabolical];
		currentGame = [ZSGameController sharedInstance].currentGame;
	}
	
	currentGameViewController = [[ZSGameViewController alloc] initWithGame:currentGame];
	currentGameViewController.hintDelegate = self;
	[self.view addSubview:currentGameViewController.view];
	
	// Create the folded corner.
	foldedCornerView = [[ZSFoldedCornerView alloc] init];
	foldedCornerView.touchDelegate = self;
	[self.view addSubview:foldedCornerView];
	[foldedCornerView redraw];
	
	// Create the hint.
	hintViewController = [[ZSHintViewController alloc] initWithNibName:@"ZSHintViewController" bundle:[NSBundle mainBundle]];
	hintViewController.view.frame = CGRectMake(0, 480, hintViewController.view.frame.size.width, hintViewController.view.frame.size.height);
	[self.view addSubview:hintViewController.view];
}

- (void)startNewGame {
	previousGameViewController = currentGameViewController;
	
	[[ZSGameController sharedInstance] fetchGameWithDifficulty:previousGameViewController.game.difficulty];
	ZSGame *currentGame = [ZSGameController sharedInstance].currentGame;
	
	currentGameViewController = [[ZSGameViewController alloc] initWithGame:currentGame];
	currentGameViewController.hintDelegate = self;
	
	[self.view addSubview:currentGameViewController.view];
	[previousGameViewController.view removeFromSuperview];
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
	_foldedCornerTouchStartPoint = startPoint;
}

- (void)foldedCornerTouchMoved:(CGPoint)touchPoint {
	CGPoint panDelta = CGPointMake(touchPoint.x - _foldedCornerTouchStartPoint.x, touchPoint.y - _foldedCornerTouchStartPoint.y);
	
	float newWidth = 50 - (panDelta.x * 1.22);
	[foldedCornerView setNeedsDisplay];
}

- (void)foldedCornerTouchEnded {
	float newWidth = 50;
	[foldedCornerView setNeedsDisplay];
}

@end

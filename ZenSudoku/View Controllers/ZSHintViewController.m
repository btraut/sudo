//
//  ZSHintViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/26/12.
//  Copyright (c) 2012 Ten Four Inc. All rights reserved.
//

#import "ZSHintViewController.h"
#import "ZSGameViewController.h"
#import "ZSGameBoardViewController.h"
#import "ZSHintCard.h"

@interface ZSHintViewController () {
	NSArray *_hintDeck;
	ZSGameViewController *_gameViewController;
	
	NSInteger _currentCard;
	
	UILabel *_textView;
	
	UILabel *_learnButton;
	UILabel *_moreButton;
	UILabel *_doneButton;
}

- (void)_learnButtonWasTouched;
- (void)_moreButtonWasTouched;
- (void)_doneButtonWasTouched;

- (void)loadHintCard;

@end

@implementation ZSHintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Create the text view.
	_textView = [[UILabel alloc] initWithFrame:CGRectMake(28, 22, 264, 78)];
	_textView.font = [UIFont fontWithName:@"Courier New" size:14.0f];
	_textView.backgroundColor = [UIColor clearColor];
	_textView.numberOfLines = 0;
	
	[self.view addSubview:_textView];
	
	// Create previous button.
	_learnButton = [[UILabel alloc] initWithFrame:CGRectMake(28, 108, 85, 21)];
	_learnButton.font = [UIFont fontWithName:@"Courier New" size:14.0f];
	_learnButton.text = @"learn";
	_learnButton.textAlignment = UITextAlignmentLeft;
	_learnButton.backgroundColor = [UIColor clearColor];
	_learnButton.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *previousGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_learnButtonWasTouched)];
	[_learnButton addGestureRecognizer:previousGestureRecognizer];
	
	[self.view addSubview:_learnButton];
	
	// Create next button.
	_moreButton = [[UILabel alloc] initWithFrame:CGRectMake(212, 108, 85, 21)];
	_moreButton.font = [UIFont fontWithName:@"Courier New" size:14.0f];
	_moreButton.text = @"more";
	_moreButton.textAlignment = UITextAlignmentRight;
	_moreButton.backgroundColor = [UIColor clearColor];
	_moreButton.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *nextGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_moreButtonWasTouched)];
	[_moreButton addGestureRecognizer:nextGestureRecognizer];
	
	[self.view addSubview:_moreButton];
	
	// Create done button.
	_doneButton = [[UILabel alloc] initWithFrame:CGRectMake(124, 108, 85, 21)];
	_doneButton.font = [UIFont fontWithName:@"Courier New" size:14.0f];
	_doneButton.text = @"done";
	_doneButton.textAlignment = UITextAlignmentCenter;
	_doneButton.backgroundColor = [UIColor clearColor];
	_doneButton.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *doneGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_doneButtonWasTouched)];
	[_doneButton addGestureRecognizer:doneGestureRecognizer];
	
	[self.view addSubview:_doneButton];
}

- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController {
	_hintDeck = hintDeck;
	_gameViewController = gameViewController;
	
	[gameViewController.gameBoardViewController deselectTileView];
	
	_currentCard = 0;
	[self loadHintCard];
}

- (void)_learnButtonWasTouched {
	--_currentCard;
	[self loadHintCard];
}

- (void)_moreButtonWasTouched {
	++_currentCard;
	[self loadHintCard];
}

- (void)_doneButtonWasTouched {
	[_gameViewController closeHintButtonWasTouched];
}

- (void)loadHintCard {
	ZSHintCard *currentCard = [_hintDeck objectAtIndex:_currentCard];
	
	_learnButton.hidden = !currentCard.allowsLearn;
	_moreButton.hidden = (_currentCard == [_hintDeck count] - 1);
	
	_textView.text = currentCard.text;
	_textView.frame = CGRectMake(28, 22, 264, 78);
	[_textView sizeToFit];
	
	[_gameViewController.gameBoardViewController removeAllHintHighlights];
	
	for (NSDictionary *dict in currentCard.highlightPencils) {
		NSInteger row = [[dict objectForKey:kDictionaryKeyTileRow] intValue];
		NSInteger col = [[dict objectForKey:kDictionaryKeyTileCol] intValue];
		NSInteger pencil = [[dict objectForKey:kDictionaryKeyTileValue] intValue];
		ZSGameBoardTilePencilTextHintHighlightType pencilTextHintHighlightType = [[dict objectForKey:kDictionaryKeyHighlightType] intValue];
		
		ZSGameBoardTileViewController *tile = [_gameViewController.gameBoardViewController getGameBoardTileViewControllerAtRow:row col:col];
		
		tile.highlightPencilHints[pencil - 1] = pencilTextHintHighlightType;
	}
	
	for (NSDictionary *dict in currentCard.highlightAnswers) {
		NSInteger row = [[dict objectForKey:kDictionaryKeyTileRow] intValue];
		NSInteger col = [[dict objectForKey:kDictionaryKeyTileCol] intValue];
		ZSGameBoardTileTextHintHighlightType textHintHighlightType = [[dict objectForKey:kDictionaryKeyHighlightType] intValue];
		
		ZSGameBoardTileViewController *tile = [_gameViewController.gameBoardViewController getGameBoardTileViewControllerAtRow:row col:col];
		
		tile.highlightGuessHint = textHintHighlightType;
	}
	
	for (NSDictionary *dict in currentCard.highlightTiles) {
		NSInteger row = [[dict objectForKey:kDictionaryKeyTileRow] intValue];
		NSInteger col = [[dict objectForKey:kDictionaryKeyTileCol] intValue];
		ZSGameBoardTileHintHighlightType hintHighlightType = [[dict objectForKey:kDictionaryKeyHighlightType] intValue];
		
		ZSGameBoardTileViewController *tile = [_gameViewController.gameBoardViewController getGameBoardTileViewControllerAtRow:row col:col];
		
		tile.highlightedHintType = hintHighlightType;
	}
	
	for (NSDictionary *dict in currentCard.removePencils) {
		NSInteger row = [[dict objectForKey:kDictionaryKeyTileRow] intValue];
		NSInteger col = [[dict objectForKey:kDictionaryKeyTileCol] intValue];
		NSInteger pencil = [[dict objectForKey:kDictionaryKeyTileValue] intValue];
		
		[_gameViewController.game setPencil:NO forPencilNumber:pencil forTileAtRow:row col:col];
	}
	
	for (NSDictionary *dict in currentCard.addPencils) {
		NSInteger row = [[dict objectForKey:kDictionaryKeyTileRow] intValue];
		NSInteger col = [[dict objectForKey:kDictionaryKeyTileCol] intValue];
		NSInteger pencil = [[dict objectForKey:kDictionaryKeyTileValue] intValue];
		
		[_gameViewController.game setPencil:YES forPencilNumber:pencil forTileAtRow:row col:col];
	}
	
	for (NSDictionary *dict in currentCard.removeGuess) {
		NSInteger row = [[dict objectForKey:kDictionaryKeyTileRow] intValue];
		NSInteger col = [[dict objectForKey:kDictionaryKeyTileCol] intValue];
		
		[_gameViewController.game clearGuessForTileAtRow:row col:col];
	}
	
	for (NSDictionary *dict in currentCard.setGuess) {
		NSInteger row = [[dict objectForKey:kDictionaryKeyTileRow] intValue];
		NSInteger col = [[dict objectForKey:kDictionaryKeyTileCol] intValue];
		NSInteger guess = [[dict objectForKey:kDictionaryKeyTileValue] intValue];
		
		[_gameViewController.game setGuess:guess forTileAtRow:row col:col];
	}
	
	if (currentCard.setAutoPencil) {
		[_gameViewController setAutoPencils];
	}
	
	[_gameViewController.gameBoardViewController reloadView];
}

@end

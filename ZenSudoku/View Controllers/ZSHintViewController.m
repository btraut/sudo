//
//  ZSHintViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/26/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintViewController.h"

#import "ZSGameViewController.h"
#import "ZSBoardViewController.h"
#import "ZSHintCard.h"

#import "ProgressDots.h"
#import "iCarousel.h"
#import "MTLabel.h"
#import "UIColor+ColorWithHex.h"

@interface ZSHintViewController () <iCarouselDataSource, iCarouselDelegate> {
	NSArray *_hintDeck;
	ZSGameViewController *_gameViewController;
	
	iCarousel *_carousel;
	NSMutableArray *_cardLabels;
	
	NSInteger _currentCard;
	NSInteger _previousCard;
	BOOL _currentCardModifiedHistory;
	
	UILabel *_textView;
	
	ProgressDots *_progressDots;
}

@end

@implementation ZSHintViewController

- (void)loadView {
	UIImage *hintPaperImage = [UIImage imageNamed:@"IndexCard.png"];
	self.view = [[UIImageView alloc] initWithImage:hintPaperImage];
	
	self.view.frame = CGRectMake(0, 0, hintPaperImage.size.width, hintPaperImage.size.height);
	self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Create progress dots.
	_progressDots = [[ProgressDots alloc] initWithFrame:CGRectMake(165, 89, 0, 0)];
	_progressDots.dotOffset = 5.0f;
	[self.view addSubview:_progressDots];
	
	// Init the carousel.
	_cardLabels = [NSMutableArray array];
	
	_carousel = [[iCarousel alloc] initWithFrame:CGRectMake(5, 5, 320, 115)];
    _carousel.type = iCarouselTypeLinear;
	_carousel.delegate = self;
	_carousel.dataSource = self;
	_carousel.bounceDistance = 0.2f;
	_carousel.scrollSpeed = 0.9f;
	_carousel.decelerationRate = 0.15f;
	[self.view addSubview:_carousel];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    return [_cardLabels count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view {
    return [_cardLabels objectAtIndex:index];
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
	_progressDots.selectedDot = carousel.currentItemIndex;
	
	_previousCard = _currentCard;
	_currentCard = carousel.currentItemIndex;
	[self _doHintCardActions];
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    switch (option) {
        case iCarouselOptionVisibleItems:
            return 3.0f;
			
		default:
			return value;
	}
}

- (void)beginHintDeck:(NSArray *)hintDeck forGameViewController:(ZSGameViewController *)gameViewController {
	_hintDeck = hintDeck;
	_gameViewController = gameViewController;
	
	[_cardLabels removeAllObjects];
	
	NSInteger sidePadding = 16;
	NSInteger topPadding = 13;
	
	for (ZSHintCard *card in hintDeck) {
		MTLabel *label = [[MTLabel alloc] initWithFrame:CGRectMake(sidePadding, topPadding, _carousel.frame.size.width - sidePadding * 2, _carousel.frame.size.height - topPadding * 2)];
		label.backgroundColor = [UIColor clearColor];
		label.shadowColor = [UIColor clearColor];
		label.text = card.text;
		label.font = [UIFont fontWithName:@"Helvetica Neue" size:16.0f];
		label.fontColor = [UIColor colorWithHexString:@"#2e2e2e"];
		label.lineHeight = 22.5f;
		
		UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _carousel.frame.size.width, _carousel.frame.size.height)];
		[container addSubview:label];
		
		[_cardLabels addObject:container];
	}
	
	[_carousel reloadData];
	_carousel.currentItemIndex = 0;
	
	_progressDots.totalDots = hintDeck.count;
	_progressDots.selectedDot = 0;
	
	[gameViewController deselectTileView];
	
	_currentCard = 0;
	_previousCard = -1;
	
	[self _doHintCardActions];
}

- (void)_doHintCardActions {
	if (_previousCard > _currentCard) {
		ZSHintCard *previousCard = [_hintDeck objectAtIndex:_previousCard];
		
		// Only undo if the previous card actually had action on it.
		if (previousCard.modifiesHistory) {
			[_gameViewController.game undoAndPlaceOntoRedoStack:NO];
		}
	}
	
	[_gameViewController.boardViewController removeAllHintHighlights];

	ZSHintCard *currentCard = [_hintDeck objectAtIndex:_currentCard];
	
	if (currentCard.modifiesHistory) {
		[_gameViewController.game startGenericUndoStop];
	}
	
	for (NSDictionary *dict in currentCard.highlightPencils) {
		NSInteger row = [[dict objectForKey:kDictionaryKeyTileRow] intValue];
		NSInteger col = [[dict objectForKey:kDictionaryKeyTileCol] intValue];
		NSInteger pencil = [[dict objectForKey:kDictionaryKeyTileValue] intValue];
		ZSTilePencilTextHintHighlightType pencilTextHintHighlightType = [[dict objectForKey:kDictionaryKeyHighlightType] intValue];
		
		ZSTileViewController *tile = [_gameViewController.boardViewController getTileViewControllerAtRow:row col:col];
		
		tile.highlightPencilHints[pencil - 1] = pencilTextHintHighlightType;
	}
	
	for (NSDictionary *dict in currentCard.highlightAnswers) {
		NSInteger row = [[dict objectForKey:kDictionaryKeyTileRow] intValue];
		NSInteger col = [[dict objectForKey:kDictionaryKeyTileCol] intValue];
		ZSTileTextHintHighlightType textHintHighlightType = [[dict objectForKey:kDictionaryKeyHighlightType] intValue];
		
		ZSTileViewController *tile = [_gameViewController.boardViewController getTileViewControllerAtRow:row col:col];
		
		tile.highlightGuessHint = textHintHighlightType;
	}
	
	for (NSDictionary *dict in currentCard.highlightTiles) {
		NSInteger row = [[dict objectForKey:kDictionaryKeyTileRow] intValue];
		NSInteger col = [[dict objectForKey:kDictionaryKeyTileCol] intValue];
		ZSTileHintHighlightType hintHighlightType = [[dict objectForKey:kDictionaryKeyHighlightType] intValue];
		
		ZSTileViewController *tile = [_gameViewController.boardViewController getTileViewControllerAtRow:row col:col];
		
		tile.highlightedHintType = hintHighlightType;
	}
	
	if (_previousCard < _currentCard) {
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
			[_gameViewController.game addAutoPencils];
		}
	}
	
	if (currentCard.modifiesHistory) {
		[_gameViewController.game stopGenericUndoStop];
	}
	
	// We can get away with just reloading the board here because we're gauranteed to have no selection
	// and a new screenshot will be generated when the hints are dismissed.
	[_gameViewController.boardViewController reloadView];
}

@end

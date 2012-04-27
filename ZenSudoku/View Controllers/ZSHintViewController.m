//
//  ZSHintViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSHintViewController.h"
#import "ZSGameViewController.h"
#import "ZSHintCard.h"

@interface ZSHintViewController () {
	NSArray *_hintDeck;
	ZSGameViewController *_gameViewController;
	
	NSInteger _currentCard;
	
	UILabel *_textView;
	
	UILabel *_previousButton;
	UILabel *_nextButton;
	UILabel *_doneButton;
}

- (void)_previousButtonWasTouched;
- (void)_nextButtonWasTouched;
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
	_previousButton = [[UILabel alloc] initWithFrame:CGRectMake(28, 108, 85, 21)];
	_previousButton.font = [UIFont fontWithName:@"Courier New" size:14.0f];
	_previousButton.text = @"< prev";
	_previousButton.textAlignment = UITextAlignmentLeft;
	_previousButton.backgroundColor = [UIColor clearColor];
	_previousButton.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *previousGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_previousButtonWasTouched)];
	[_previousButton addGestureRecognizer:previousGestureRecognizer];
	
	[self.view addSubview:_previousButton];
	
	// Create next button.
	_nextButton = [[UILabel alloc] initWithFrame:CGRectMake(212, 108, 85, 21)];
	_nextButton.font = [UIFont fontWithName:@"Courier New" size:14.0f];
	_nextButton.text = @"next >";
	_nextButton.textAlignment = UITextAlignmentRight;
	_nextButton.backgroundColor = [UIColor clearColor];
	_nextButton.userInteractionEnabled = YES;
	
	UITapGestureRecognizer *nextGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_nextButtonWasTouched)];
	[_nextButton addGestureRecognizer:nextGestureRecognizer];
	
	[self.view addSubview:_nextButton];
	
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
	
	_currentCard = 0;
	[self loadHintCard];
}

- (void)_previousButtonWasTouched {
	--_currentCard;
	[self loadHintCard];
}

- (void)_nextButtonWasTouched {
	++_currentCard;
	[self loadHintCard];
}

- (void)_doneButtonWasTouched {
	[_gameViewController closeHintButtonWasTouched];
}

- (void)loadHintCard {
	ZSHintCard *currentCard = [_hintDeck objectAtIndex:_currentCard];
	
	_previousButton.hidden = !currentCard.allowsPrevious;
	_nextButton.hidden = (_currentCard == [_hintDeck count] - 1);
	
	_textView.text = currentCard.text;
	_textView.frame = CGRectMake(28, 22, 264, 78);
	[_textView sizeToFit];
	
	if (currentCard.setAutoPencil) {
		[_gameViewController setAutoPencils];
	}
}

@end

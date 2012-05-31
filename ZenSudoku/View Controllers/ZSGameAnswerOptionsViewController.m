//
//  ZSGameAnswerOptionsViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameAnswerOptionsViewController.h"
#import "ZSGameAnswerOptionViewController.h"
#import "ZSGameViewController.h"
#import "ZSGameBoardViewController.h"
#import "ZSGameTile.h"
#import "ZSGame.h"
#import "ZSGameBoard.h"

#define DEFAULT_FRAME_HEIGHT 300
#define DEFAULT_FRAME_WIDTH 31

@interface ZSGameAnswerOptionsViewController () {
	BOOL _answerOptionIsBeingTouched;
	ZSGameAnswerOption _previousTouchedAnswerOption;
}

@end

@implementation ZSGameAnswerOptionsViewController

@synthesize gameViewController;
@synthesize delegate;
@synthesize gameAnswerOptionViewControllers, pencilToggleButton;
@synthesize selectedGameAnswerOptionView;

- (id)initWithGameViewController:(ZSGameViewController *)newGameViewController {
	self = [self init];
	
	if (self) {
		gameViewController = newGameViewController;
	}
	
	return self;
}

- (ZSGameAnswerOptionViewController *)getGameAnswerOptionViewControllerForGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption {
	return [gameAnswerOptionViewControllers objectAtIndex:(NSInteger)gameAnswerOption];
}

#pragma mark - View Lifecycle

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DEFAULT_FRAME_HEIGHT, DEFAULT_FRAME_WIDTH)];
	self.view.userInteractionEnabled = YES;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Build numbers.
	NSMutableArray *buttons = [NSMutableArray array];
	ZSGameAnswerOptionViewController *gameAnswerOptionViewController;
	
	NSInteger xOffset = 0;
	
	for (NSInteger i = 0; i < gameViewController.game.gameBoard.size; i++) {
		gameAnswerOptionViewController = [[ZSGameAnswerOptionViewController alloc] initWithGameAnswerOption:(ZSGameAnswerOption)i];
		gameAnswerOptionViewController.view.frame = CGRectMake(xOffset, 0, gameAnswerOptionViewController.view.frame.size.width, gameAnswerOptionViewController.view.frame.size.height);
		gameAnswerOptionViewController.delegate = self;
		gameAnswerOptionViewController.gameAnswerOptionsViewController = self;
		
		[self.view addSubview:gameAnswerOptionViewController.view];
		[buttons addObject:gameAnswerOptionViewController];
		
		xOffset += DEFAULT_FRAME_WIDTH;
	}
	
	gameAnswerOptionViewControllers = [NSArray arrayWithArray:buttons];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)reloadView {
	ZSGameBoardTileViewController *selectedTile = gameViewController.gameBoardViewController.selectedTileView;
	
	for (ZSGameAnswerOptionViewController *gameAnswerOptionViewController in gameAnswerOptionViewControllers) {
		// Check if the answer option is at quota.
		if ([gameViewController.game allowsGuess:((NSInteger)gameAnswerOptionViewController.gameAnswerOption + 1)]) {
			gameAnswerOptionViewController.enabled = YES;
			gameAnswerOptionViewController.toggled = [selectedTile.tile getPencilForGuess:((NSInteger)gameAnswerOptionViewController.gameAnswerOption + 1)];
		} else {
			gameAnswerOptionViewController.enabled = NO;
		}
		
		gameAnswerOptionViewController.selected = selectedTile.tile.guess && selectedTile.tile.guess == ((NSInteger)gameAnswerOptionViewController.gameAnswerOption + 1);
		
		// Reload the answer option.
		[gameAnswerOptionViewController reloadView];
	}
}

#pragma mark - Answer Option Changes

- (void)selectGameAnswerOptionView:(ZSGameAnswerOptionViewController *)newSelected {
	// If there was a selection, deselect it.
	if (selectedGameAnswerOptionView) {
		[self deselectGameAnswerOptionView];
	}
	
	// Make the new selection.
	selectedGameAnswerOptionView = newSelected;
	[selectedGameAnswerOptionView setSelected:YES];
}

- (void)deselectGameAnswerOptionView {
	if (selectedGameAnswerOptionView) {
		[selectedGameAnswerOptionView setSelected:NO];
		selectedGameAnswerOptionView = nil;
	}
}

#pragma mark - Handle Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// Figure out which (if any) option is being touched.
	UITouch *touch = [touches anyObject];
	ZSGameAnswerOptionViewController *touchedViewController;
	
	CGPoint touchPoint = [touch locationInView:self.view];
	BOOL touchIsInBounds = touchPoint.x >= 0 && touchPoint.y >= 0 && touchPoint.x < self.view.frame.size.width && touchPoint.y < self.view.frame.size.height;
	
	if (touchIsInBounds) {
		for (ZSGameAnswerOptionViewController *viewController in gameAnswerOptionViewControllers) {
			if (touchPoint.x >= viewController.view.frame.origin.x && touchPoint.x < viewController.view.frame.origin.x + viewController.view.frame.size.width) {
				touchedViewController = viewController;
				break;
			}
		}
	}
	
	// Mark the option as touched.
	if (touchedViewController && touchedViewController.enabled) {
		[touchedViewController handleTouchEnter];
		
		_answerOptionIsBeingTouched = YES;
		_previousTouchedAnswerOption = touchedViewController.gameAnswerOption;
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// Figure out which (if any) option is being touched.
	UITouch *touch = [touches anyObject];
	ZSGameAnswerOptionViewController *touchedViewController;
	
	CGPoint touchPoint = [touch locationInView:self.view];
	BOOL touchIsInBounds = touchPoint.x >= 0 && touchPoint.y >= 0 && touchPoint.x < self.view.frame.size.width && touchPoint.y < self.view.frame.size.height;
	
	if (touchIsInBounds) {
		for (ZSGameAnswerOptionViewController *viewController in gameAnswerOptionViewControllers) {
			if (touchPoint.x >= viewController.view.frame.origin.x && touchPoint.x < viewController.view.frame.origin.x + viewController.view.frame.size.width) {
				touchedViewController = viewController;
				break;
			}
		}
	}
	
	// If the user is touching a tile, mark it touched. If a previous one was being touched, turn that one off first.
	if (touchedViewController && touchedViewController.enabled) {
		if (_answerOptionIsBeingTouched) {
			if (_previousTouchedAnswerOption != touchedViewController.gameAnswerOption) {
				[[self getGameAnswerOptionViewControllerForGameAnswerOption:_previousTouchedAnswerOption] handleTouchExit];
				[touchedViewController handleTouchEnter];
			}
		} else {
			[touchedViewController handleTouchEnter];
		}
		
		_answerOptionIsBeingTouched = YES;
		_previousTouchedAnswerOption = touchedViewController.gameAnswerOption;
	} else {
		if (_answerOptionIsBeingTouched) {
			_answerOptionIsBeingTouched = NO;
			[[self getGameAnswerOptionViewControllerForGameAnswerOption:_previousTouchedAnswerOption] handleTouchExit];
		}
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// Figure out which (if any) option is being touched.
	UITouch *touch = [touches anyObject];
	ZSGameAnswerOptionViewController *touchedViewController;
	
	CGPoint touchPoint = [touch locationInView:self.view];
	BOOL touchIsInBounds = touchPoint.x >= 0 && touchPoint.y >= 0 && touchPoint.x < self.view.frame.size.width && touchPoint.y < self.view.frame.size.height;
	
	if (touchIsInBounds) {
		for (ZSGameAnswerOptionViewController *viewController in gameAnswerOptionViewControllers) {
			if (touchPoint.x >= viewController.view.frame.origin.x && touchPoint.x < viewController.view.frame.origin.x + viewController.view.frame.size.width) {
				touchedViewController = viewController;
				break;
			}
		}
	}
	
	// If an answer option was being touched, turn it off and register a tap.
	if (touchedViewController && touchedViewController.enabled) {
		[touchedViewController handleTouchExit];
		[touchedViewController handleTap];
	}
	
	_answerOptionIsBeingTouched = NO;
}

#pragma mark - Delegate Responsibilities

- (void)gameAnswerOptionTouchEntered:(ZSGameAnswerOptionViewController *)touchedView {
	[(ZSGameViewController *)delegate gameAnswerOptionTouchEnteredWithGameAnswerOption:touchedView.gameAnswerOption];
}

- (void)gameAnswerOptionTouchExited:(ZSGameAnswerOptionViewController *)touchedView {
	[(ZSGameViewController *)delegate gameAnswerOptionTouchExitedWithGameAnswerOption:touchedView.gameAnswerOption];
}

- (void)gameAnswerOptionTapped:(ZSGameAnswerOptionViewController *)touchedView {
	[(ZSGameViewController *)delegate gameAnswerOptionTappedWithGameAnswerOption:touchedView.gameAnswerOption];
}

@end

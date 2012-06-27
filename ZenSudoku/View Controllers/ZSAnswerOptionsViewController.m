//
//  ZSAnswerOptionsViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSAnswerOptionsViewController.h"
#import "ZSAnswerOptionViewController.h"
#import "ZSGameViewController.h"
#import "ZSBoardViewController.h"
#import "ZSTile.h"
#import "ZSGame.h"
#import "ZSBoard.h"

#define DEFAULT_FRAME_HEIGHT 300
#define DEFAULT_FRAME_WIDTH 31

@interface ZSAnswerOptionsViewController () {
	BOOL _answerOptionIsBeingTouched;
	ZSAnswerOption _previousTouchedAnswerOption;
}

@end

@implementation ZSAnswerOptionsViewController

@synthesize gameViewController;
@synthesize touchDelegate;
@synthesize gameAnswerOptionViewControllers, pencilToggleButton;
@synthesize selectedGameAnswerOptionView;

- (id)initWithGameViewController:(ZSGameViewController *)newGameViewController {
	self = [self init];
	
	if (self) {
		gameViewController = newGameViewController;
	}
	
	return self;
}

- (ZSAnswerOptionViewController *)getGameAnswerOptionViewControllerForGameAnswerOption:(ZSAnswerOption)gameAnswerOption {
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
	ZSAnswerOptionViewController *gameAnswerOptionViewController;
	
	NSInteger xOffset = 0;
	
	for (NSInteger i = 0; i < gameViewController.game.board.size; i++) {
		gameAnswerOptionViewController = [[ZSAnswerOptionViewController alloc] initWithGameAnswerOption:(ZSAnswerOption)i];
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
	ZSTileViewController *selectedTile = gameViewController.boardViewController.selectedTileView;
	
	[self deselectGameAnswerOptionView];
	
	for (ZSAnswerOptionViewController *gameAnswerOptionViewController in gameAnswerOptionViewControllers) {
		// Check if the answer option is at quota.
		if ([gameViewController.game allowsGuess:((NSInteger)gameAnswerOptionViewController.gameAnswerOption + 1)]) {
			gameAnswerOptionViewController.enabled = YES;
			gameAnswerOptionViewController.toggled = selectedTile && [selectedTile.tile getPencilForGuess:((NSInteger)gameAnswerOptionViewController.gameAnswerOption + 1)];
		} else {
			gameAnswerOptionViewController.enabled = NO;
		}
		
		if (selectedTile && selectedTile.tile.guess && selectedTile.tile.guess == ((NSInteger)gameAnswerOptionViewController.gameAnswerOption + 1)) {
			[self selectGameAnswerOptionView:gameAnswerOptionViewController];
		}
		
		// Reload the answer option.
		[gameAnswerOptionViewController reloadView];
	}
}

#pragma mark - Answer Option Changes

- (void)selectGameAnswerOptionView:(ZSAnswerOptionViewController *)newSelected {
	// If there was a selection, deselect it.
	if (selectedGameAnswerOptionView) {
		[self deselectGameAnswerOptionView];
	}
	
	// Make the new selection.
	selectedGameAnswerOptionView = newSelected;
	selectedGameAnswerOptionView.selected = YES;
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
	ZSAnswerOptionViewController *touchedViewController;
	
	CGPoint touchPoint = [touch locationInView:self.view];
	BOOL touchIsInBounds = touchPoint.x >= 0 && touchPoint.y >= 0 && touchPoint.x < self.view.frame.size.width && touchPoint.y < self.view.frame.size.height;
	
	if (touchIsInBounds) {
		for (ZSAnswerOptionViewController *viewController in gameAnswerOptionViewControllers) {
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
	ZSAnswerOptionViewController *touchedViewController;
	
	CGPoint touchPoint = [touch locationInView:self.view];
	BOOL touchIsInBounds = touchPoint.x >= 0 && touchPoint.y >= 0 && touchPoint.x < self.view.frame.size.width && touchPoint.y < self.view.frame.size.height;
	
	if (touchIsInBounds) {
		for (ZSAnswerOptionViewController *viewController in gameAnswerOptionViewControllers) {
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
	ZSAnswerOptionViewController *touchedViewController;
	
	CGPoint touchPoint = [touch locationInView:self.view];
	BOOL touchIsInBounds = touchPoint.x >= 0 && touchPoint.y >= 0 && touchPoint.x < self.view.frame.size.width && touchPoint.y < self.view.frame.size.height;
	
	if (touchIsInBounds) {
		for (ZSAnswerOptionViewController *viewController in gameAnswerOptionViewControllers) {
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

- (void)gameAnswerOptionTouchEntered:(ZSAnswerOptionViewController *)touchedView {
	[touchDelegate gameAnswerOptionTouchEnteredWithGameAnswerOption:touchedView.gameAnswerOption];
}

- (void)gameAnswerOptionTouchExited:(ZSAnswerOptionViewController *)touchedView {
	[touchDelegate gameAnswerOptionTouchExitedWithGameAnswerOption:touchedView.gameAnswerOption];
}

- (void)gameAnswerOptionTapped:(ZSAnswerOptionViewController *)touchedView {
	[touchDelegate gameAnswerOptionTappedWithGameAnswerOption:touchedView.gameAnswerOption];
}

@end

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
#import "ZSPanBetweenSubviewsGestureRecognizer.h"

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
		
		_previousTouchedAnswerOption = -1;
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
	
	// Create the gesture recognizer.
	ZSPanBetweenSubviewsGestureRecognizer *panBetweenSubviewsGestureRecognizer = [[ZSPanBetweenSubviewsGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[self.view addGestureRecognizer:panBetweenSubviewsGestureRecognizer];
	
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
		
		[panBetweenSubviewsGestureRecognizer addSubview:gameAnswerOptionViewController.view];
		
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

- (void)pan:(ZSPanBetweenSubviewsGestureRecognizer *)sender {
	if (sender.selectedSubviewIndex != _previousTouchedAnswerOption) {
		if (sender.selectedSubviewIndex == -1) {
			ZSAnswerOptionViewController *previouslySelectedViewController = [self getGameAnswerOptionViewControllerForGameAnswerOption:_previousTouchedAnswerOption];
			[previouslySelectedViewController handleTouchExit];
		} else {
			if (_previousTouchedAnswerOption != -1) {
				ZSAnswerOptionViewController *previouslySelectedViewController = [self getGameAnswerOptionViewControllerForGameAnswerOption:_previousTouchedAnswerOption];
				[previouslySelectedViewController handleTouchExit];
			}
			
			ZSAnswerOptionViewController *selectedViewController = [self getGameAnswerOptionViewControllerForGameAnswerOption:sender.selectedSubviewIndex];
			[selectedViewController handleTouchEnter];
			
		}
		
		_previousTouchedAnswerOption = sender.selectedSubviewIndex;
	}

	if (sender.state == UIGestureRecognizerStateEnded && sender.selectedSubviewIndex != -1) {
		ZSAnswerOptionViewController *selectedViewController = [self getGameAnswerOptionViewControllerForGameAnswerOption:sender.selectedSubviewIndex];
		[selectedViewController handleTouchExit];
		[selectedViewController handleTap];
		
		_previousTouchedAnswerOption = -1;
	}
}

#pragma mark - ZSAnswerOptionTouchDelegate Methods

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

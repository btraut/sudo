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
#import "ZSGame.h"
#import "ZSGameBoard.h"

@implementation ZSGameAnswerOptionsViewController

@synthesize game;
@synthesize delegate;
@synthesize gameAnswerOptionViewControllers, pencilToggleButton;
@synthesize selectedGameAnswerOptionView;

+ (id)gameAnswerOptionsViewControllerForGame:(ZSGame *)newGame {
	return [[ZSGameAnswerOptionsViewController alloc] initWithGame:newGame];
}

- (id)initWithGame:(ZSGame *)newGame {
	self = [self init];
	
	if (self) {
		game = newGame;
	}
	
	return self;
}

- (ZSGameAnswerOptionViewController *)getGameAnswerOptionViewControllerForGameAnswerOption:(ZSGameAnswerOption)gameAnswerOption {
	return [gameAnswerOptionViewControllers objectAtIndex:(int)gameAnswerOption];
}

#pragma mark - View Lifecycle

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSMutableArray *buttons = [NSMutableArray array];
	ZSGameAnswerOptionViewController *gameAnswerOptionViewController;
	
	int xOffset = 1;
	
	for (int i = 0; i <= game.gameBoard.size; i++) {
		gameAnswerOptionViewController = [[ZSGameAnswerOptionViewController alloc] initWithGameAnswerOption:(ZSGameAnswerOption)i];
		gameAnswerOptionViewController.view.frame = CGRectMake(xOffset, 0, gameAnswerOptionViewController.view.frame.size.width, gameAnswerOptionViewController.view.frame.size.height);
		gameAnswerOptionViewController.delegate = self;
		
		[self.view addSubview:gameAnswerOptionViewController.view];
		[buttons addObject:gameAnswerOptionViewController];
		
		xOffset += 30;
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
	for (ZSGameAnswerOptionViewController *gameAnswerOptionViewController in gameAnswerOptionViewControllers) {
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

#pragma mark - Delegate Responsibilities

- (void)gameAnswerOptionWasTouched:(ZSGameAnswerOptionViewController *)newSelected {
	[(ZSGameViewController *)delegate gameAnswerOptionWasTouchedWithGameAnswerOption:newSelected.gameAnswerOption];
}

@end

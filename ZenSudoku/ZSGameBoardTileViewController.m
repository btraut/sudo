//
//  ZSGameBoardTileViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameBoardTileViewController.h"
#import "ZSGameTile.h"
#import "ZSGame.h"
#import "ZSGameBoard.h"

@implementation ZSGameBoardTileViewController

@synthesize tile, delegate;
@synthesize selected, highlighted, incorrect;
@synthesize pencilViews, guessView;

- (id)init {
	self = [super init];
	
	if (self) {
		selected = NO;
		highlighted = NO;
		incorrect = NO;
	}
	
	return self;
}

- (id)initWithTile:(ZSGameTile *)newTile {
	self = [self init];
	
	if (self) {
		tile = newTile;
	}
	
	return self;
}

#pragma mark - View Lifecycle

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
	self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.2];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Listen to the view's taps.
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
	[self.view addGestureRecognizer:gestureRecognizer];
	
	// Create the pencil labels.
	NSMutableArray *newPencils = [NSMutableArray array];
	
	for (NSInteger row = 0; row < 3; row++) {
		for (NSInteger col = 0; col < 3; col++) {
			UILabel *pencil = [[UILabel alloc] init];
			
			pencil.text = [NSString stringWithFormat:@"%i", (row * 3) + col + 1];
			pencil.frame = CGRectMake(col * 11, row * 11, 10, 10);
			pencil.textAlignment = UITextAlignmentCenter;
			pencil.lineBreakMode = UILineBreakModeClip;
			pencil.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			pencil.font = [UIFont systemFontOfSize:10];
			pencil.backgroundColor = [UIColor clearColor];
			pencil.hidden = YES;
			
			[newPencils addObject:pencil];
			[self.view addSubview:pencil];
		}
	}
	
	pencilViews = [NSArray arrayWithArray:newPencils];
	
	// Create the guess label.
	guessView = [[UILabel alloc] init];
	
	guessView.text = @"0";
	guessView.frame = CGRectMake(0, 0, 32, 32);
	guessView.textAlignment = UITextAlignmentCenter;
	guessView.lineBreakMode = UILineBreakModeClip;
	guessView.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	guessView.font = [UIFont systemFontOfSize:20];
	guessView.backgroundColor = [UIColor clearColor];
	guessView.hidden = YES;
	
	self.selected = NO;
	
	[self.view addSubview:guessView];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

#pragma mark - Sudoku Stuff

- (void)reloadView {
	// Choose whether to show the guess or pencil marks.
	if (tile.guess) {
		// Set the guess text and show it.
		guessView.text = [NSString stringWithFormat:@"%i", tile.guess];
		guessView.hidden = NO;
		
		// Set visibility on all the pencil views.
		for (NSInteger i = 0; i < tile.gameBoard.size; ++i) {
			UILabel *pencilLabel = [pencilViews objectAtIndex:i];
			pencilLabel.hidden = YES;
		}		
		
		// Choose the guess text color.
		if (tile.locked) {
			guessView.textColor = [UIColor blackColor];
		} else {
			if (incorrect) {
				guessView.textColor = [UIColor colorWithRed:0.5 green:0.1 blue:0.1 alpha:1.0];
			} else {
				guessView.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:1.0];
			}
		}
	} else {
		// Hide the guess.
		guessView.hidden = YES;
		
		// Set visibility on all the pencil views.
		for (NSInteger i = 0; i < tile.gameBoard.size; ++i) {
			UILabel *pencilLabel = [pencilViews objectAtIndex:i];
			pencilLabel.hidden = ![tile getPencilForGuess:(i + 1)];
		}
	}
	
	// Choose the background color.
	if (selected) {
		if (incorrect) {
			self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.5 alpha:0.2];
		} else {
			self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.2];
		}
	} else {
		if (incorrect) {
			self.view.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.2];
		} else {
			if (highlighted) {
				if (tile.guess) {
					self.view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.5 alpha:0.6];
				} else {
					self.view.backgroundColor = [UIColor colorWithRed:0.8 green:1.0 blue:0.8 alpha:0.6];
				}
			} else {
				self.view.backgroundColor = [UIColor clearColor];
			}
		}
	}
}

#pragma mark - Touch Events

- (void)handleTap {
	NSLog(@"Row: %i", tile.row);
	NSLog(@"Col: %i", tile.col);
	NSLog(@"Group: %i", tile.groupId);
	
	[(id<ZSGameBoardTileTouchDelegate>)delegate gameBoardTileWasTouched:self];
}

@end

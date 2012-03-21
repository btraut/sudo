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
#import "FontLabel.h"
#import "UIColor+ColorWithHex.h"

// Tile Color Constants
NSString * const kTextColorAnswer = @"#FF111111";
NSString * const kTextColorGuess = @"#FF4444FF";
NSString * const kTextColorError = @"#FF882222";

NSString * const kTileColorNormal = @"#00FFFFFF";
NSString * const kTileColorSelected = @"#220000FF";
NSString * const kTileColorHighlightAnswer = @"#99FFFF88";
NSString * const kTileColorHighlightPencil = @"#99BBFFBB";
NSString * const kTileColorError = @"#33FF0000";
NSString * const kTileColorErrorSelected = @"#33D600DB";

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
			FontLabel *pencil = [[FontLabel alloc] initWithFrame:CGRectMake(col * 11, row * 11, 10, 10) fontName:@"ReklameScript-Regular" pointSize:10.0f];
			
			pencil.text = [NSString stringWithFormat:@"%i", (row * 3) + col + 1];
			pencil.textAlignment = UITextAlignmentCenter;
			pencil.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			pencil.lineBreakMode = UILineBreakModeClip;
			pencil.textColor = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.0f];
			pencil.backgroundColor = [UIColor clearColor];
			pencil.hidden = YES;
			
			[newPencils addObject:pencil];
			[self.view addSubview:pencil];
		}
	}
	
	pencilViews = [NSArray arrayWithArray:newPencils];
	
	// Create the guess label.
	guessView = [[FontLabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32) fontName:@"ReklameScript-Regular" pointSize:24.0f];
	
	guessView.text = @"0";
	guessView.textAlignment = UITextAlignmentCenter;
	guessView.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	guessView.lineBreakMode = UILineBreakModeClip;
	guessView.textColor = [UIColor colorWithWhite:0.07f alpha:1.0f];
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
			guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswer];
		} else {
			if (incorrect) {
				guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorError];
			} else {
				guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorGuess];
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
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorErrorSelected];
		} else {
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorSelected];
		}
	} else {
		if (incorrect) {
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorError];
		} else {
			if (highlighted) {
				if (tile.guess) {
					self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorHighlightAnswer];
				} else {
					self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorHighlightPencil];
				}
			} else {
				self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorNormal];
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

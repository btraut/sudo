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
#import "UIColor+ColorWithHex.h"

// Tile Color Constants
NSString * const kTextColorAnswer = @"#FF2B2B2B";
NSString * const kTextColorGuess = @"#FF666666";
NSString * const kTextColorGuessSelected = @"#FF595959";
NSString * const kTextColorGuessFingerDown = @"#FF666666";
NSString * const kTextColorError = @"#FFA70404";
NSString * const kTextColorErrorSelected = @"#FFA70404";
NSString * const kTextColorHighlightHintA = @"#FFA70404";
NSString * const kTextColorHighlightHintB = @"#FF16BE3D";

NSString * const kTextColorPencil = @"#FF2B2B2B";
NSString * const kTextColorPencilHighlightHintA = @"#FFA70404";
NSString * const kTextColorPencilHighlightHintB = @"#FF16BE3D";

NSString * const kTextShadowColorGuess = @"66FFFFFF";
NSString * const kTextShadowColorGuessSelected = @"44FFFFFF";
NSString * const kTextShadowColorGuessFingerDown = @"66FFFFFF";

NSString * const kTileColorDefault = @"#00FFFFFF";
NSString * const kTileColorSelected = @"#CC2F83D4";
NSString * const kTileColorHighlightSimilarAnswer = @"#4C2F83D4";
NSString * const kTileColorHighlightSimilarPencil = @"#202F83D4";
NSString * const kTileColorSimilarError = @"#66A70404";
NSString * const kTileColorSimilarErrorGroup = @"#19A70404";
NSString * const kTileColorOtherError = @"#19A70404";
NSString * const kTileColorHighlightHintA = @"#4CD42FB3";
NSString * const kTileColorHighlightHintB = @"#4C632FD4";
NSString * const kTileColorHighlightHintC = @"#4CD42F4A";
NSString * const kTileColorHighlightHintD = @"#4C2FADD4";

@implementation ZSGameBoardTileViewController

@synthesize tile, delegate;
@synthesize textType, backgroundType;
@synthesize ghosted, ghostedValue, selected, highlightedSimilar, highlightedError, error;
@synthesize highlightedHintType, highlightGuessHint, highlightPencilHints;

- (id)init {
	self = [super init];
	
	if (self) {
		ghosted = NO;
		selected = NO;
		highlightedSimilar = NO;
		highlightedError = NO;
		error = NO;
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
			UILabel *pencil = [[UILabel alloc] initWithFrame:CGRectMake(col * 11, row * 11, 10, 10)];
			
			pencil.font = [UIFont fontWithName:@"ReklameScript-Regular" size:10.0f];
			pencil.text = [NSString stringWithFormat:@"%i", (row * 3) + col + 1];
			pencil.textAlignment = UITextAlignmentCenter;
			pencil.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
			pencil.lineBreakMode = UILineBreakModeClip;
			pencil.textColor = [UIColor colorWithAlphaHexString:kTextColorPencil];
			pencil.backgroundColor = [UIColor clearColor];
			pencil.hidden = YES;
			pencil.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorGuess];
			pencil.shadowOffset = CGSizeMake(0, 1);
			
			[newPencils addObject:pencil];
			[self.view addSubview:pencil];
		}
	}
	
	pencilViews = [NSArray arrayWithArray:newPencils];
	
	// Init pencil highlights.
	highlightPencilHints = malloc(9 * sizeof(ZSGameBoardTilePencilTextType));
	
	for (NSInteger i = 0; i < 9; ++i) {
		highlightPencilHints[i] = ZSGameBoardTilePencilTextTypeNormal;
	}
	
	// Create the guess label.
	guessView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
	
	guessView.font = [UIFont fontWithName:@"ReklameScript-Regular" size:24.0f];
	guessView.text = @"0";
	guessView.textAlignment = UITextAlignmentCenter;
	guessView.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
	guessView.lineBreakMode = UILineBreakModeClip;
	guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorGuess];
	guessView.backgroundColor = [UIColor clearColor];
	guessView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorGuess];
	guessView.shadowOffset = CGSizeMake(0, 1);
	guessView.hidden = YES;
	
	self.selected = NO;
	
	[self.view addSubview:guessView];
}

- (void)viewDidUnload {
	free(highlightPencilHints);
	
	[super viewDidUnload];
}

#pragma mark - Sudoku Stuff

- (void)reloadView {
	// Choose whether to show the guess or pencil marks.
	if (ghosted) {
		guessView.text = [NSString stringWithFormat:@"%i", ghostedValue];
		[self showGuess];		
	} else if (tile.guess) {
		guessView.text = [NSString stringWithFormat:@"%i", tile.guess];
		[self showGuess];		
	} else {
		[self hideGuess];
	}
	
	// Set the proper text and background types.
	[self reloadTextAndBackgroundType];
	
	// Set the text color based on text type.
	switch (textType) {
		case ZSGameBoardTileTextTypeAnswer:
			guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorAnswer];
			guessView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorGuess];
			break;
		
		case ZSGameBoardTileTextTypeGuess:
			guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorGuess];
			guessView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorGuess];
			break;
			
		case ZSGameBoardTileTextTypeGuessSelected:
			guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorGuessSelected];
			guessView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorGuessFingerDown];
			break;
			
		case ZSGameBoardTileTextTypeGuessFingerDown:
			guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorGuessFingerDown];
			guessView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorGuess];
			break;
			
		case ZSGameBoardTileTextTypeGuessError:
			guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorError];
			guessView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorGuess];
			break;
			
		case ZSGameBoardTileTextTypeGuessErrorSelected:
			guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorErrorSelected];
			guessView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorGuess];
			break;
			
		case ZSGameBoardTileTextTypeHighlightHintA:
			guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorHighlightHintA];
			guessView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorGuess];
			break;
			
		case ZSGameBoardTileTextTypeHighlightHintB:
			guessView.textColor = [UIColor colorWithAlphaHexString:kTextColorHighlightHintB];
			guessView.shadowColor = [UIColor colorWithAlphaHexString:kTextShadowColorGuess];
			break;
	}
	
	// Set the background color based on text type.
	switch (backgroundType) {
		case ZSGameBoardTileBackgroundTypeDefault:
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorDefault];
			break;
			
		case ZSGameBoardTileBackgroundTypeSelected:
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorSelected];
			break;
			
		case ZSGameBoardTileBackgroundTypeSimilarPencil:
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorHighlightSimilarPencil];
			break;
			
		case ZSGameBoardTileBackgroundTypeSimilarAnswer:
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorHighlightSimilarAnswer];
			break;
			
		case ZSGameBoardTileBackgroundTypeSimilarError:
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorSimilarError];
			break;
			
		case ZSGameBoardTileBackgroundTypeSimilarErrorGroup:
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorSimilarErrorGroup];
			break;
			
		case ZSGameBoardTileBackgroundTypeOtherError:
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorOtherError];
			break;
			
		case ZSGameBoardTileBackgroundTypeHighlightHintA:
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorHighlightHintA];
			break;
			
		case ZSGameBoardTileBackgroundTypeHighlightHintB:
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorHighlightHintB];
			break;
			
		case ZSGameBoardTileBackgroundTypeHighlightHintC:
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorHighlightHintC];
			break;
			
		case ZSGameBoardTileBackgroundTypeHighlightHintD:
			self.view.backgroundColor = [UIColor colorWithAlphaHexString:kTileColorHighlightHintD];
			break;
	}
	
}

- (void)reloadTextAndBackgroundType {
	// Choose the text color.
	if (ghosted) {
		textType = ZSGameBoardTileTextTypeGuessFingerDown;
	} else {
		if (tile.guess) {
			if (highlightGuessHint == ZSGameBoardTileTextHintHighlightTypeNone) {
				if (tile.locked) {
					textType = ZSGameBoardTileTextTypeAnswer;
				} else {
					if (selected) {
						if (error) {
							textType = ZSGameBoardTileTextTypeGuessErrorSelected;
						} else {
							textType = ZSGameBoardTileTextTypeGuessSelected;
						}
					} else {
						if (error) {
							textType = ZSGameBoardTileTextTypeGuessError;
						} else {
							textType = ZSGameBoardTileTextTypeGuess;
						}
					}
				}
			} else {
				switch (highlightGuessHint) {
					case ZSGameBoardTileTextHintHighlightTypeA: textType = ZSGameBoardTileTextTypeHighlightHintA; break;
					case ZSGameBoardTileTextHintHighlightTypeB: textType = ZSGameBoardTileTextTypeHighlightHintB; break;
					default: break;
				}
			}
		} else {
			for (NSInteger i = 0; i < 9; ++i) {
				UILabel *pencilView = [pencilViews objectAtIndex:i];
				
				switch (highlightPencilHints[i]) {
					case ZSGameBoardTilePencilTextTypeNormal: pencilView.textColor = [UIColor colorWithAlphaHexString:kTextColorPencil]; break;
					case ZSGameBoardTilePencilTextTypeHighlightHintA: pencilView.textColor = [UIColor colorWithAlphaHexString:kTextColorPencilHighlightHintA]; break;
					case ZSGameBoardTilePencilTextTypeHighlightHintB: pencilView.textColor = [UIColor colorWithAlphaHexString:kTextColorPencilHighlightHintB]; break;
				}
			}
		}
	}
	
	// Choose the background color.
	if (highlightedHintType == ZSGameBoardTileHintHighlightTypeNone) {
		if (selected) {
			backgroundType = ZSGameBoardTileBackgroundTypeSelected;
		} else {
			if (highlightedError) {
				// Todo: this should really only be set if the guess of the tile matches that of the selected tile
				if (tile.guess && highlightedSimilar) {
					backgroundType = ZSGameBoardTileBackgroundTypeSimilarError;
				} else {
					if (error) {
						backgroundType = ZSGameBoardTileBackgroundTypeOtherError;
					} else {
						backgroundType = ZSGameBoardTileBackgroundTypeSimilarErrorGroup;
					}
				}
			} else {
				if (error) {
					backgroundType = ZSGameBoardTileBackgroundTypeOtherError;
				} else {
					if (highlightedSimilar) {
						if (tile.guess) {
							backgroundType = ZSGameBoardTileBackgroundTypeSimilarAnswer;
						} else {
							backgroundType = ZSGameBoardTileBackgroundTypeSimilarPencil;
						}
					} else {
						backgroundType = ZSGameBoardTileBackgroundTypeDefault;
					}
				}
			}
		}
	} else {
		switch (highlightedHintType) {
			case ZSGameBoardTileHintHighlightTypeA: backgroundType = ZSGameBoardTileBackgroundTypeHighlightHintA; break;
			case ZSGameBoardTileHintHighlightTypeB: backgroundType = ZSGameBoardTileBackgroundTypeHighlightHintB; break;
			case ZSGameBoardTileHintHighlightTypeC: backgroundType = ZSGameBoardTileBackgroundTypeHighlightHintC; break;
			case ZSGameBoardTileHintHighlightTypeD: backgroundType = ZSGameBoardTileBackgroundTypeHighlightHintD; break;
			default: break;
		}
	}
}

- (void)showGuess {
	// Show the guess.
	guessView.hidden = NO;
	
	// Set visibility on all the pencil views.
	for (NSInteger i = 0; i < tile.gameBoard.size; ++i) {
		UILabel *pencilLabel = [pencilViews objectAtIndex:i];
		pencilLabel.hidden = YES;
	}		
}

- (void)hideGuess {
	// Hide the guess.
	guessView.hidden = YES;
	
	// Set visibility on all the pencil views.
	for (NSInteger i = 0; i < tile.gameBoard.size; ++i) {
		UILabel *pencilLabel = [pencilViews objectAtIndex:i];
		pencilLabel.hidden = ![tile getPencilForGuess:(i + 1)];
	}
}

#pragma mark - Touch Events

- (void)handleTap {
	NSLog(@"Tile: (%i, %i), group %i", tile.row, tile.col, tile.groupId);
	NSLog(@"Guess: %i", tile.guess);
	NSLog(@"Answer: %i", tile.answer);
	
	[delegate gameBoardTileWasTouched:self];
}

@end

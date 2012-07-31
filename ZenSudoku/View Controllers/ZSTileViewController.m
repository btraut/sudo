//
//  ZSTileViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/25/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSTileViewController.h"
#import "ZSTile.h"
#import "ZSGame.h"
#import "ZSBoard.h"
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
NSString * const kTextColorPencilHighlightHintA = @"#FFCE0000";
NSString * const kTextColorPencilHighlightHintB = @"#FF16BE3D";

NSString * const kTextShadowColorGuess = @"66FFFFFF";
NSString * const kTextShadowColorGuessSelected = @"44FFFFFF";
NSString * const kTextShadowColorGuessFingerDown = @"66FFFFFF";

NSString * const kTileColorDefault = @"#00FFFFFF";
NSString * const kTileColorSelected = @"#CC2F83D4";
NSString * const kTileColorHighlightSimilarAnswer = @"#4C2F83D4";
NSString * const kTileColorDarkHighlightSimilarAnswer = @"#4C3695f0";
NSString * const kTileColorHighlightSimilarPencil = @"#202f83d4";
NSString * const kTileColorDarkHighlightSimilarPencil = @"#205aa6fc";
NSString * const kTileColorSimilarError = @"#66A70404";
NSString * const kTileColorSimilarErrorGroup = @"#19A70404";
NSString * const kTileColorOtherError = @"#19A70404";
NSString * const kTileColorHighlightHintA = @"#4CF0F800";
NSString * const kTileColorHighlightHintB = @"#4C7542E2";
NSString * const kTileColorHighlightHintC = @"#4C34C0E3";
NSString * const kTileColorHighlightHintD = @"#4CFFAE00";

@interface ZSTileViewController () {
	BOOL _isDarkTile;
	
	ZSTileTextType _textType;
	ZSTileTextType _previousTextType;
	ZSTileBackgroundType _backgroundType;
	ZSTileBackgroundType _previousBackgroundType;
	
	BOOL _previouslyGhosted;
	NSInteger _previousValue;
}

@end

@implementation ZSTileViewController

@synthesize needsReload;
@synthesize tile, touchDelegate;
@synthesize ghostedValue, selected, highlightedSimilar, highlightedError, error;
@synthesize highlightedHintType, highlightGuessHint, highlightPencilHints;
@synthesize animateChanges;

- (id)init {
	self = [super init];
	
	if (self) {
		[self reset];
	}
	
	return self;
}

- (id)initWithTile:(ZSTile *)newTile {
	self = [self init];
	
	if (self) {
		tile = newTile;
	}
	
	return self;
}

- (void)reset {
	needsReload = YES;
	
	selected = NO;
	highlightedSimilar = NO;
	highlightedError = NO;
	error = NO;
	
	// Make sure the "previous" settings are different than the current ones.
	_previousTextType = -1;
	_previousBackgroundType = -1;
	_previousValue = -1;
}

#pragma mark - View Lifecycle

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Listen to the view's taps.
	UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleTap)];
	singleTapRecognizer.numberOfTapsRequired = 1; 
	[self.view addGestureRecognizer:singleTapRecognizer];
	
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
	highlightPencilHints = malloc(9 * sizeof(ZSTilePencilTextType));
	
	for (NSInteger i = 0; i < 9; ++i) {
		highlightPencilHints[i] = ZSTilePencilTextTypeNormal;
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
	
	// Determine if the tile is light or dark.
	switch (tile.groupId) {
		case 0:
		case 2:
		case 4:
		case 6:
		case 8:
			_isDarkTile = YES;
			break;
			
		default:
			_isDarkTile = NO;
			break;
	}
	
	[self.view addSubview:guessView];
}

- (void)viewDidUnload {
	free(highlightPencilHints);
	
	[super viewDidUnload];
}

#pragma mark - Sudoku Stuff

- (void)reloadView {
	BOOL waitToClearGuessText = NO;
	
	NSInteger newValue = 0;
	
	if (ghostedValue) {
		newValue = ghostedValue;
	} else if (tile.guess) {
		newValue = tile.guess;
	}
	
	if (tile.guess > 0 || ghostedValue > 0) {
		// Show the guess.
		[self _setGuessHidden:NO animated:NO];
		
		// Set visibility on all the pencil views.
		[self _changePencilsHidden:YES animated:NO];
	} else {
		// Hide the guess.
		[self _setGuessHidden:YES animated:self.animateChanges];
		
		// Set visibility on all the pencil views.
		[self _changePencilsHidden:NO animated:self.animateChanges];
		
		if (self.animateChanges && !ghostedValue) {
			waitToClearGuessText = YES;
		}
	}
	
	if (newValue != _previousValue) {
		if (!waitToClearGuessText) {
			guessView.text = [NSString stringWithFormat:@"%i", newValue];
		}
		
		_previousValue = newValue;
	}
	
	// Set the proper text and background types.
	[self reloadTextAndBackgroundType];
	
	// Set the text color based on text type.
	if (_textType != _previousTextType) {
		_previousTextType = _textType;
		
		switch (_textType) {
			case ZSTileTextTypeAnswer:
				guessView.textColor = [ZSTileViewController getTextColorAnswer];
				guessView.shadowColor = [ZSTileViewController getTextShadowColorGuess];
				break;
			
			case ZSTileTextTypeGuess:
				guessView.textColor = [ZSTileViewController getTextColorGuess];
				guessView.shadowColor = [ZSTileViewController getTextShadowColorGuess];
				break;
				
			case ZSTileTextTypeGuessSelected:
				guessView.textColor = [ZSTileViewController getTextColorGuessSelected];
				guessView.shadowColor = [ZSTileViewController getTextShadowColorGuessFingerDown];
				break;
				
			case ZSTileTextTypeGuessFingerDown:
				guessView.textColor = [ZSTileViewController getTextColorGuessFingerDown];
				guessView.shadowColor = [ZSTileViewController getTextShadowColorGuess];
				break;
				
			case ZSTileTextTypeGuessError:
				guessView.textColor = [ZSTileViewController getTextColorError];
				guessView.shadowColor = [ZSTileViewController getTextShadowColorGuess];
				break;
				
			case ZSTileTextTypeGuessErrorSelected:
				guessView.textColor = [ZSTileViewController getTextColorErrorSelected];
				guessView.shadowColor = [ZSTileViewController getTextShadowColorGuess];
				break;
				
			case ZSTileTextTypeHighlightHintA:
				guessView.textColor = [ZSTileViewController getTextColorHighlightHintA];
				guessView.shadowColor = [ZSTileViewController getTextShadowColorGuess];
				break;
				
			case ZSTileTextTypeHighlightHintB:
				guessView.textColor = [ZSTileViewController getTextColorHighlightHintB];
				guessView.shadowColor = [ZSTileViewController getTextShadowColorGuess];
				break;
		}
	}

	// Set the background color based on text type.
	if (_backgroundType != _previousBackgroundType) {
		_previousBackgroundType = _backgroundType;
		
		switch (_backgroundType) {
			case ZSTileBackgroundTypeDefault:
				self.view.backgroundColor = [ZSTileViewController getTileColorDefault];
				break;
				
			case ZSTileBackgroundTypeSelected:
				self.view.backgroundColor = [ZSTileViewController getTileColorSelected];
				break;
				
			case ZSTileBackgroundTypeSimilarPencil:
				self.view.backgroundColor = [UIColor colorWithAlphaHexString:_isDarkTile ? kTileColorDarkHighlightSimilarPencil : kTileColorHighlightSimilarPencil];
				break;
				
			case ZSTileBackgroundTypeSimilarAnswer:
				self.view.backgroundColor = [UIColor colorWithAlphaHexString:_isDarkTile ? kTileColorDarkHighlightSimilarAnswer : kTileColorHighlightSimilarAnswer];
				break;
				
			case ZSTileBackgroundTypeSimilarError:
				self.view.backgroundColor = [ZSTileViewController getTileColorSimilarError];
				break;
				
			case ZSTileBackgroundTypeSimilarErrorGroup:
				self.view.backgroundColor = [ZSTileViewController getTileColorSimilarErrorGroup];
				break;
				
			case ZSTileBackgroundTypeOtherError:
				self.view.backgroundColor = [ZSTileViewController getTileColorOtherError];
				break;
				
			case ZSTileBackgroundTypeHighlightHintA:
				self.view.backgroundColor = [ZSTileViewController getTileColorHighlightHintA];
				break;
				
			case ZSTileBackgroundTypeHighlightHintB:
				self.view.backgroundColor = [ZSTileViewController getTileColorHighlightHintB];
				break;
				
			case ZSTileBackgroundTypeHighlightHintC:
				self.view.backgroundColor = [ZSTileViewController getTileColorHighlightHintC];
				break;
				
			case ZSTileBackgroundTypeHighlightHintD:
				self.view.backgroundColor = [ZSTileViewController getTileColorHighlightHintD];
				break;
		}
	}
	
	// Reload is done. We no longer need to reload this tile.
	self.needsReload = NO;
}

- (void)reloadTextAndBackgroundType {
	// Choose the text color.
	if (ghostedValue) {
		_textType = ZSTileTextTypeGuessFingerDown;
	} else {
		if (tile.guess) {
			if (highlightGuessHint == ZSTileTextHintHighlightTypeNone) {
				if (tile.locked) {
					_textType = ZSTileTextTypeAnswer;
				} else {
					if (selected) {
						if (error) {
							_textType = ZSTileTextTypeGuessErrorSelected;
						} else {
							_textType = ZSTileTextTypeGuessSelected;
						}
					} else {
						if (error) {
							_textType = ZSTileTextTypeGuessError;
						} else {
							_textType = ZSTileTextTypeGuess;
						}
					}
				}
			} else {
				switch (highlightGuessHint) {
					case ZSTileTextHintHighlightTypeA: _textType = ZSTileTextTypeHighlightHintA; break;
					case ZSTileTextHintHighlightTypeB: _textType = ZSTileTextTypeHighlightHintB; break;
					default: break;
				}
			}
		} else {
			for (NSInteger i = 0; i < 9; ++i) {
				UILabel *pencilView = [pencilViews objectAtIndex:i];
				
				switch (highlightPencilHints[i]) {
					case ZSTilePencilTextTypeNormal: pencilView.textColor = [ZSTileViewController getTextColorPencil]; break;
					case ZSTilePencilTextTypeHighlightHintA: pencilView.textColor = [ZSTileViewController getTextColorPencilHighlightHintA]; break;
					case ZSTilePencilTextTypeHighlightHintB: pencilView.textColor = [ZSTileViewController getTextColorPencilHighlightHintB]; break;
				}
			}
		}
	}
	
	// Choose the background color.
	if (highlightedHintType == ZSTileHintHighlightTypeNone) {
		if (selected) {
			_backgroundType = ZSTileBackgroundTypeSelected;
		} else {
			if (highlightedError) {
				if (tile.guess && highlightedSimilar) {
					_backgroundType = ZSTileBackgroundTypeSimilarError;
				} else {
					if (error) {
						_backgroundType = ZSTileBackgroundTypeOtherError;
					} else {
						_backgroundType = ZSTileBackgroundTypeSimilarErrorGroup;
					}
				}
			} else {
				if (error) {
					_backgroundType = ZSTileBackgroundTypeOtherError;
				} else {
					if (highlightedSimilar) {
						if (tile.guess) {
							_backgroundType = ZSTileBackgroundTypeSimilarAnswer;
						} else {
							_backgroundType = ZSTileBackgroundTypeSimilarPencil;
						}
					} else {
						_backgroundType = ZSTileBackgroundTypeDefault;
					}
				}
			}
		}
	} else {
		switch (highlightedHintType) {
			case ZSTileHintHighlightTypeA: _backgroundType = ZSTileBackgroundTypeHighlightHintA; break;
			case ZSTileHintHighlightTypeB: _backgroundType = ZSTileBackgroundTypeHighlightHintB; break;
			case ZSTileHintHighlightTypeC: _backgroundType = ZSTileBackgroundTypeHighlightHintC; break;
			case ZSTileHintHighlightTypeD: _backgroundType = ZSTileBackgroundTypeHighlightHintD; break;
			default: break;
		}
	}
}

- (void)_setGuessHidden:(BOOL)hidden animated:(BOOL)animated {
	if (animated) {
		if (guessView.hidden && !hidden) {
			guessView.alpha = 0;
			guessView.hidden = NO;
		}
		
		[UIView
		 animateWithDuration:0.3f
		 delay:0
		 options:
		 UIViewAnimationOptionCurveEaseOut |
		 UIViewAnimationOptionOverrideInheritedDuration |
		 UIViewAnimationOptionOverrideInheritedCurve
		 animations:^{
			 if (hidden) {
				 guessView.alpha = 0;
			 } else {
				 guessView.alpha = 1;
			 }
		 }
		 completion:^(BOOL finished){
			 if (guessView.alpha == 0) {
				 guessView.hidden = YES;
				 guessView.alpha = 1;
				 
				 guessView.text = [NSString stringWithFormat:@"%i", _previousValue];
			 }
		 }];
	} else {
		guessView.hidden = hidden;
	}
}

- (void)_changePencilsHidden:(BOOL)hidden animated:(BOOL)animated {
	if (animated) {
		if (!hidden) {
			// If a hidden pencil is becoming visible, we need to start by setting its alpha to 0 and then making it visible.
			for (NSInteger i = 0; i < tile.board.size; ++i) {
				UILabel *pencilLabel = [pencilViews objectAtIndex:i];
				
				if ([tile getPencilForGuess:(i + 1)] && pencilLabel.hidden) {
					pencilLabel.alpha = 0;
					pencilLabel.hidden = NO;
				}
			}
		}
		
		[UIView
		 animateWithDuration:0.3f
		 delay:0
		 options:
			UIViewAnimationOptionCurveEaseOut |
			UIViewAnimationOptionOverrideInheritedDuration |
			UIViewAnimationOptionOverrideInheritedCurve
		 animations:^{
			 for (NSInteger i = 0; i < tile.board.size; ++i) {
				 UILabel *pencilLabel = [pencilViews objectAtIndex:i];
				 
				 if (hidden && !pencilLabel.hidden) {
					 pencilLabel.alpha = 0;
				 } else if (![tile getPencilForGuess:(i + 1)] && !pencilLabel.hidden) {
					 pencilLabel.alpha = 0;
				 } else if ([tile getPencilForGuess:(i + 1)] && pencilLabel.alpha == 0) {
					 pencilLabel.alpha = 1;
				 }
			 }
		 }
		 completion:^(BOOL finished){
			 // If a pencil is being hidden, we want to actually set its visibility to hidden and its alpha back to 1.
			 for (NSInteger i = 0; i < tile.board.size; ++i) {
				 UILabel *pencilLabel = [pencilViews objectAtIndex:i];
				 
				 if (pencilLabel.alpha == 0) {
					 pencilLabel.hidden = YES;
					 pencilLabel.alpha = 1;
				 }
			 }
		 }];
	} else {
		for (NSInteger i = 0; i < tile.board.size; ++i) {
			UILabel *pencilLabel = [pencilViews objectAtIndex:i];
			
			if (hidden) {
				pencilLabel.hidden = YES;
			} else {
				pencilLabel.hidden = ![tile getPencilForGuess:(i + 1)];
			}
		}
	}
}

#pragma mark - Touch Events

- (void)handleTap {
	// NSLog(@"Tile: (%i, %i), group %i", tile.row, tile.col, tile.groupId);
	// NSLog(@"Guess: %i", tile.guess);
	// NSLog(@"Answer: %i", tile.answer);
	
	[touchDelegate tileWasTapped:self];
}

#pragma mark - Colors

+ (UIColor *)getTextColorAnswer {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextColorAnswer];
	}
	
	return color;
}

+ (UIColor *)getTextColorGuess {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextColorGuess];
	}
	
	return color;
}

+ (UIColor *)getTextColorGuessSelected {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextColorGuessSelected];
	}
	
	return color;
}

+ (UIColor *)getTextColorGuessFingerDown {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextColorGuessFingerDown];
	}
	
	return color;
}

+ (UIColor *)getTextColorError {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextColorError];
	}
	
	return color;
}

+ (UIColor *)getTextColorErrorSelected {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextColorErrorSelected];
	}
	
	return color;
}

+ (UIColor *)getTextColorHighlightHintA {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextColorHighlightHintA];
	}
	
	return color;
}

+ (UIColor *)getTextColorHighlightHintB {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextColorHighlightHintB];
	}
	
	return color;
}

+ (UIColor *)getTextColorPencil {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextColorPencil];
	}
	
	return color;
}

+ (UIColor *)getTextColorPencilHighlightHintA {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextColorPencilHighlightHintA];
	}
	
	return color;
}

+ (UIColor *)getTextColorPencilHighlightHintB {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextColorPencilHighlightHintB];
	}
	
	return color;
}

+ (UIColor *)getTextShadowColorGuess {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextShadowColorGuess];
	}
	
	return color;
}

+ (UIColor *)getTextShadowColorGuessSelected {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextShadowColorGuessSelected];
	}
	
	return color;
}

+ (UIColor *)getTextShadowColorGuessFingerDown {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTextShadowColorGuessFingerDown];
	}
	
	return color;
}

+ (UIColor *)getTileColorDefault {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorDefault];
	}
	
	return color;
}

+ (UIColor *)getTileColorSelected {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorSelected];
	}
	
	return color;
}

+ (UIColor *)getTileColorHighlightSimilarAnswer {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorHighlightSimilarAnswer];
	}
	
	return color;
}

+ (UIColor *)getTileColorDarkHighlightSimilarAnswer {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorDarkHighlightSimilarAnswer];
	}
	
	return color;
}

+ (UIColor *)getTileColorHighlightSimilarPencil {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorHighlightSimilarPencil];
	}
	
	return color;
}

+ (UIColor *)getTileColorDarkHighlightSimilarPencil {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorDarkHighlightSimilarPencil];
	}
	
	return color;
}

+ (UIColor *)getTileColorSimilarError {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorSimilarError];
	}
	
	return color;
}

+ (UIColor *)getTileColorSimilarErrorGroup {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorSimilarErrorGroup];
	}
	
	return color;
}

+ (UIColor *)getTileColorOtherError {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorOtherError];
	}
	
	return color;
}

+ (UIColor *)getTileColorHighlightHintA {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorHighlightHintA];
	}
	
	return color;
}

+ (UIColor *)getTileColorHighlightHintB {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorHighlightHintB];
	}
	
	return color;
}

+ (UIColor *)getTileColorHighlightHintC {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorHighlightHintC];
	}
	
	return color;
}

+ (UIColor *)getTileColorHighlightHintD {
	static UIColor *color = nil;
	
	if (color == nil) {
		color = [UIColor colorWithAlphaHexString:kTileColorHighlightHintD];
	}
	
	return color;
}

@end

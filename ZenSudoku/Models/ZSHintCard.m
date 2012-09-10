//
//  ZSHintCard.m
//  ZenSudoku
//
//  Created by Brent Traut on 4/27/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHintCard.h"

NSString * const kDictionaryKeyTileRow = @"kDictionaryKeyTileRow";
NSString * const kDictionaryKeyTileCol = @"kDictionaryKeyTileCol";
NSString * const kDictionaryKeyTileValue = @"kDictionaryKeyTileValue";
NSString * const kDictionaryKeyHighlightType = @"kDictionaryKeyHighlightType";

@implementation ZSHintCard

@synthesize text;
@synthesize highlightPencils, highlightAnswers, highlightTiles, removePencils, addPencils, removeGuess, setGuess, setAutoPencil;

- (id)init {
	self = [super init];
	
	if (self) {
		highlightPencils = [NSMutableArray array];
		highlightAnswers = [NSMutableArray array];
		highlightTiles = [NSMutableArray array];
		removePencils = [NSMutableArray array];
		addPencils = [NSMutableArray array];
		removeGuess = [NSMutableArray array];
		setGuess = [NSMutableArray array];
	}
	
	return self;
}

- (void)addInstructionHighlightPencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col highlightType:(ZSTilePencilTextHintHighlightType)pencilTextHintHighlightType {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:row], kDictionaryKeyTileRow,
						  [NSNumber numberWithInt:col], kDictionaryKeyTileCol,
						  [NSNumber numberWithInt:pencil], kDictionaryKeyTileValue,
						  [NSNumber numberWithInt:pencilTextHintHighlightType], kDictionaryKeyHighlightType,
						  nil];
	[highlightPencils addObject:dict];
}

- (void)addInstructionHighlightAnswerForTileAtRow:(NSInteger)row col:(NSInteger)col highlightType:(ZSTileTextHintHighlightType)textHintHighlightType {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:row], kDictionaryKeyTileRow,
						  [NSNumber numberWithInt:col], kDictionaryKeyTileCol,
						  [NSNumber numberWithInt:textHintHighlightType], kDictionaryKeyHighlightType,
						  nil];
	[highlightAnswers addObject:dict];
}

- (void)addInstructionHighlightTileAtRow:(NSInteger)row col:(NSInteger)col highlightType:(ZSTileHintHighlightType)hintHighlightType {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:row], kDictionaryKeyTileRow,
						  [NSNumber numberWithInt:col], kDictionaryKeyTileCol,
						  [NSNumber numberWithInt:hintHighlightType], kDictionaryKeyHighlightType,
						  nil];
	[highlightTiles addObject:dict];
}

- (void)addInstructionRemovePencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:row], kDictionaryKeyTileRow,
						  [NSNumber numberWithInt:col], kDictionaryKeyTileCol,
						  [NSNumber numberWithInt:pencil], kDictionaryKeyTileValue,
						  nil];
	[removePencils addObject:dict];
}

- (void)addInstructionAddPencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:row], kDictionaryKeyTileRow,
						  [NSNumber numberWithInt:col], kDictionaryKeyTileCol,
						  [NSNumber numberWithInt:pencil], kDictionaryKeyTileValue,
						  nil];
	[addPencils addObject:dict];
}

- (void)addInstructionRemoveGuessForTileAtRow:(NSInteger)row col:(NSInteger)col {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:row], kDictionaryKeyTileRow,
						  [NSNumber numberWithInt:col], kDictionaryKeyTileCol,
						  nil];
	[removeGuess addObject:dict];
}

- (void)addInstructionSetGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithInt:row], kDictionaryKeyTileRow,
						  [NSNumber numberWithInt:col], kDictionaryKeyTileCol,
						  [NSNumber numberWithInt:guess], kDictionaryKeyTileValue,
						  nil];
	[setGuess addObject:dict];
}

- (BOOL)modifiesHistory {
	if (removePencils.count || addPencils.count || removeGuess.count || setGuess.count || setAutoPencil) {
		return YES;
	}
	
	return NO;
}

@end

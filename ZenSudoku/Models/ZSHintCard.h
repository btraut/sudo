//
//  ZSHintCard.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZSGameBoardTileViewController.h"

@interface ZSHintCard : NSObject {
	NSString *text;
	
	NSMutableArray *highlightPencils;
	NSMutableArray *highlightAnswers;
	NSMutableArray *highlightTiles;
	NSMutableArray *removePencils;
	NSMutableArray *addPencils;
	NSMutableArray *removeGuess;
	NSMutableArray *setGuess;
	BOOL setAutoPencil;
	
	BOOL allowsLearn;
}

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSMutableArray *highlightPencils;
@property (nonatomic, strong) NSMutableArray *highlightAnswers;
@property (nonatomic, strong) NSMutableArray *highlightTiles;
@property (nonatomic, strong) NSMutableArray *removePencils;
@property (nonatomic, strong) NSMutableArray *addPencils;
@property (nonatomic, strong) NSMutableArray *removeGuess;
@property (nonatomic, strong) NSMutableArray *setGuess;
@property (nonatomic, assign) BOOL setAutoPencil;

@property (nonatomic, assign) BOOL allowsLearn;

- (void)addInstructionHighlightPencilForTileAtRow:(NSInteger)row col:(NSInteger)col pencil:(NSInteger)pencil highlightType:(ZSGameBoardTilePencilTextHintHighlightType)pencilTextHintHighlightType;
- (void)addInstructionHighlightAnswerForTileAtRow:(NSInteger)row col:(NSInteger)col highlightType:(ZSGameBoardTileTextHintHighlightType)textHintHighlightType;
- (void)addInstructionHighlightTileAtRow:(NSInteger)row col:(NSInteger)col highlightType:(ZSGameBoardTileHintHighlightType)hintHighlightType;
- (void)addInstructionRemovePencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)addInstructionAddPencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)addInstructionRemoveGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)addInstructionSetGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;

@end

extern NSString * const kDictionaryKeyTileRow;
extern NSString * const kDictionaryKeyTileCol;
extern NSString * const kDictionaryKeyTileValue;
extern NSString * const kDictionaryKeyHighlightType;

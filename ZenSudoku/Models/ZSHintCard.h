//
//  ZSHintCard.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZSGameBoardTileViewController.h"

@interface ZSHintCard : NSObject

@property (strong) NSString *text;

@property (strong) NSMutableArray *highlightPencils;
@property (strong) NSMutableArray *highlightAnswers;
@property (strong) NSMutableArray *highlightTiles;
@property (strong) NSMutableArray *removePencils;
@property (strong) NSMutableArray *addPencils;
@property (strong) NSMutableArray *removeGuess;
@property (strong) NSMutableArray *setGuess;
@property (assign) BOOL setAutoPencil;

@property (assign) BOOL allowsLearn;

- (void)addInstructionHighlightPencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col highlightType:(ZSGameBoardTilePencilTextHintHighlightType)pencilTextHintHighlightType;
- (void)addInstructionHighlightAnswerForTileAtRow:(NSInteger)row col:(NSInteger)col highlightType:(ZSGameBoardTileTextHintHighlightType)textHintHighlightType;
- (void)addInstructionHighlightTileAtRow:(NSInteger)row col:(NSInteger)col highlightType:(ZSGameBoardTileHintHighlightType)hintHighlightType;
- (void)addInstructionRemovePencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)addInstructionAddPencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)addInstructionRemoveGuessForTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)addInstructionSetGuess:(NSInteger)guess forTileAtRow:(NSInteger)row col:(NSInteger)col;

@end

extern NSString * const kDictionaryKeyTileRow;
extern NSString * const kDictionaryKeyTileCol;
extern NSString * const kDictionaryKeyTileValue;
extern NSString * const kDictionaryKeyHighlightType;

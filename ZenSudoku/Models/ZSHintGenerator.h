//
//  ZSHintGenerator.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/28/11.
//  Copyright (c) 2011 Ten Four Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ZSGameSolveResultSucceeded,
	ZSGameSolveResultFailedNoSolution,
	ZSGameSolveResultFailedMultipleSolutions
} ZSGameSolveResult;

typedef enum {
	ZSChainMapResultUnset,
	ZSChainMapResultLinkedOn,
	ZSChainMapResultLinkedOff,
	ZSChainMapResultLinkedConflicted,
	ZSChainMapResultRelatedOn,
	ZSChainMapResultRelatedOff,
	ZSChainMapResultRelatedConflicted,
	ZSChainMapResultUnrelated
} ZSChainMapResult;

typedef struct {
	NSInteger *slotIndexes;
	NSInteger totalSlotIndexes;
	NSInteger matchIndex;
} ZSXWingSlotMatch;

typedef enum {
	ZSHintGeneratorTileScopeRow,
	ZSHintGeneratorTileScopeCol,
	ZSHintGeneratorTileScopeGroup
} ZSHintGeneratorTileScope;

typedef struct {
	NSInteger row;
	NSInteger col;
	NSInteger pencil;
} ZSHintGeneratorTileInstruction;

@protocol ZSHintGeneratorUtility <NSObject>

- (NSArray *)generateHint;

@end

@class ZSFastGameBoard;
@class ZSGameBoard;

@interface ZSHintGenerator : NSObject

- (id)init;
- (id)initWithSize:(NSInteger)size;
- (void)dealloc;

- (void)copyGameStateFromGameBoard:(ZSGameBoard *)gameBoard;

- (NSArray *)generateHint;

@end

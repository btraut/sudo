//
//  ZSHintGeneratorEliminatePencilsNakedSubgroup.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorEliminatePencilsNakedSubgroup : NSObject <ZSHintGeneratorUtility> {
	BOOL subgroupExistsInSameRow;
	BOOL subgroupExistsInSameCol;
	BOOL subgroupExistsInSameGroup;
	
	NSInteger totalPencilsToEliminate;
}

@property (assign) BOOL subgroupExistsInSameRow;
@property (assign) BOOL subgroupExistsInSameCol;
@property (assign) BOOL subgroupExistsInSameGroup;

- (id)initWithSubgroupSize:(NSInteger)size;

- (void)resetTilesAndInstructions;

- (void)addGroupTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addSubgroupTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile;

- (NSArray *)generateHint;

@end

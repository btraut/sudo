//
//  ZSHintGeneratorEliminatePencilsNakedSubgroup.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorEliminatePencilsNakedSubgroup : NSObject <ZSHintGeneratorUtility> {
	BOOL subgroupExistsInSameRow;
	BOOL subgroupExistsInSameCol;
	BOOL subgroupExistsInSameGroup;
	
	NSInteger totalPencilsToEliminate;
}

@property (nonatomic, assign) BOOL subgroupExistsInSameRow;
@property (nonatomic, assign) BOOL subgroupExistsInSameCol;
@property (nonatomic, assign) BOOL subgroupExistsInSameGroup;

- (id)initWithSubgroupSize:(NSInteger)size;

- (void)resetTilesAndInstructions;

- (void)addGroupTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addSubgroupTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile;

- (NSArray *)generateHint;

@end

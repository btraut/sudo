//
//  ZSHintGeneratorEliminatePencilsNakedSubgroup.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

typedef struct {
	NSInteger row;
	NSInteger col;
	NSInteger pencil;
} ZSHintGeneratorEliminatePencilsNakedSubgroupInstruction;

@interface ZSHintGeneratorEliminatePencilsNakedSubgroup : NSObject <ZSHintGeneratorUtility> {
	BOOL subgroupExistsInSameRow;
	BOOL subgroupExistsInSameCol;
	BOOL subgroupExistsInSameGroup;
}

@property (nonatomic, assign) BOOL subgroupExistsInSameRow;
@property (nonatomic, assign) BOOL subgroupExistsInSameCol;
@property (nonatomic, assign) BOOL subgroupExistsInSameGroup;

- (id)initWithSubgroupSize:(NSInteger)size;

- (void)resetTilesAndInstructions;

- (void)addGroupTile:(ZSHintGeneratorEliminatePencilsNakedSubgroupInstruction)tile;
- (void)addSubGroupTile:(ZSHintGeneratorEliminatePencilsNakedSubgroupInstruction)tile;
- (void)addPencilToEliminate:(ZSHintGeneratorEliminatePencilsNakedSubgroupInstruction)tile;

- (NSArray *)generateHint;

@end

//
//  ZSHintGeneratorEliminatePencilsHiddenSubgroup.h
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
} ZSHintGeneratorEliminatePencilsHiddenSubgroupInstruction;

@interface ZSHintGeneratorEliminatePencilsHiddenSubgroup : NSObject <ZSHintGeneratorUtility> {
	ZSHintGeneratorTileScope scope;
}

@property (nonatomic, assign) ZSHintGeneratorTileScope scope;

- (id)initWithSubgroupSize:(NSInteger)size;

- (void)resetTilesAndInstructions;

- (void)addSubgroupPencil:(NSInteger)pencil;
- (void)addGroupTile:(ZSHintGeneratorEliminatePencilsHiddenSubgroupInstruction)tile;
- (void)addSubgroupTile:(ZSHintGeneratorEliminatePencilsHiddenSubgroupInstruction)tile;
- (void)addPencilToEliminate:(ZSHintGeneratorEliminatePencilsHiddenSubgroupInstruction)tile;

- (NSArray *)generateHint;

@end

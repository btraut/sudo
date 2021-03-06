//
//  ZSHintGeneratorEliminatePencilsHiddenSubgroup.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorEliminatePencilsHiddenSubgroup : NSObject <ZSHintGeneratorUtility>

@property (assign) ZSHintGeneratorTileScope scope;

- (id)initWithSubgroupSize:(NSInteger)size;

- (void)resetTilesAndInstructions;

- (void)addSubgroupPencil:(NSInteger)pencil;
- (void)addGroupTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addSubgroupTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile;

- (NSArray *)generateHint;

@end

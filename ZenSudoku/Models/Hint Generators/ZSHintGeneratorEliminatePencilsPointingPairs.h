//
//  ZSHintGeneratorEliminatePencilsPointingPairs.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorEliminatePencilsPointingPairs : NSObject <ZSHintGeneratorUtility> {
	ZSHintGeneratorTileScope scope;
	NSInteger targetPencil;
}

@property (assign) ZSHintGeneratorTileScope scope;
@property (assign) NSInteger targetPencil;

- (void)resetTilesAndInstructions;

- (void)addPointingPairTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addGroupTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addRowOrColTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile;

- (NSArray *)generateHint;

@end

//
//  ZSHintGeneratorEliminatePencilsFinnedXWing.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorEliminatePencilsFinnedXWing : NSObject <ZSHintGeneratorUtility>

@property (assign) ZSHintGeneratorTileScope scope;
@property (assign) NSInteger targetPencil;
@property (assign) NSInteger size;

- (void)resetTilesAndInstructions;

- (void)addFinnedXWingTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addFinTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile;

- (NSArray *)generateHint;

@end

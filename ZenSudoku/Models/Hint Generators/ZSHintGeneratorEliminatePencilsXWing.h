//
//  ZSHintGeneratorEliminatePencilsXWing.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorEliminatePencilsXWing : NSObject <ZSHintGeneratorUtility>

@property (assign) ZSHintGeneratorTileScope scope;
@property (assign) NSInteger targetPencil;
@property (assign) NSInteger size;

- (void)resetTilesAndInstructions;

- (void)addXWingTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile;

- (NSArray *)generateHint;

@end

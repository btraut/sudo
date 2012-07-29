//
//  ZSHintGeneratorEliminatePencilsRemotePairs
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorEliminatePencilsRemotePairs : NSObject <ZSHintGeneratorUtility>

@property (assign) NSInteger chainPencil1;
@property (assign) NSInteger chainPencil2;

- (void)resetTilesAndInstructions;

- (void)addEvenChainLink:(ZSHintGeneratorTileInstruction)tile;
- (void)addOddChainLink:(ZSHintGeneratorTileInstruction)tile;

- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile;

- (NSArray *)generateHint;

@end

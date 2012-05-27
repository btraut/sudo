//
//  ZSHintGeneratorEliminatePencilsBoxLineReduction.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorEliminatePencilsBoxLineReduction : NSObject <ZSHintGeneratorUtility> {
	ZSHintGeneratorTileScope scope;
	NSInteger targetPencil;
}

@property (nonatomic, assign) ZSHintGeneratorTileScope scope;
@property (nonatomic, assign) NSInteger targetPencil;

- (void)resetTilesAndInstructions;

- (void)addBoxLineReductionTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addGroupTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addRowOrColTile:(ZSHintGeneratorTileInstruction)tile;
- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile;

- (NSArray *)generateHint;

@end

//
//  ZSHintGeneratorEliminatePencilsYWing
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorEliminatePencilsYWing : NSObject <ZSHintGeneratorUtility>

@property (assign) ZSHintGeneratorTileInstruction hingeTile;
@property (assign) ZSHintGeneratorTileInstruction pincer1;
@property (assign) ZSHintGeneratorTileInstruction pincer2;
@property (assign) NSInteger hingePencil1;
@property (assign) NSInteger hingePencil2;
@property (assign) NSInteger targetPencil;

- (void)addPencilToEliminate:(ZSHintGeneratorTileInstruction)tile;

- (NSArray *)generateHint;

@end

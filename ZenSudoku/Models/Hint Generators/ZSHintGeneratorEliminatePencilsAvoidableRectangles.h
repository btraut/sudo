//
//  ZSHintGeneratorEliminatePencilsAvoidableRectangles
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorEliminatePencilsAvoidableRectangles : NSObject <ZSHintGeneratorUtility>

@property (assign) ZSHintGeneratorTileInstruction hingeTile;
@property (assign) ZSHintGeneratorTileInstruction pincer1;
@property (assign) ZSHintGeneratorTileInstruction pincer2;
@property (assign) ZSHintGeneratorTileInstruction eliminateInstruction;

@property (assign) NSInteger diagonalAnswer;
@property (assign) NSInteger impossibleAnswer;

- (NSArray *)generateHint;

@end

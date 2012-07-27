//
//  ZSHintGeneratorFixIncorrectGuesses.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorFixIncorrectGuesses : NSObject <ZSHintGeneratorUtility>

- (void)resetTilesAndInstructions;

- (void)addIncorrectGuess:(ZSHintGeneratorTileInstruction)tile;

- (NSArray *)generateHint;

@end

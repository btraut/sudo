//
//  ZSHintGeneratorFixMissingPencil.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZSHintGenerator.h"

typedef struct {
	NSInteger row;
	NSInteger col;
	NSInteger pencil;
} ZSHintGeneratorFixMissingPencilInstruction;

@interface ZSHintGeneratorFixMissingPencil : NSObject <ZSHintGeneratorUtility>

- (id)initWithSize:(NSInteger)size;

- (void)addMissingPencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col;
- (void)addPencil:(NSInteger)pencil forTileAtRow:(NSInteger)row col:(NSInteger)col;

- (void)setTotalTilesWithPencils:(NSInteger)totalTilesWithPencils;

- (NSArray *)generateHint;

@end

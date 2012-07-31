//
//  ZSHintGeneratorNoHint.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZSHintGenerator.h"

@class ZSBoard;

@interface ZSHintGeneratorNoHint : NSObject <ZSHintGeneratorUtility>

@property (assign) ZSHintGeneratorTileInstruction randomEliminateInstruction;

- (NSArray *)generateHint;

@end
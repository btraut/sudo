//
//  ZSHintGeneratorSolveOnlyChoice.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorSolveOnlyChoice : NSObject <ZSHintGeneratorUtility>

- (void)setOnlyChoice:(NSInteger)choice forTileInRow:(NSInteger)row col:(NSInteger)col;

- (NSArray *)generateHint;

@end

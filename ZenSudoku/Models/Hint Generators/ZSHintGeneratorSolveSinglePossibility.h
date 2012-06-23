//
//  ZSHintGeneratorSolveSinglePossibility.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 Ten Four Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorSolveSinglePossibility : NSObject <ZSHintGeneratorUtility>

- (void)setSinglePossibility:(NSInteger)guess forTileInRow:(NSInteger)row col:(NSInteger)col scope:(ZSHintGeneratorTileScope)scope;

- (NSArray *)generateHint;

@end

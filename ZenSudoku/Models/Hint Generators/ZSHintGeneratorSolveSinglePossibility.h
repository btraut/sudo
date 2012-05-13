//
//  ZSHintGeneratorSolveSinglePossibility.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

typedef enum {
	ZSHintGeneratorSolveSinglePossibilityScopeRow,
	ZSHintGeneratorSolveSinglePossibilityScopeCol,
	ZSHintGeneratorSolveSinglePossibilityScopeGroup
} ZSHintGeneratorSolveSinglePossibilityScope;

@interface ZSHintGeneratorSolveSinglePossibility : NSObject <ZSHintGeneratorUtility>

- (void)setSinglePossibility:(NSInteger)guess forTileInRow:(NSInteger)row col:(NSInteger)col scope:(ZSHintGeneratorSolveSinglePossibilityScope)scope;

- (NSArray *)generateHint;

@end

//
//  ZSHintGeneratorFixIncorrectGuess.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZSHintGenerator.h"

@interface ZSHintGeneratorFixIncorrectGuess : NSObject <ZSHintGeneratorUtility>

- (void)setIncorrectTileRow:(NSInteger)row col:(NSInteger)col;

- (NSArray *)generateHint;

@end

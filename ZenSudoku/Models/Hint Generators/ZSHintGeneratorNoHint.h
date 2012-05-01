//
//  ZSHintGeneratorNoHint.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZSHintGenerator.h"

@class ZSGameBoard;

@interface ZSHintGeneratorNoHint : NSObject <ZSHintGeneratorUtility>

- (void)setGameBoard:(ZSGameBoard *)gameBoard;

- (NSArray *)generateHint;

@end
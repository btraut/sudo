//
//  ZSGameHistoryEntry.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSGameTile.h"

typedef enum {
	ZSGameHistoryEntryTypePencil,
	ZSGameHistoryEntryTypeGuess
} ZSGameHistoryEntryType;

@interface ZSGameHistoryEntry : NSObject {
	ZSGameHistoryEntryType type;
	ZSGameTile *tile;
	NSInteger previousValue;
	NSInteger pencilNumber;
}

@property (assign) ZSGameHistoryEntryType type;
@property (strong) ZSGameTile *tile;
@property (assign) NSInteger previousValue;
@property (assign) NSInteger pencilNumber;

+ (id)undoStop;
+ (id)undoDescriptionWithType:(ZSGameHistoryEntryType)newType tile:(ZSGameTile *)newTile previousValue:(NSInteger)newPreviousValue;
- (id)initWithType:(ZSGameHistoryEntryType)newType tile:(ZSGameTile *)newTile previousValue:(NSInteger)newPreviousValue;

@end

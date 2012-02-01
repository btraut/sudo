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
	int row;
	int col;
	int previousValue;
	int pencilNumber;
}

@property (assign) ZSGameHistoryEntryType type;
@property (assign) int row;
@property (assign) int col;
@property (assign) int previousValue;
@property (assign) int pencilNumber;

+ (id)undoStop;
+ (id)undoDescriptionWithType:(ZSGameHistoryEntryType)newType tile:(ZSGameTile *)newTile previousValue:(int)newPreviousValue;
- (id)initWithType:(ZSGameHistoryEntryType)newType tile:(ZSGameTile *)newTile previousValue:(int)newPreviousValue;
- (id)initWithType:(ZSGameHistoryEntryType)newType row:(int)row col:(int)col previousValue:(int)newPreviousValue;

- (id)initWithDictionaryRepresentation:(NSDictionary *)dict;
- (NSDictionary *)getDictionaryRepresentation;

@end

extern NSString * const kDictionaryRepresentationGameHistoryEntryTypeKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryTileRowKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryTileColKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryPreviousValueKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryPencilNumberKey;

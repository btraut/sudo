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

@interface ZSGameHistoryEntry : NSObject

@property (assign) ZSGameHistoryEntryType type;
@property (assign) NSInteger row;
@property (assign) NSInteger col;
@property (assign) NSInteger previousValue;
@property (assign) NSInteger pencilNumber;

+ (id)undoStop;
+ (id)undoDescriptionWithType:(ZSGameHistoryEntryType)newType tile:(ZSGameTile *)newTile previousValue:(NSInteger)newPreviousValue;
- (id)initWithType:(ZSGameHistoryEntryType)newType tile:(ZSGameTile *)newTile previousValue:(NSInteger)newPreviousValue;
- (id)initWithType:(ZSGameHistoryEntryType)newType row:(NSInteger)row col:(NSInteger)col previousValue:(NSInteger)newPreviousValue;

- (id)initWithDictionaryRepresentation:(NSDictionary *)dict;
- (NSDictionary *)getDictionaryRepresentation;

@end

extern NSString * const kDictionaryRepresentationGameHistoryEntryTypeKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryTileRowKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryTileColKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryPreviousValueKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryPencilNumberKey;

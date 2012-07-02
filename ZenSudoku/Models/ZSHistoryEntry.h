//
//  ZSHistoryEntry.h
//  ZenSudoku
//
//  Created by Brent Traut on 12/3/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSTile.h"

typedef enum {
	ZSHistoryEntryTypePencil,
	ZSHistoryEntryTypeGuess
} ZSHistoryEntryType;

@interface ZSHistoryEntry : NSObject <NSCoding>

@property (assign) ZSHistoryEntryType type;
@property (assign) NSInteger row;
@property (assign) NSInteger col;
@property (assign) NSInteger previousValue;
@property (assign) NSInteger pencilNumber;

+ (id)undoStop;
+ (id)undoDescriptionWithType:(ZSHistoryEntryType)newType tile:(ZSTile *)newTile previousValue:(NSInteger)newPreviousValue;
- (id)initWithType:(ZSHistoryEntryType)newType tile:(ZSTile *)newTile previousValue:(NSInteger)newPreviousValue;
- (id)initWithType:(ZSHistoryEntryType)newType row:(NSInteger)row col:(NSInteger)col previousValue:(NSInteger)newPreviousValue;

@end

extern NSString * const kDictionaryRepresentationGameHistoryEntryTypeKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryTileRowKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryTileColKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryPreviousValueKey;
extern NSString * const kDictionaryRepresentationGameHistoryEntryPencilNumberKey;

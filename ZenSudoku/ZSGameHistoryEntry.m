//
//  ZSGameHistoryEntry.m
//  ZenSudoku
//
//  Created by Brent Traut on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameHistoryEntry.h"

NSString * const kDictionaryRepresentationGameHistoryEntryTypeKey = @"kDictionaryRepresentationGameHistoryEntryTypeKey";
NSString * const kDictionaryRepresentationGameHistoryEntryTileRowKey = @"kDictionaryRepresentationGameHistoryEntryTileRowKey";
NSString * const kDictionaryRepresentationGameHistoryEntryTileColKey = @"kDictionaryRepresentationGameHistoryEntryTileColKey";
NSString * const kDictionaryRepresentationGameHistoryEntryPreviousValueKey = @"kDictionaryRepresentationGameHistoryEntryPreviousValueKey";
NSString * const kDictionaryRepresentationGameHistoryEntryPencilNumberKey = @"kDictionaryRepresentationGameHistoryEntryPencilNumberKey";

@implementation ZSGameHistoryEntry

@synthesize type, row, col, previousValue, pencilNumber;

+ (id)undoStop {
	return [[self alloc] initWithType:ZSGameHistoryEntryTypeGuess tile:nil previousValue:0];
}

+ (id)undoDescriptionWithType:(ZSGameHistoryEntryType)newType tile:(ZSGameTile *)newTile previousValue:(int)newPreviousValue {
	return [[self alloc] initWithType:newType tile:newTile previousValue:newPreviousValue];
}

- (id)init {
	return [self initWithType:ZSGameHistoryEntryTypeGuess tile:nil previousValue:0];
}

- (id)initWithType:(ZSGameHistoryEntryType)newType tile:(ZSGameTile *)newTile previousValue:(int)newPreviousValue {
	return [self initWithType:newType row:newTile.row col:newTile.col previousValue:newPreviousValue];
}

- (id)initWithType:(ZSGameHistoryEntryType)newType row:(int)newRow col:(int)newCol previousValue:(int)newPreviousValue {
	self = [super init];
	
	if (self) {
		type = newType;
		row = newRow;
		col = newCol;
		previousValue = newPreviousValue;
		pencilNumber = 0;
	}
	
	return self;
}


- (id)initWithDictionaryRepresentation:(NSDictionary *)dict {
	ZSGameHistoryEntry *newEntry = [self initWithType:[[dict objectForKey:kDictionaryRepresentationGameHistoryEntryTypeKey] intValue]
												  row:[[dict objectForKey:kDictionaryRepresentationGameHistoryEntryTileRowKey] intValue]
												  col:[[dict objectForKey:kDictionaryRepresentationGameHistoryEntryTileColKey] intValue]
										previousValue:[[dict objectForKey:kDictionaryRepresentationGameHistoryEntryPreviousValueKey] intValue]];
	
	newEntry.pencilNumber = [[dict objectForKey:kDictionaryRepresentationGameHistoryEntryPencilNumberKey] intValue];
	
	return newEntry;
}

- (NSDictionary *)getDictionaryRepresentation {
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:type], kDictionaryRepresentationGameHistoryEntryTypeKey,
			[NSNumber numberWithInt:row], kDictionaryRepresentationGameHistoryEntryTileRowKey,
			[NSNumber numberWithInt:col], kDictionaryRepresentationGameHistoryEntryTileColKey,
			[NSNumber numberWithInt:previousValue], kDictionaryRepresentationGameHistoryEntryPreviousValueKey,
			[NSNumber numberWithInt:pencilNumber], kDictionaryRepresentationGameHistoryEntryPencilNumberKey,
			nil];
}

@end

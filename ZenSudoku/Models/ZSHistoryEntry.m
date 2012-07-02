//
//  ZSHistoryEntry.m
//  ZenSudoku
//
//  Created by Brent Traut on 12/3/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSHistoryEntry.h"

NSString * const kDictionaryRepresentationGameHistoryEntryTypeKey = @"kDictionaryRepresentationGameHistoryEntryTypeKey";
NSString * const kDictionaryRepresentationGameHistoryEntryTileRowKey = @"kDictionaryRepresentationGameHistoryEntryTileRowKey";
NSString * const kDictionaryRepresentationGameHistoryEntryTileColKey = @"kDictionaryRepresentationGameHistoryEntryTileColKey";
NSString * const kDictionaryRepresentationGameHistoryEntryPreviousValueKey = @"kDictionaryRepresentationGameHistoryEntryPreviousValueKey";
NSString * const kDictionaryRepresentationGameHistoryEntryPencilNumberKey = @"kDictionaryRepresentationGameHistoryEntryPencilNumberKey";

@implementation ZSHistoryEntry

@synthesize type, row, col, previousValue, pencilNumber;

+ (id)undoStop {
	return [[self alloc] initWithType:ZSHistoryEntryTypeGuess tile:nil previousValue:0];
}

+ (id)undoDescriptionWithType:(ZSHistoryEntryType)newType tile:(ZSTile *)newTile previousValue:(NSInteger)newPreviousValue {
	return [[self alloc] initWithType:newType tile:newTile previousValue:newPreviousValue];
}

- (id)init {
	return [self initWithType:ZSHistoryEntryTypeGuess tile:nil previousValue:0];
}

- (id)initWithType:(ZSHistoryEntryType)newType tile:(ZSTile *)newTile previousValue:(NSInteger)newPreviousValue {
	return [self initWithType:newType row:newTile.row col:newTile.col previousValue:newPreviousValue];
}

- (id)initWithType:(ZSHistoryEntryType)newType row:(NSInteger)newRow col:(NSInteger)newCol previousValue:(NSInteger)newPreviousValue {
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

#pragma mark - NSCoder Methods

- (id)initWithCoder:(NSCoder *)decoder {
	ZSHistoryEntry *newEntry = [self initWithType:[decoder decodeIntForKey:kDictionaryRepresentationGameHistoryEntryTypeKey]
											  row:[decoder decodeIntForKey:kDictionaryRepresentationGameHistoryEntryTileRowKey]
											  col:[decoder decodeIntForKey:kDictionaryRepresentationGameHistoryEntryTileColKey]
									previousValue:[decoder decodeIntForKey:kDictionaryRepresentationGameHistoryEntryPreviousValueKey]];
	
	newEntry.pencilNumber = [decoder decodeIntForKey:kDictionaryRepresentationGameHistoryEntryPencilNumberKey];
	
	return newEntry;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeInt:type forKey:kDictionaryRepresentationGameHistoryEntryTypeKey];
	[encoder encodeInt:row forKey:kDictionaryRepresentationGameHistoryEntryTileRowKey];
	[encoder encodeInt:col forKey:kDictionaryRepresentationGameHistoryEntryTileColKey];
	[encoder encodeInt:previousValue forKey:kDictionaryRepresentationGameHistoryEntryPreviousValueKey];
	[encoder encodeInt:pencilNumber forKey:kDictionaryRepresentationGameHistoryEntryPencilNumberKey];
}

@end

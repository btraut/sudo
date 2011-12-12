//
//  ZSGameHistoryEntry.m
//  ZenSudoku
//
//  Created by Brent Traut on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameHistoryEntry.h"

@implementation ZSGameHistoryEntry

@synthesize type, tile, previousValue, pencilNumber;

+ (id)undoStop {
	return [[self alloc] initWithType:ZSGameHistoryEntryTypeGuess tile:nil previousValue:0];
}

+ (id)undoDescriptionWithType:(ZSGameHistoryEntryType)newType tile:(ZSGameTile *)newTile previousValue:(NSInteger)newPreviousValue {
	return [[self alloc] initWithType:newType tile:newTile previousValue:newPreviousValue];
}

- (id)init {
	return [self initWithType:ZSGameHistoryEntryTypeGuess tile:nil previousValue:0];
}

- (id)initWithType:(ZSGameHistoryEntryType)newType tile:(ZSGameTile *)newTile previousValue:(NSInteger)newPreviousValue {
	self = [super init];
	
	if (self) {
		tile = newTile;
		type = newType;
		previousValue = newPreviousValue;
		pencilNumber = 0;
	}
	
	return self;
}

@end

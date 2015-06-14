//
//  ZSTile.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import "ZSTile.h"
#import "ZSBoard.h"
#import "ZSGame.h"
#import "ZSHistoryEntry.h"

NSString * const kDictionaryRepresentationGameTileSizeKey = @"kDictionaryRepresentationGameTileSizeKey";
NSString * const kDictionaryRepresentationGameTileGuessKey = @"kDictionaryRepresentationGameTileGuessKey";
NSString * const kDictionaryRepresentationGameTileAnswerKey = @"kDictionaryRepresentationGameTileAnswerKey";
NSString * const kDictionaryRepresentationGameTileLockedKey = @"kDictionaryRepresentationGameTileLockedKey";
NSString * const kDictionaryRepresentationGameTileGroupIdKey = @"kDictionaryRepresentationGameTileGroupIdKey";
NSString * const kDictionaryRepresentationGameTilePencilsKey = @"kDictionaryRepresentationGameTilePencilsKey";

@interface ZSTile() {
	BOOL *_pencils;
	
	NSInteger _size;
}

@end

@implementation ZSTile

@synthesize board;
@synthesize row, col, groupId;
@synthesize guess, answer, locked;

#pragma mark - Object Lifecycle

- (id)init {
	return [self initWithSize:9];
}

- (id)initWithBoard:(ZSBoard *)newBoard {
	self = [self initWithSize:newBoard.size];
	
	if (self) {
		board = newBoard;
	}
	
	return self;
}

- (id)initWithSize:(NSInteger)size {
	self = [super init];
	
	if (self) {
		_size = size;
		
		_pencils = malloc(_size * sizeof(BOOL));
		
		for (NSInteger i = 0; i < _size; ++i) {
			_pencils[i] = NO;
		}
	}
	
	return self;
}

- (void)copyTile:(ZSTile *)tile {
	guess = tile.guess;
	answer = tile.answer;
	locked = tile.locked;
	
	groupId = tile.groupId;
	
	for (NSInteger i = 1; i <= _size; ++i) {
		[self setPencil:[tile getPencilForGuess:i] forGuess:i];
	}
}

- (void)dealloc {
	free(_pencils);
}

#pragma mark - NSCoder Methods

- (id)initWithCoder:(NSCoder *)decoder {
	NSInteger size = [decoder decodeIntForKey:kDictionaryRepresentationGameTileSizeKey];
	
	self = [self initWithSize:size];
	
	if (self) {
		guess = [decoder decodeIntForKey:kDictionaryRepresentationGameTileGuessKey];
		answer = [decoder decodeIntForKey:kDictionaryRepresentationGameTileAnswerKey];
		locked = [decoder decodeBoolForKey:kDictionaryRepresentationGameTileLockedKey];
		
		groupId = [decoder decodeIntForKey:kDictionaryRepresentationGameTileGroupIdKey];
		
		NSArray *pencilArray = [decoder decodeObjectForKey:kDictionaryRepresentationGameTilePencilsKey];
		
		for (NSInteger i = 0; i < _size; ++i) {
			NSNumber *pencilNumber = [pencilArray objectAtIndex:i];
			[self setPencil:[pencilNumber boolValue] forGuess:(i + 1)];
		}
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeInteger:_size forKey:kDictionaryRepresentationGameTileSizeKey];
	
	[encoder encodeInteger:guess forKey:kDictionaryRepresentationGameTileGuessKey];
	[encoder encodeInteger:answer forKey:kDictionaryRepresentationGameTileAnswerKey];
	[encoder encodeBool:locked forKey:kDictionaryRepresentationGameTileLockedKey];
	
	[encoder encodeInteger:groupId forKey:kDictionaryRepresentationGameTileGroupIdKey];
	
	NSMutableArray *pencilsArray = [NSMutableArray array];
	
	for (NSInteger i = 0; i < _size; ++i) {
		[pencilsArray addObject:[NSNumber numberWithBool:_pencils[i]]];
	}
	
	[encoder encodeObject:pencilsArray forKey:kDictionaryRepresentationGameTilePencilsKey];
}

#pragma mark - Setters / Getters

- (BOOL)getPencilForGuess:(NSInteger)newGuess {
	return _pencils[(newGuess - 1)];
}

- (void)setPencil:(BOOL)isset forGuess:(NSInteger)newGuess {
	_pencils[(newGuess - 1)] = isset;
}

- (void)setAllPencils:(BOOL)isset {
	for (NSInteger i = 1; i <= _size; ++i) {
		[self setPencil:isset forGuess:i];
	}
}

- (void)togglePencilForGuess:(NSInteger)newGuess {
	[self setPencil:(![self getPencilForGuess:newGuess]) forGuess:newGuess];
}

@end

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
#import "ZSBoard.h"
#import "ZSHistoryEntry.h"

NSString * const kDictionaryRepresentationGameTileGuessKey = @"kDictionaryRepresentationGameTileGuessKey";
NSString * const kDictionaryRepresentationGameTileAnswerKey = @"kDictionaryRepresentationGameTileAnswerKey";
NSString * const kDictionaryRepresentationGameTileLockedKey = @"kDictionaryRepresentationGameTileLockedKey";
NSString * const kDictionaryRepresentationGameTileGroupIdKey = @"kDictionaryRepresentationGameTileGroupIdKey";
NSString * const kDictionaryRepresentationGameTilePencilsKey = @"kDictionaryRepresentationGameTilePencilsKey";

@interface ZSTile() {
	BOOL *_pencils;
}

@end

@implementation ZSTile

@synthesize board;
@synthesize row, col, groupId;
@synthesize guess, answer, locked;

#pragma mark - Object Lifecycle

// Don't call this directly!
- (id)init {
	return nil;
}

- (id)initWithBoard:(ZSBoard *)newGameBoard {
	self = [super init];
	
	if (self) {
		board = newGameBoard;
		
		_pencils = malloc(board.size * sizeof(BOOL));
		
		for (NSInteger i = 0; i < board.size; ++i) {
			_pencils[i] = NO;
		}
	}
	
	return self;
}

- (void)dealloc {
	free(_pencils);
}

#pragma mark - Dictionary Representations

- (void)setValuesForDictionaryRepresentation:(NSDictionary *)dict {
	guess = [[dict objectForKey:kDictionaryRepresentationGameTileGuessKey] intValue];
	answer = [[dict objectForKey:kDictionaryRepresentationGameTileAnswerKey] intValue];
	locked = [[dict objectForKey:kDictionaryRepresentationGameTileLockedKey] boolValue];
	
	groupId = [[dict objectForKey:kDictionaryRepresentationGameTileGroupIdKey] intValue];
	
	for (NSInteger i = 0; i < board.size; ++i) {
		NSNumber *pencilNumber = [[dict objectForKey:kDictionaryRepresentationGameTilePencilsKey] objectAtIndex:i];
		[self setPencil:[pencilNumber boolValue] forGuess:(i + 1)];
	}
}

- (NSDictionary *)getDictionaryRepresentation {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setValue:[NSNumber numberWithInt:guess] forKey:kDictionaryRepresentationGameTileGuessKey];
	[dict setValue:[NSNumber numberWithInt:answer] forKey:kDictionaryRepresentationGameTileAnswerKey];
	[dict setValue:[NSNumber numberWithBool:locked] forKey:kDictionaryRepresentationGameTileLockedKey];
	
	[dict setValue:[NSNumber numberWithInt:groupId] forKey:kDictionaryRepresentationGameTileGroupIdKey];
	
	NSMutableArray *pencilsArray = [NSMutableArray array];
	
	for (NSInteger i = 0; i < board.size; ++i) {
		[pencilsArray addObject:[NSNumber numberWithBool:_pencils[i]]];
	}
	
	[dict setValue:pencilsArray forKey:kDictionaryRepresentationGameTilePencilsKey];
	
	return dict;
}

#pragma mark - Setters / Getters

- (BOOL)getPencilForGuess:(NSInteger)newGuess {
	return _pencils[(newGuess - 1)];
}

- (void)setPencil:(BOOL)isset forGuess:(NSInteger)newGuess {
	_pencils[(newGuess - 1)] = isset;
}

- (void)setAllPencils:(BOOL)isset {
	for (NSInteger i = 1; i <= board.size; ++i) {
		[self setPencil:isset forGuess:i];
	}
}

- (void)togglePencilForGuess:(NSInteger)newGuess {
	[self setPencil:(![self getPencilForGuess:newGuess]) forGuess:newGuess];
}

@end
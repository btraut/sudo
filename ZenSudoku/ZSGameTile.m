//
//  ZSGameTile.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSGameTile.h"
#import "ZSGame.h"
#import "ZSGameHistoryEntry.h"

NSString * const kDictionaryRepresentationGameTileGuessKey = @"kDictionaryRepresentationGameTileGuessKey";
NSString * const kDictionaryRepresentationGameTileAnswerKey = @"kDictionaryRepresentationGameTileAnswerKey";
NSString * const kDictionaryRepresentationGameTileLockedKey = @"kDictionaryRepresentationGameTileLockedKey";
NSString * const kDictionaryRepresentationGameTileGroupIdKey = @"kDictionaryRepresentationGameTileGroupIdKey";
NSString * const kDictionaryRepresentationGameTilePencilsKey = @"kDictionaryRepresentationGameTilePencilsKey";

@implementation ZSGameTile

@synthesize game;
@synthesize row, col, groupId;
@synthesize guess, answer, locked;

#pragma mark - Object Lifecycle

// Don't call this directly!
- (id)init {
	return nil;
}

- (id)initWithGame:(ZSGame *)newGame {
	self = [super init];
	
	if (self) {
		game = newGame;
		
		_pencils = [NSMutableArray array];
		
		for (NSInteger i = 0; i < game.size; ++i) {
			[_pencils addObject:[NSNumber numberWithBool:NO]];
		}
	}
	
	return self;
}

- (id)initWithGame:(ZSGame *)newGame dictionaryRepresentation:(NSDictionary *)dict {
	self = [self initWithGame:newGame];
	
	if (self) {
		guess = [[dict objectForKey:kDictionaryRepresentationGameTileGuessKey] intValue];
		answer = [[dict objectForKey:kDictionaryRepresentationGameTileAnswerKey] intValue];
		locked = [[dict objectForKey:kDictionaryRepresentationGameTileLockedKey] boolValue];
		
		groupId = [[dict objectForKey:kDictionaryRepresentationGameTileGroupIdKey] boolValue];
		
		for (NSInteger i = 0; i < game.size; ++i) {
			NSNumber *pencilNumber = [[dict objectForKey:kDictionaryRepresentationGameTilePencilsKey] objectAtIndex:i];
			[self setPencil:[pencilNumber boolValue] forGuess:(i + 1)];
		}
	}
	
	return self;
}

#pragma mark - Setters / Getters

- (NSDictionary *)getDictionaryRepresentation {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	[dict setValue:[NSNumber numberWithInt:guess] forKey:kDictionaryRepresentationGameTileGuessKey];
	[dict setValue:[NSNumber numberWithInt:answer] forKey:kDictionaryRepresentationGameTileAnswerKey];
	[dict setValue:[NSNumber numberWithBool:locked] forKey:kDictionaryRepresentationGameTileLockedKey];
	
	[dict setValue:[NSNumber numberWithInt:groupId] forKey:kDictionaryRepresentationGameTileGroupIdKey];
	
	NSMutableArray *pencilsArray = [NSMutableArray array];
	
	for (NSNumber *pencilNumber in _pencils) {
		[pencilsArray addObject:[NSNumber numberWithInt:[pencilNumber intValue]]];
	}
	
	[dict setValue:pencilsArray forKey:kDictionaryRepresentationGameTilePencilsKey];
	
	return dict;
}

- (BOOL)getPencilForGuess:(NSInteger)newGuess {
	return [[_pencils objectAtIndex:(newGuess - 1)] boolValue];
}

- (void)setPencil:(BOOL)isset forGuess:(NSInteger)newGuess {
	[_pencils replaceObjectAtIndex:(newGuess - 1) withObject:[NSNumber numberWithBool:isset]];
}

- (void)setAllPencils:(BOOL)isset {
	for (NSInteger i = 1; i <= game.size; ++i) {
		[self setPencil:isset forGuess:i];
	}
}

- (void)togglePencilForGuess:(NSInteger)newGuess {
	[self setPencil:(![self getPencilForGuess:newGuess]) forGuess:newGuess];
}

@end

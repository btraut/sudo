//
//  ZSGameTile.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSGame;

@interface ZSGameTile : NSObject {
	ZSGame *game;
	
	NSInteger row;
	NSInteger col;
	NSInteger groupId;
	
	NSInteger guess;
	NSInteger answer;
	BOOL locked;
	
	@private
	
	NSMutableArray *_pencils;
}

@property (strong) ZSGame *game;

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger col;
@property (nonatomic, assign) NSInteger groupId;

@property (nonatomic, assign) NSInteger guess;
@property (nonatomic, assign) NSInteger answer;
@property (nonatomic, assign) BOOL locked;

- (id)initWithGame:(ZSGame *)newGame;
- (id)initWithGame:(ZSGame *)newGame dictionaryRepresentation:(NSDictionary *)dict;

- (NSDictionary *)getDictionaryRepresentation;

- (BOOL)getPencilForGuess:(NSInteger)newGuess;
- (void)setPencil:(BOOL)isset forGuess:(NSInteger)guess;
- (void)setAllPencils:(BOOL)isset;
- (void)togglePencilForGuess:(NSInteger)guess;

@end

extern NSString * const kDictionaryRepresentationGameTileGuessKey;
extern NSString * const kDictionaryRepresentationGameTileAnswerKey;
extern NSString * const kDictionaryRepresentationGameTileLockedKey;
extern NSString * const kDictionaryRepresentationGameTileGroupIdKey;
extern NSString * const kDictionaryRepresentationGameTilePencilsKey;

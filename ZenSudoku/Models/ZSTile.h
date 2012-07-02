//
//  ZSTile.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSBoard;

@interface ZSTile : NSObject <NSCoding>

@property (weak) ZSBoard *board;

@property (assign) NSInteger row;
@property (assign) NSInteger col;
@property (assign) NSInteger groupId;

@property (assign) NSInteger guess;
@property (assign) NSInteger answer;
@property (assign) BOOL locked;

- (id)initWithBoard:(ZSBoard *)board;
- (id)initWithSize:(NSInteger)size;
- (void)copyTile:(ZSTile *)tile;

- (BOOL)getPencilForGuess:(NSInteger)newGuess;
- (void)setPencil:(BOOL)isset forGuess:(NSInteger)guess;
- (void)setAllPencils:(BOOL)isset;
- (void)togglePencilForGuess:(NSInteger)guess;

@end

extern NSString * const kDictionaryRepresentationGameTileSizeKey;
extern NSString * const kDictionaryRepresentationGameTileGuessKey;
extern NSString * const kDictionaryRepresentationGameTileAnswerKey;
extern NSString * const kDictionaryRepresentationGameTileLockedKey;
extern NSString * const kDictionaryRepresentationGameTileGroupIdKey;
extern NSString * const kDictionaryRepresentationGameTilePencilsKey;

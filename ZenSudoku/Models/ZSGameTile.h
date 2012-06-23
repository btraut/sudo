//
//  ZSGameTile.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 Ten Four Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSGameBoard;

@interface ZSGameTile : NSObject

@property (weak) ZSGameBoard *gameBoard;

@property (assign) NSInteger row;
@property (assign) NSInteger col;
@property (assign) NSInteger groupId;

@property (assign) NSInteger guess;
@property (assign) NSInteger answer;
@property (assign) BOOL locked;

- (id)initWithBoard:(ZSGameBoard *)gameBoard;

- (void)setValuesForDictionaryRepresentation:(NSDictionary *)dict;
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

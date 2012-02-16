//
//  ZSGameTile.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZSGameBoard;

@interface ZSGameTile : NSObject {
	ZSGameBoard *gameBoard;
	
	NSInteger row;
	NSInteger col;
	NSInteger groupId;
	
	NSInteger guess;
	NSInteger answer;
	BOOL locked;
	
	@private
	
	NSMutableArray *_pencils;
}

@property (strong) ZSGameBoard *gameBoard;

@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger col;
@property (nonatomic, assign) NSInteger groupId;

@property (nonatomic, assign) NSInteger guess;
@property (nonatomic, assign) NSInteger answer;
@property (nonatomic, assign) BOOL locked;

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

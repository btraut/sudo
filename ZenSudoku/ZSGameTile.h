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
	
	int row;
	int col;
	int groupId;
	
	int guess;
	int answer;
	BOOL locked;
	
	@private
	
	NSMutableArray *_pencils;
}

@property (strong) ZSGameBoard *gameBoard;

@property (nonatomic, assign) int row;
@property (nonatomic, assign) int col;
@property (nonatomic, assign) int groupId;

@property (nonatomic, assign) int guess;
@property (nonatomic, assign) int answer;
@property (nonatomic, assign) BOOL locked;

- (id)initWithBoard:(ZSGameBoard *)gameBoard;

- (void)setValuesForDictionaryRepresentation:(NSDictionary *)dict;
- (NSDictionary *)getDictionaryRepresentation;

- (BOOL)getPencilForGuess:(int)newGuess;
- (void)setPencil:(BOOL)isset forGuess:(int)guess;
- (void)setAllPencils:(BOOL)isset;
- (void)togglePencilForGuess:(int)guess;

@end

extern NSString * const kDictionaryRepresentationGameTileGuessKey;
extern NSString * const kDictionaryRepresentationGameTileAnswerKey;
extern NSString * const kDictionaryRepresentationGameTileLockedKey;
extern NSString * const kDictionaryRepresentationGameTileGroupIdKey;
extern NSString * const kDictionaryRepresentationGameTilePencilsKey;

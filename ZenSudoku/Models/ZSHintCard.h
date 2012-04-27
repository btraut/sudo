//
//  ZSHintCard.h
//  ZenSudoku
//
//  Created by Brent Traut on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZSHintCard : NSObject {
	NSString *text;
	
	NSMutableArray *highlightPencils;
	NSMutableArray *highlightAnswers;
	NSMutableArray *highlightTilesColorA;
	NSMutableArray *highlightTilesColorB;
	NSMutableArray *removePencils;
	NSMutableArray *removeAnswers;
	NSMutableArray *setAnswers;
	BOOL setAutoPencil;
	
	BOOL allowsPrevious;
}

@property (nonatomic, strong) NSString *text;

@property (nonatomic, strong) NSMutableArray *highlightPencils;
@property (nonatomic, strong) NSMutableArray *highlightAnswers;
@property (nonatomic, strong) NSMutableArray *highlightTilesColorA;
@property (nonatomic, strong) NSMutableArray *highlightTilesColorB;
@property (nonatomic, strong) NSMutableArray *removePencils;
@property (nonatomic, strong) NSMutableArray *removeAnswers;
@property (nonatomic, strong) NSMutableArray *setAnswers;
@property (nonatomic, assign) BOOL setAutoPencil;

@property (nonatomic, assign) BOOL allowsPrevious;

@end

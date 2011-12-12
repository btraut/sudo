//
//  ZSAppDelegate.h
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSMainMenuViewController.h"

@interface ZSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) IBOutlet UIWindow *window;

- (void)setUserDefaults;

@end

// === Define Preference Keys === //

extern NSString * const kTileAnswerOrderKey;

extern NSString * const kClearAnswerOptionSelectionAfterPickingTileForAnswerKey;
extern NSString * const kClearTileSelectionAfterPickingAnswerOptionForAnswerKey;
extern NSString * const kClearAnswerOptionSelectionAfterPickingTileForPencilKey;
extern NSString * const kClearTileSelectionAfterPickingAnswerOptionForPencilKey;

extern NSString * const kClearPencilsAfterGuessingKey;

extern NSString * const kShowErrorsOptionKey;
extern NSString * const kRemoveTileAfterErrorKey;

extern NSString * const kSavedGameInProgressKey;
extern NSString * const kSavedGameKey;

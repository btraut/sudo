//
//  ZSAnswerOptionsTallViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 9/17/12.
//
//

#import "ZSAnswerOptionsTallViewController.h"
#import "ZSAnswerOptionViewController.h"
#import "ZSAnswerOptionTallViewController.h"
#import "ZSGameViewController.h"
#import "ZSBoardViewController.h"
#import "ZSTile.h"
#import "ZSGame.h"
#import "ZSBoard.h"
#import "ZSPanBetweenSubviewsGestureRecognizer.h"

@interface ZSAnswerOptionsTallViewController ()

@end

@implementation ZSAnswerOptionsTallViewController

- (void)loadView {
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 246, 90)];
	self.view.userInteractionEnabled = YES;
}

- (void)_buildButtons {
	// Create the gesture recognizer.
	ZSPanBetweenSubviewsGestureRecognizer *panBetweenSubviewsGestureRecognizer = [[ZSPanBetweenSubviewsGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[self.view addGestureRecognizer:panBetweenSubviewsGestureRecognizer];
	
	// Build numbers.
	NSMutableArray *buttons = [NSMutableArray array];
	ZSAnswerOptionViewController *gameAnswerOptionViewController;
	
	NSInteger xOffset = 0;
	NSInteger yOffset = 0;
	
	for (NSInteger i = 0; i < self.gameViewController.game.board.size; i++) {
		if (i == 5) {
			yOffset = 54;
			xOffset = 0;
		}
		
		gameAnswerOptionViewController = [[ZSAnswerOptionTallViewController alloc] initWithGameAnswerOption:(ZSAnswerOption)i];
		gameAnswerOptionViewController.view.frame = CGRectMake(xOffset, yOffset, gameAnswerOptionViewController.view.frame.size.width, gameAnswerOptionViewController.view.frame.size.height);
		gameAnswerOptionViewController.delegate = self;
		gameAnswerOptionViewController.gameAnswerOptionsViewController = self;
		
		[self.view addSubview:gameAnswerOptionViewController.view];
		[buttons addObject:gameAnswerOptionViewController];
		
		[panBetweenSubviewsGestureRecognizer addSubview:gameAnswerOptionViewController.view];
		
		xOffset += 52;
	}
	
	gameAnswerOptionViewControllers = [NSArray arrayWithArray:buttons];
}

@end

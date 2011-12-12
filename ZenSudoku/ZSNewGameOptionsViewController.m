//
//  ZSNewGameOptionsViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSNewGameOptionsViewController.h"
#import "ZSGameViewController.h"
#import "ZSGameController.h"
#import "ZSGame.h"

@implementation ZSNewGameOptionsViewController

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	
	if (self) {
		// Custom initialization
	}
	
	return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = @"New Game";
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	switch (indexPath.row) {
		default:
		case 0:
			cell.textLabel.text = @"Easy";
			break;
			
		case 1:
			cell.textLabel.text = @"Medium";
			break;
			
		case 2:
			cell.textLabel.text = @"Hard";
			break;
			
		case 3:
			cell.textLabel.text = @"Expert";
			break;
	}
	
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		default:
		case 0:
			[[ZSGameController sharedInstance] generateGameWithDifficulty:ZSGameDifficultyEasy];
			break;
			
		case 1:
			[[ZSGameController sharedInstance] generateGameWithDifficulty:ZSGameDifficultyMedium];
			break;
			
		case 2:
			[[ZSGameController sharedInstance] generateGameWithDifficulty:ZSGameDifficultyHard];
			break;
			
		case 3:
			[[ZSGameController sharedInstance] generateGameWithDifficulty:ZSGameDifficultyExpert];
			break;
	}
	
	ZSGameViewController *gameViewController = [[ZSGameViewController alloc] initWithGame:[ZSGameController sharedInstance].currentGame];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:gameViewController];
	
	[self.navigationController presentModalViewController:navController animated:YES];
}

@end

//
//  ZSMainMenuViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ZSMainMenuViewController.h"
#import "ZSNewGameOptionsViewController.h"
#import "ZSGameViewController.h"
#import "ZSGameController.h"
#import "ZSGame.h"

@implementation ZSMainMenuViewController

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
	
	self.title = @"Game Menu";
    [self.navigationController setNavigationBarHidden:NO animated:NO];
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
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 2;
		case 1:
			return 4;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"New Game";
				break;
				
			case 1:
				cell.textLabel.text = @"Resume Game";
				break;
		}
	} else {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Statistics";
				break;
				
			case 1:
				cell.textLabel.text = @"Instructions";
				break;
				
			case 2:
				cell.textLabel.text = @"Game Center";
				break;
				
			case 3:
				cell.textLabel.text = @"Settings";
				break;
		}
	}
	
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIViewController *detailViewController = nil;
	
	if (indexPath.section == 0) {
		ZSGame *game;
		
		switch (indexPath.row) {
			case 0:
				detailViewController = [[ZSNewGameOptionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
				break;
				
			case 1:
				game = [ZSGameController sharedInstance].currentGame;
				
				if (game) {
					ZSGameViewController *gameViewController = [[ZSGameViewController alloc] initWithGame:game];
					UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:gameViewController];
					
					[self.navigationController presentModalViewController:navController animated:YES];
				}
				
				break;
		}
	} else {
		switch (indexPath.row) {
			case 0:
				break;
				
			case 1:
				break;
				
			case 2:
				break;
				
			case 3:
				break;
		}
	}
	
	if (detailViewController) {
		[self.navigationController pushViewController:detailViewController animated:YES];
	}
}

@end

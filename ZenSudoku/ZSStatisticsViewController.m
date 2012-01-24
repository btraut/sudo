//
//  ZSStatisticsViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 1/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ZSStatisticsViewController.h"
#import "ZSStatisticsController.h"
#import "ZSAppDelegate.h"

#import "TestFlight.h"

@implementation ZSStatisticsViewController

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	
	if (self) {
		// Custom initialization
	}
	
	return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
	// TestFlight Checkpoint
	[TestFlight passCheckpoint:kTestFlightCheckPointOpenedStatistics];
	
	[super viewDidLoad];
	
	self.title = @"Statistics";
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

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0: return 5;
		case 1: return 3;
		case 2: return 1;
		case 3: return 5;
	}
	
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0: return @"Puzzles Solved";
		case 1: return @"Answers Entered";
		case 2: return @"Time Played";
		case 3: return @"";
	}
	
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}
	
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Easy";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [[ZSStatisticsController sharedInstance] gamesSolvedPerEasy]];
				break;
				
			case 1:
				cell.textLabel.text = @"Medium";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [[ZSStatisticsController sharedInstance] gamesSolvedPerMedium]];
				break;
				
			case 2:
				cell.textLabel.text = @"Hard";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [[ZSStatisticsController sharedInstance] gamesSolvedPerHard]];
				break;
				
			case 3:
				cell.textLabel.text = @"Expert";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [[ZSStatisticsController sharedInstance] gamesSolvedPerExpert]];
				break;
				
			case 4:
				cell.textLabel.text = @"Total";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", [[ZSStatisticsController sharedInstance] totalSolvedGames]];
				break;
		}
	} else if (indexPath.section == 1) {
		NSInteger answers = [[ZSStatisticsController sharedInstance] totalEnteredAnswers];
		NSInteger strikes = [[ZSStatisticsController sharedInstance] totalStrikes];
		float accuracy = answers ? ((float)(answers - strikes) / (float)answers) * 100 : 0;
		
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = @"Answers";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", answers];
				break;
				
			case 1:
				cell.textLabel.text = @"Strikes";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%i", strikes];
				break;
				
			case 2:
				cell.textLabel.text = @"Accuracy";
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%1.0f%%", accuracy];
				break;
		}
	} else if (indexPath.section == 2) {
		NSInteger remainingSeconds = [[ZSStatisticsController sharedInstance] totalTimePlayed];
		
		NSInteger daysPlayed = 0;
		NSInteger hoursPlayed = 0;
		NSInteger minutesPlayed = 0;
		NSInteger secondsPlayed = 0;
		
		NSMutableString *timePlayedString = [NSMutableString string];
		
		daysPlayed = remainingSeconds / 86400;
		remainingSeconds -= daysPlayed * 86400;
		
		hoursPlayed = remainingSeconds / 3600;
		remainingSeconds -= hoursPlayed * 3600;
		
		minutesPlayed = remainingSeconds / 60;
		remainingSeconds -= minutesPlayed * 60;
		
		secondsPlayed = remainingSeconds;
		
		if (daysPlayed) {
			[timePlayedString appendFormat:@"%i days, %i hours", daysPlayed, hoursPlayed];
		} else if (hoursPlayed) {
			[timePlayedString appendFormat:@"%i hours, %i minutes", hoursPlayed, minutesPlayed];
		} else if (minutesPlayed) {
			[timePlayedString appendFormat:@"%i minutes, %i seconds", minutesPlayed, secondsPlayed];
		} else {
			[timePlayedString appendFormat:@"%i seconds", secondsPlayed];
		}
		
		cell.textLabel.text = @"Total";
		cell.detailTextLabel.text = timePlayedString;
	} else {
	}
	
	return cell;
}

@end
//
//  ZSAdPageViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 8/5/12.
//
//

#import "ZSAdPageViewController.h"

#import "UIColor+ColorWithHex.h"

#define TOTAL_FORCED_AD_DISPLAY_TIME 10

@interface ZSAdPageViewController ()

@property (strong) IMAdView *adView;

@property (strong) UIImageView *adContainer;

@property (strong) UILabel *innerAdText;
@property (strong) UILabel *turnThePageNotice;
@property (strong) NSTimer *countdownTimer;
@property (assign) NSInteger countdownTimerCount;

@end

@implementation ZSAdPageViewController

@synthesize adView = _adView;
@synthesize adContainer = _adContainer;
@synthesize innerAdText = _innerAdText;
@synthesize turnThePageNotice = _turnThePageNotice;
@synthesize countdownTimer = _countdownTimer;
@synthesize countdownTimerCount = _countdownTimerCount;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Create the title.
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(67, 16, 180, 30)];
	title.font = [UIFont fontWithName:@"ReklameScript-Medium" size:30.0f];
	title.textAlignment = UITextAlignmentCenter;
	title.text = @"Advertisement";
	title.shadowColor = [UIColor whiteColor];
	title.shadowOffset = CGSizeMake(0, 0.5f);
	title.backgroundColor = [UIColor clearColor];
	[self.innerView addSubview:title];
	
	// Create the ad border.
	self.adContainer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AdBorder.png"]];
	self.adContainer.frame = CGRectMake(5.5f, 56, self.adContainer.frame.size.width, self.adContainer.frame.size.height);
	[self.innerView addSubview:self.adContainer];
	
	// Create the ad border.
	self.innerAdText = [[UILabel alloc] initWithFrame:CGRectMake(7, 108, 300, 36)];
	self.innerAdText.font = [UIFont fontWithName:@"ReklameScript-Medium" size:15.0f];
	self.innerAdText.textAlignment = UITextAlignmentCenter;
	self.innerAdText.shadowColor = [UIColor whiteColor];
	self.innerAdText.shadowOffset = CGSizeMake(0, 0.5f);
	self.innerAdText.backgroundColor = [UIColor clearColor];
	self.innerAdText.numberOfLines = 2;
	self.innerAdText.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
	self.innerAdText.text = @"This space intentionally left blank.";
	[self.adContainer addSubview:self.innerAdText];
	
	// Create the label stating how much time is left before the page fold starts.
	self.turnThePageNotice = [[UILabel alloc] initWithFrame:CGRectMake(7, 318, 300, 18)];
	self.turnThePageNotice.font = [UIFont fontWithName:@"ReklameScript-Regular" size:15.0f];
	self.turnThePageNotice.textAlignment = UITextAlignmentCenter;
	self.turnThePageNotice.shadowColor = [UIColor whiteColor];
	self.turnThePageNotice.shadowOffset = CGSizeMake(0, -0.5f);
	self.turnThePageNotice.backgroundColor = [UIColor clearColor];
	[self.innerView addSubview:self.turnThePageNotice];
	
	// Create the HR.
	UIImageView *hr = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HR.png"]];
	hr.frame = CGRectMake(9, 346, hr.frame.size.width, hr.frame.size.height);
	[self.innerView addSubview:hr];
	
	// Start with the corner un-folded.
	[self.foldedCornerViewController resetToStartPosition];
}

- (void)viewWasPromotedToFront {
	[super viewWasPromotedToFront];
	
	// Create the ad.
	self.adView = [[IMAdView alloc] initWithFrame:CGRectMake(1.5f, 2, 300, 250) imAppId:@"4028cba631d63df10131e1d4650600cd" imAdUnit:IM_UNIT_300x250 rootViewController:self];
	self.adView.delegate = self;
	self.adView.animationType = kIMAnimationOff;
	[self.adContainer addSubview:self.adView];
	
	IMAdRequest *request = [IMAdRequest request];
	request.testMode = YES;
	//[self.adView loadIMAdRequest:request];
	
	// Set the timeout for folding down the page.
	self.countdownTimerCount = TOTAL_FORCED_AD_DISPLAY_TIME;
	self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_countdownTimerAdvanced:) userInfo:nil repeats:YES];
	
	[self _updateTurnThePageNoticeText];
}

- (void)viewWasRemovedFromBook {
	[super viewWasRemovedFromBook];
	
	[self.adView removeFromSuperview];
	self.adView.delegate = nil;
	self.adView = nil;
	
	if (self.countdownTimer) {
		[self.countdownTimer invalidate];
		self.countdownTimer = nil;
	}
	
	self.turnThePageNotice.text = @"";
	
	[self.foldedCornerViewController resetToStartPosition];
	[self setScreenshotVisible:NO];
}

- (void)dealloc {
	[self.adView setDelegate:nil];
	self.adView = nil;
}

- (void)_countdownTimerAdvanced:(NSTimer *)timer {
	if (--self.countdownTimerCount == 0) {
		[self.foldedCornerViewController animateStartFold];
		
		[self.countdownTimer invalidate];
		self.countdownTimer = nil;
		
		self.needsScreenshotUpdate = YES;
	}
	
	[self _updateTurnThePageNoticeText];
}

- (void)_updateTurnThePageNoticeText {
	if (self.countdownTimerCount > 0) {
		if (self.countdownTimerCount == 1) {
			self.turnThePageNotice.text = [NSString stringWithFormat:@"You may turn the page in %i second.", self.countdownTimerCount];
		} else {
			self.turnThePageNotice.text = [NSString stringWithFormat:@"You may turn the page in %i seconds.", self.countdownTimerCount];
		}
	} else {
		self.turnThePageNotice.text = @"Turn the page to play Sudo!";
	}
}

#pragma mark - IMAdDelegate Implementation

- (void)adViewDidFinishRequest:(IMAdView *)adView {
	
}

- (void)adView:(IMAdView *)view didFailRequestWithError:(IMAdError *)error {
	
}

@end

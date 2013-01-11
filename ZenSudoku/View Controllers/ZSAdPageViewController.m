//
//  ZSAdPageViewController.m
//  ZenSudoku
//
//  Created by Brent Traut on 8/5/12.
//
//

#import "ZSAdPageViewController.h"

#import "ZSAppDelegate.h"
#import "UIColor+ColorWithHex.h"

#define TOTAL_FORCED_AD_DISPLAY_TIME 8

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
	title.textAlignment = NSTextAlignmentCenter;
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
	self.innerAdText.textAlignment = NSTextAlignmentCenter;
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
	self.turnThePageNotice.textAlignment = NSTextAlignmentCenter;
	self.turnThePageNotice.shadowColor = [UIColor whiteColor];
	self.turnThePageNotice.shadowOffset = CGSizeMake(0, 0.5f);
	self.turnThePageNotice.backgroundColor = [UIColor clearColor];
	[self.innerView addSubview:self.turnThePageNotice];
	
	// Create the HR.
	UIImageView *hr = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HR.png"]];
	hr.frame = CGRectMake(9, 346, hr.frame.size.width, hr.frame.size.height);
	[self.innerView addSubview:hr];
	
	// Create full version ad container.
	UIView *adContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 352, 294, 100)];
	adContainer.clipsToBounds = YES;
	[self.innerView addSubview:adContainer];
	
	UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(_adContainerWasTapped)];
	singleTapRecognizer.numberOfTapsRequired = 1;
	[adContainer addGestureRecognizer:singleTapRecognizer];
	
	// Create the icon.
	UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconWithShadow.png"]];
	icon.center = CGPointMake(40, 43);
	[adContainer addSubview:icon];
	
	UIFont *blackFont = [UIFont fontWithName:@"ReklameScript-Regular" size:15.0f];
	UIColor *blackTextColor = [UIColor blackColor];
	
	// Create the top label.
	UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(82, 21, 140, 20)];
	topLabel.backgroundColor = [UIColor clearColor];
	topLabel.font = blackFont;
	topLabel.textColor = blackTextColor;
	topLabel.textAlignment = UITextAlignmentLeft;
	topLabel.text = @"✓ More difficulties";
	[adContainer addSubview:topLabel];
	
	UILabel *topLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(82, 41, 140, 20)];
	topLabel2.backgroundColor = [UIColor clearColor];
	topLabel2.font = blackFont;
	topLabel2.textColor = blackTextColor;
	topLabel2.textAlignment = UITextAlignmentLeft;
	topLabel2.text = @"✓ Thousands of puzzles";
	[adContainer addSubview:topLabel2];
	
	UILabel *topLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(82, 61, 140, 20)];
	topLabel3.backgroundColor = [UIColor clearColor];
	topLabel3.font = blackFont;
	topLabel3.textColor = blackTextColor;
	topLabel3.textAlignment = UITextAlignmentLeft;
	topLabel3.text = @"✓ No ads";
	[adContainer addSubview:topLabel3];
	
	// Create the bottom label.
	UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 76, 80, 20)];
	bottomLabel.backgroundColor = [UIColor clearColor];
	bottomLabel.font = [UIFont fontWithName:@"ReklameScript-Medium" size:17.0f];
	bottomLabel.textColor = blackTextColor;
	bottomLabel.textAlignment = NSTextAlignmentCenter;
	bottomLabel.text = @"Sudo";
	[adContainer addSubview:bottomLabel];
	
	// Create the app store button.
	UIImageView *appStoreButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AppStoreButton"]];
	appStoreButton.center = CGPointMake(248, 53);
	[adContainer addSubview:appStoreButton];
	
	// Start with the corner un-folded.
	[self.foldedCornerViewController resetToStartPosition];
}

- (void)_adContainerWasTapped {
	ZSAppDelegate *appDelegate = (ZSAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[UIApplication sharedApplication] openURL:appDelegate.iTunesURL];
}

- (void)viewWasPromotedToFront {
	[super viewWasPromotedToFront];
	
	// Create the ad.
	self.adView = [[IMAdView alloc] initWithFrame:CGRectMake(1.5f, 2, 300, 250) imAppId:@"4028cbff39009b2401390d0b50220174" imAdUnit:IM_UNIT_300x250 rootViewController:self];
	self.adView.delegate = self;
	self.adView.animationType = kIMAnimationOff;
	[self.adContainer addSubview:self.adView];
	
	IMAdRequest *request = [IMAdRequest request];
	[self.adView loadIMAdRequest:request];
	
	// Tell the user that the ad is loading.
	self.innerAdText.text = @"Loading an ad…";
	
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
	
	self.innerAdText.text = @"This space intentionally left blank.";
	self.innerAdText.hidden = NO;
	
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

- (void)startFoldAnimationDidFinishWithViewController:(ZSFoldedCornerViewController *)viewController {
	[super startFoldAnimationDidFinishWithViewController:viewController];
	
	[self updateScreenshotSynchronous:NO];
}

#pragma mark - IMAdDelegate Implementation

- (void)adViewDidFinishRequest:(IMAdView *)adView {
	self.needsScreenshotUpdate = YES;
	self.innerAdText.hidden = YES;
}

- (void)adView:(IMAdView *)view didFailRequestWithError:(IMAdError *)error {
	switch (error.code) {
		default:
		case kIMADInternalError:
		case kIMADNetworkError:
		case kIMADInvalidRequestError:
			self.needsScreenshotUpdate = YES;
			self.innerAdText.text = @"There was an error loading ads.";
			break;
			
		case kIMAdRequestInProgressError:
		case kIMAdClickInProgressError:
			break;
			
		case kIMADNoFillError:
			self.needsScreenshotUpdate = YES;
			self.innerAdText.text = @"This space intentionally left blank.";
			break;
	}
}

@end

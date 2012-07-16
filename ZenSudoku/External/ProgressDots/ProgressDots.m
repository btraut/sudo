//
//  ProgressDots.m
//  ZenSudoku
//
//  Created by Brent Traut on 7/5/12.
//  Copyright (c) 2012 Ten Four Software, LLC. All rights reserved.
//

#import "ProgressDots.h"

@interface ProgressDots () {
	NSInteger _totalInitializedDots;
	NSMutableArray *_dotViews;
	UIImageView *_selectedDotView;
}

@end

@implementation ProgressDots

@synthesize totalDots = _totalDots;
@synthesize selectedDot = _selectedDot;
@synthesize dotOffset = _dotOffset;
@synthesize dotImage = _dotImage;
@synthesize selectedDotImage = _selectedDotImage;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	
    if (self) {
        _dotImage = [UIImage imageNamed:@"LightBlueDot.png"];
        _selectedDotImage = [UIImage imageNamed:@"DarkBlueDot.png"];
		
		_dotViews = [NSMutableArray array];
    }
	
    return self;
}

- (void)setTotalDots:(NSInteger)totalDots {
	if (totalDots != _totalDots && totalDots >= 0) {
		_totalDots = totalDots;
		
		if (_selectedDot >= totalDots) {
			_selectedDot = 0;
		}
		
		[self _initializeDots];
		[self _placeViews];
		[self _refreshLayout];
	}
}

- (void)setSelectedDot:(NSInteger)selectedDot {
	if (selectedDot != _selectedDot && selectedDot >= 0 && selectedDot < self.totalDots) {
		_selectedDot = selectedDot;
		
		[self _refreshLayout];
	}
}

- (void)setDotOffset:(CGFloat)dotOffset {
	if (dotOffset != _dotOffset) {
		_dotOffset = dotOffset;
		
		[self _refreshLayout];
	}
}

- (void)setDotImage:(UIImage *)dotImage {
	if (dotImage != _dotImage) {
		_dotImage = dotImage;
		
		for (NSInteger i = 0; i < _totalInitializedDots; ++i) {
			UIImageView *currentImageView = [_dotViews objectAtIndex:i];
			[currentImageView removeFromSuperview];
		}
		
		_totalInitializedDots = 0;
		
		[self _initializeDots];
		[self _placeViews];
		[self _refreshLayout];
	}
}

- (void)setSelectedDotImage:(UIImage *)selectedDotImage {
	if (selectedDotImage != _selectedDotImage) {
		_selectedDotImage = selectedDotImage;
		
		[_selectedDotView removeFromSuperview];
		_selectedDotView = nil;
		
		[self _initializeDots];
		[self _placeViews];
		[self _refreshLayout];
	}
}

- (void)_initializeDots {
	// Build new dots.
	for (NSInteger i = self.totalDots - _totalInitializedDots - 1; i > 0; --i) {
		UIImageView *newDotView = [[UIImageView alloc] initWithImage:self.dotImage];
		[_dotViews addObject:newDotView];
		++_totalInitializedDots;
	}
	
	if (_selectedDotView == nil) {
		_selectedDotView = [[UIImageView alloc] initWithImage:self.selectedDotImage];
	}
}

- (void)_placeViews {
	// Add or remove the deselected dots.
	for (NSInteger i = 0; i < _totalInitializedDots; ++i) {
		UIImageView *imageView = [_dotViews objectAtIndex:i];
		
		if (i < self.totalDots - 1) {
			[self addSubview:imageView];
		} else {
			[imageView removeFromSuperview];
		}
	}
	
	// Add or remove the selected dot.
	if (self.totalDots) {
		[self addSubview:_selectedDotView];
	} else {
		[_selectedDotView removeFromSuperview];
	}
}

- (void)_refreshLayout {
	CGFloat totalWidth = (self.totalDots - 1) * (self.dotImage.size.width + self.dotOffset) + self.selectedDotImage.size.width;
	CGFloat totalHeight = self.selectedDotImage.size.height > self.dotImage.size.height ? self.selectedDotImage.size.height : self.dotImage.size.height;
	
	self.frame = CGRectMake(self.center.x - (totalWidth / 2), self.center.y - (totalHeight / 2), totalWidth, totalHeight);
	
	CGFloat currentOffset = 0;
	NSInteger currentDot = 0;
	
	for (NSInteger i = 0; i < self.totalDots; ++i) {
		if (i == self.selectedDot) {
			_selectedDotView.frame = CGRectMake(currentOffset, 0, self.selectedDotImage.size.width, self.selectedDotImage.size.height);
			currentOffset += self.selectedDotImage.size.width + self.dotOffset;
		} else {
			UIImageView *currentDotView = [_dotViews objectAtIndex:currentDot];
			currentDotView.frame = CGRectMake(currentOffset, 0, self.selectedDotImage.size.width, self.selectedDotImage.size.height);
			currentOffset += self.dotImage.size.width + self.dotOffset;
			++currentDot;
		}
	}
}

@end

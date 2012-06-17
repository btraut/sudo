//
//  ZSFoldedPageView.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSGameViewController;

@interface ZSFoldedPageView : UIView

@property (nonatomic, assign) CGSize foldDimensions;

- (void)createScreenshotFromView;
- (void)restoreScreenshotFromOriginal;
- (void)setAllSubViewsHidden:(BOOL)hidden except:(UIView *)excludeView;

@end

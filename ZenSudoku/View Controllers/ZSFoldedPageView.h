//
//  ZSFoldedPageView.h
//  ZenSudoku
//
//  Created by Brent Traut on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZSGameViewController;

@interface ZSFoldedPageView : UIView {
	ZSGameViewController *foldSizeDelegate;
}

@property (nonatomic, strong) ZSGameViewController *foldSizeDelegate;

- (void)createScreenshotFromView;
- (void)restoreScreenshotFromOriginal;
- (void)setAllSubViewsHidden:(BOOL)hidden;

@end

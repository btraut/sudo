/*
// Commenting out the normal main function to fix a bug in XCode 5 causing lots of console noise.
 
//
//  main.m
//  ZenSudoku
//
//  Created by Brent Traut on 11/24/11.
//  Copyright (c) 2011 Ten Four Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZSAppDelegate.h"

int main(int argc, char *argv[])
{
	@autoreleasepool {
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([ZSAppDelegate class]));
	}
}
*/

#import <UIKit/UIKit.h>

#import "ZSAppDelegate.h"


typedef int (*PYStdWriter)(void *, const char *, int);
static PYStdWriter _oldStdWrite;

int __pyStderrWrite(void *inFD, const char *buffer, int size);
int __pyStderrWrite(void *inFD, const char *buffer, int size)
{
	if ( strncmp(buffer, "AssertMacros:", 13) == 0 ) {
		return 0;
	}
	return _oldStdWrite(inFD, buffer, size);
}

int main(int argc, char * argv[])
{
	_oldStdWrite = stderr->_write;
	stderr->_write = __pyStderrWrite;
	@autoreleasepool {
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([ZSAppDelegate class]));
	}
}
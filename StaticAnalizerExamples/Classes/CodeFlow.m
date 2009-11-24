//
//  CodeFlow.m
//  StaticAnalizerExamples
//
//  Not Created by Cyril Godefroy on 15/09/09.


//  http://iphonedevelopertips.com/xcode/static-code-analysis-clang-and-xcode-3-2.html

/* Nice arrows heh? Shows an uninitialized variable bug all paths are
 taken and csa tries all valid values of x, including =0 */

#import "CodeFlow.h"


@implementation CodeFlow


- (BOOL)getSomeValue:(int)x {
	BOOL positiveFlag;
	
	if (x < 0) {    
		positiveFlag = NO;   
	}   
	else if (x > 0) {
		positiveFlag = YES;
	}  
	
	return positiveFlag;
}


@end

//
//  CodeFlow.m
//  StaticAnalizerExamples
//
//  Created by Cyril Godefroy on 15/09/09.
//  Copyright 2009 eCOMPOSITE. All rights reserved.
//  [TODO] credit URL where I found that code very first hit for Google "static analyzer xcode"

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

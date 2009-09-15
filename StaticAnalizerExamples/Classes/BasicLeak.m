//
//  BasicLeak.m
//  StaticAnalizerExamples
//
//  Created by Cyril Godefroy on 15/09/09.
//  Copyright 2009 eCOMPOSITE. All rights reserved.
//

#import "BasicLeak.h"


@implementation BasicLeak

- (id)init{
	[super init];
	NSString *message = [[NSString alloc] initWithString:@"Hello World"];
	
	NSLog(@"%@",message);
	return self;
}

@end

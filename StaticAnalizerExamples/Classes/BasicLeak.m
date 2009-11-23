//
//  BasicLeak.m
//  StaticAnalizerExamples
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

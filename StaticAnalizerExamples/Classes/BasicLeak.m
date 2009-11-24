//
//  BasicLeak.m
//  StaticAnalizerExamples
//

/* First example of the most common problem newbies find in their code:
 leaks. This one is easy to solve, just uncomment */

#import "BasicLeak.h"


@implementation BasicLeak

- (id)init{
	[super init];
	NSString *message = [[NSString alloc] initWithString:@"Hello World"];
	
	NSLog(@"%@",message);
	//[message release];
	return self;
}

@end

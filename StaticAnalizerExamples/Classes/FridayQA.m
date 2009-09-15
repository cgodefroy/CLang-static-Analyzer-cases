//
//  WorksWithC.m
//  StaticAnalizerExamples
//
//  http://www.mikeash.com/?page=pyblog/friday-qa-2009-03-06-using-the-clang-static-analyzer.html
//

#import <Foundation/Foundation.h>

static void TestFunc(char *inkind, char *inname)
{
	NSString *kind = [[NSString alloc] initWithUTF8String:inkind];
	NSString *name = [NSString stringWithUTF8String:inname];
	if(!name)
		return;
	
	const char *kindC = NULL;
	const char *nameC = NULL;
	if(kind)
		kindC = [kind UTF8String];
	if(name)
		nameC = [name UTF8String];
	if(!isalpha(kindC[0]))
		return;
	if(!isalpha(nameC[0]))
		return;
	
	[kind release];
	[name release];
}


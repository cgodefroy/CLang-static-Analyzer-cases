//
//  OverRelease.m
//  StaticAnalizerExamples
//
//  Created by Cyril Godefroy on 16/09/09.
//

/* Example of Memory Error nr 2 : using an object after releasing it. 
 Interesting example because it shows how paths are taken and how the analyser goes deep
 */ 

#import <Foundation/Foundation.h>

void doSomething(NSUInteger count, NSArray *objects, NSString *string){
	NSObject *objectID = nil;
	
	for (NSUInteger i = 0; i< count; i++){
		NSObject *obj = [objects objectAtIndex:i];
		
		if([obj isMemberOfClass:[NSString class]]){
			objectID = [[NSString alloc] initWithString:string];
		}
		
		//Do Something
		
		if (objectID != nil){
			[objectID release];
		}
	}
}
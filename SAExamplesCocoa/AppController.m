//
//  AppController.m
//  
//
//  Created by Guillaume Cerquant on 22/04/09.
//  Copyright 2009 MacMation. All rights reserved.
//


#import "AppController.h"


@interface AppController (PrivateMethods)


@end


@implementation AppController


#pragma mark /* Class methods */

/*
 * This is a singleton
 * Code from http://developer.apple.com/documentation/Cocoa/Conceptual/CocoaFundamentals/CocoaObjects/chapter_3_section_10.html
 * with a few customization
 * This one also has been modified to not allow Interface Builder to alloc/init more instance
 * The _controller assignment is now done in init
 */
static AppController *_controller = nil;


//NS_RETURNS_RETAINED

+ (id)controller {
	@synchronized(self) {
        if (_controller == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return _controller;
}


/*
+ (void)initialize
 {
	static BOOL initialized = NO;
 
	 NSLog(@"%s", _cmd);
 
	 if (!initialized) {
		 initialized = YES;
		 _controller = [[self alloc] init];
	 }
 }
 */

+ (id)allocWithZone:(NSZone *)zone
{
	
    @synchronized(self) {
        if (_controller == nil) {
            return [super allocWithZone:zone];
            // _controller = [super allocWithZone:zone];
            // return _controller;  // assignment and return on first allocation
        }
    }
    return _controller; //on subsequent allocation attempts return nil
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release{
    //do nothing
}

- (id)autorelease{
    return self;
}

- (NSString*) returnsRetained {
	return [[NSString alloc] initWithCString:"no leak here"];
}
- (NSString*) alsoReturnsRetained {
	return [[NSString alloc] initWithCString:"flag a leak"];
}

- (id)init
{
	// Enforcing singletoness
    if (nil != _controller) {

		return _controller;
	}
	
	
    if (self = [super init]) {
	
		_controller = self; // Saving instance to static variable, for singletoness purpose

	}
	
    return self;
}


// End of singleton method





@end

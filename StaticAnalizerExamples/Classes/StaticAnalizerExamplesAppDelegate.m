//
//  StaticAnalizerExamplesAppDelegate.m
//  StaticAnalizerExamples
//
//  Created by Cyril Godefroy on 15/09/09.
//  Copyright eCOMPOSITE 2009. All rights reserved.
//

#import "StaticAnalizerExamplesAppDelegate.h"

@implementation StaticAnalizerExamplesAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end

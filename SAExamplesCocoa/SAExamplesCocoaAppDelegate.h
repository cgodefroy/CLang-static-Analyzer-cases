//
//  SAExamplesCocoaAppDelegate.h
//  SAExamplesCocoa
//
//  Created by Cyril Godefroy on 17/09/09.
//  Copyright 2009 eCOMPOSITE. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SAExamplesCocoaAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end

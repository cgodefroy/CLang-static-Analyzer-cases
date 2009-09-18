//
//  AppController.h
//  
//
//  Created by Guillaume Cerquant on 22/04/09.
//  Copyright 2009 MacMation. All rights reserved.
//

//#import <PreferencePanes/NSPreferencePane.h>
//#import <Cocoa/Cocoa.h>


#ifndef __has_feature      // Optional.
#define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif

#ifndef NS_RETURNS_RETAINED
#if __has_feature(attribute_ns_returns_retained)
#define NS_RETURNS_RETAINED __attribute__((ns_returns_retained))
#else
#define NS_RETURNS_RETAINED
#endif
#endif


@interface AppController: NSObject /*: NSPreferencePane*/ {

}


+ (id) controller ;
@end

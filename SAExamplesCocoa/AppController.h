//
//  AppController.h
//  
//
//  Created by Guillaume Cerquant on 22/04/09.
//  Copyright 2009 MacMation. All rights reserved.
//

//#import <PreferencePanes/NSPreferencePane.h>
//#import <Cocoa/Cocoa.h>

//NS_RETURNS_RETAINED


@interface AppController: NSObject /*: NSPreferencePane*/ {

}

// Two solutions
// Either add an NS_RETURNS_RETAINED here or rename the method

+ (id) controller ;
- (NSString*) returnsRetained;
- (NSString*) alsoReturnsRetained;

@end
